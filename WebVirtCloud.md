#kvm 

> Базовый стенд: ВМ на Debian 12 (аналогично для Astra Linux SE), панель на отдельной ВМ, гипервизоры libvirt/KVM, доступ qemu+ssh через сервисного пользователя `webvirt`, корпоративный Nginx с TLS и именем `astrakvm.ksb.local`.

---

# 1) ВМ под панель: подготовка ОС

```bash
# Обновить индексы и систему (тихо, без интерактива)
sudo apt update && sudo apt -y dist-upgrade

# Базовые пакеты: git, python, venv, Nginx, Supervisor, утилиты libvirt, curl, sqlite3
sudo apt install -y git python3 python3-venv python3-dev build-essential \
  nginx supervisor libvirt-clients openssh-client rsyslog curl jq sqlite3
```

**Зачем:** всё, что нужно для запуска WVC (Django+Gunicorn), проксирования (Nginx), демонов novncd/socketiod (Supervisor) и работы с libvirt (virsh).

---

# 2) Развёртывание WebVirtCloud

```bash
# Куда ставим
sudo mkdir -p /srv/webvirtcloud && cd /srv/webvirtcloud
sudo chown $USER:$USER /srv/webvirtcloud

# Забираем исходники
git clone https://github.com/retspen/webvirtcloud.git .
# (при необходимости зафиксируйте конкретный релиз/коммит)

# Python-окружение
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip wheel
pip install -r requirements.txt
deactivate

# Первичная настройка приложения
sudo -u www-data -H /srv/webvirtcloud/venv/bin/python manage.py migrate
sudo -u www-data -H /srv/webvirtcloud/venv/bin/python manage.py collectstatic --noinput
sudo -u www-data -H /srv/webvirtcloud/venv/bin/python manage.py createsuperuser
```

**Зачем:** создаём виртуальное окружение, накат миграций, сборка статики, делаем админа.

---

# 3) Конфиг Django (безопасный прод)

Открой `/srv/webvirtcloud/webvirtcloud/settings.py` и выставь ключевые опции:

```python
DEBUG = False
ALLOWED_HOSTS = ["astrakvm.ksb.local", "localhost", "127.0.0.1"]
CSRF_TRUSTED_ORIGINS = ["https://astrakvm.ksb.local"]

# работа за реверс-прокси (важно для https/redirect)
SECURE_PROXY_SSL_HEADER = ("HTTP_X_FORWARDED_PROTO", "https")
USE_X_FORWARDED_HOST = True

# https-флаги и HSTS
SECURE_SSL_REDIRECT = True
SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True
SECURE_HSTS_SECONDS = 31536000
SECURE_HSTS_INCLUDE_SUBDOMAINS = True
SECURE_HSTS_PRELOAD = False

# Публичные параметры WS (консоль) за прокси
WS_PUBLIC_HOST = "astrakvm.ksb.local"
WS_PUBLIC_PORT = 443
WS_PUBLIC_PATH = "/novncd/"

SOCKETIO_PUBLIC_HOST = "astrakvm.ksb.local"
SOCKETIO_PUBLIC_PORT = 443
SOCKETIO_PUBLIC_PATH = "socket.io/"
```

**Зачем:** убираем DEBUG, разрешаем нужное имя, доверяем https-оригин, правильно сообщаем Django о «реальном» https за прокси, настраиваем внешние адреса для WebSocket.

---

# 4) Supervisor: gunicorn + novncd + socketiod

`/etc/supervisor/conf.d/webvirtcloud.conf`

```ini
[program:webvirtcloud]
command=/srv/webvirtcloud/venv/bin/gunicorn --workers 3 --bind 127.0.0.1:8000 webvirtcloud.wsgi:application
directory=/srv/webvirtcloud
user=www-data
autostart=true
autorestart=true
redirect_stderr=true

[program:novncd]
command=/srv/webvirtcloud/venv/bin/python3 /srv/webvirtcloud/console/novncd --host 127.0.0.1 --port 6080
directory=/srv/webvirtcloud
user=www-data
autostart=true
autorestart=true
redirect_stderr=true

[program:socketiod]
command=/srv/webvirtcloud/venv/bin/python3 /srv/webvirtcloud/console/socketiod -d --host 127.0.0.1 --port 6081
directory=/srv/webvirtcloud
user=www-data
autostart=true
autorestart=true
redirect_stderr=true
```

```bash
sudo systemctl restart supervisor
sudo supervisorctl status     # все три должны быть RUNNING
```

**Зачем:** сервисно запускаем приложение и WS-демоны, слушаем только loopback.

---

# 5) Локальный Nginx (панель) — строго за корпоративным

`/etc/nginx/conf.d/webvirtcloud.conf`

```nginx
server {
    listen 80 default_server;
    server_name 10.38.22.115 astrakvm.ksb.local _;

    # пускать только корпоративный Nginx и локально
    allow 127.0.0.1;
    allow 10.38.22.65;
    deny  all;

    location /static/ {
        root /srv/webvirtcloud;
        expires max;
    }

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_http_version 1.1;

        proxy_set_header Host              $host;            # без :порт
        proxy_set_header X-Real-IP         $remote_addr;
        proxy_set_header X-Forwarded-For   $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Host  $host;
        proxy_set_header X-Forwarded-Proto $http_x_forwarded_proto;

        client_max_body_size 1024M;
        proxy_read_timeout 1800; proxy_send_timeout 1800; proxy_connect_timeout 1800;
    }

    # noVNC/SPICE websocket
    location /novncd/ {
        proxy_pass http://127.0.0.1:6080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }

    # socket.io
    location /socket.io/ {
        proxy_pass http://127.0.0.1:6081;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }

    # совместимость
    location /websockify {
        proxy_pass http://127.0.0.1:6080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
```

```bash
sudo nginx -t && sudo systemctl reload nginx
```

**Зачем:** панель доступна только из корпоративного прокси, а WS-трафик завернут локально на 6080/6081.

---

# 6) Корпоративный Nginx (10.38.22.65) — TLS + WebSocket

`/etc/nginx/sites-available/astrakvm.ksb.local.conf` (включите линком в `sites-enabled/`)

```nginx
server {
  listen 80;
  server_name astrakvm.ksb.local;
  allow 10.38.22.0/24; allow 10.38.40.0/24; deny all;
  return 301 https://$host$request_uri;
}

server {
  listen 443 ssl http2;
  server_name astrakvm.ksb.local;

  allow 10.38.22.0/24; allow 10.38.40.0/24; deny all;

  ssl_certificate     /etc/ssl/astrakvm/astrakvm.ksb.local.crt;
  ssl_certificate_key /etc/ssl/astrakvm/astrakvm.ksb.local.key;
  # ssl_trusted_certificate /etc/ssl/astrakvm/chain.crt;   # при наличии

  ssl_protocols TLSv1.2 TLSv1.3;
  ssl_prefer_server_ciphers on;
  ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:'
              'ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:'
              'ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305';
  add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
  server_tokens off;

  proxy_http_version 1.1;
  proxy_send_timeout 3600; proxy_read_timeout 3600; proxy_connect_timeout 60;

  set $backend http://10.38.22.115;

  location / {
    proxy_pass $backend;
    proxy_set_header Host              $host;
    proxy_set_header X-Forwarded-Host  $host;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Real-IP         $remote_addr;
    proxy_set_header X-Forwarded-For   $proxy_add_x_forwarded_for;
    proxy_set_header Connection        "";
  }

  location /novncd/ {
    proxy_pass $backend;
    proxy_set_header Host              $host;
    proxy_set_header X-Forwarded-Host  $host;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Real-IP         $remote_addr;
    proxy_set_header X-Forwarded-For   $proxy_add_x_forwarded_for;
    proxy_set_header Upgrade           $http_upgrade;
    proxy_set_header Connection        "upgrade";
  }

  location /socket.io/ {
    proxy_pass $backend;
    proxy_set_header Host              $host;
    proxy_set_header X-Forwarded-Host  $host;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Real-IP         $remote_addr;
    proxy_set_header X-Forwarded-For   $proxy_add_x_forwarded_for;
    proxy_set_header Upgrade           $http_upgrade;
    proxy_set_header Connection        "upgrade";
  }

  location /websockify {
    proxy_pass $backend;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
  }

  location /static/ {
    proxy_pass $backend;
    expires 1h;
    proxy_set_header Connection "";
  }
}
```

```bash
sudo nginx -t && sudo systemctl reload nginx
```

**Зачем:** безопасный https, правильные заголовки Host/X-Forwarded-Proto, WS-апгрейд.

---

# 7) Доступ к гипервизорам по qemu+ssh (пользователь `webvirt`)

На **каждом** гипервизоре (Astra/Debian):

```bash
# сервисная учётка без пароля
sudo adduser --disabled-password --gecos "WebVirtCloud svc" webvirt || true

# права на libvirt/KVM
sudo usermod -a -G kvm,libvirt,libvirt-qemu,libvirt-admin webvirt

# ключи
sudo install -d -m 700 -o webvirt -g webvirt ~webvirt/.ssh
sudo touch ~webvirt/.ssh/authorized_keys && sudo chown webvirt:webvirt ~webvirt/.ssh/authorized_keys && sudo chmod 600 ~webvirt/.ssh/authorized_keys

# libvirt
sudo systemctl enable --now libvirtd
```

На **панели**:

```bash
# хост-ключи (без интерактива)
sudo -u www-data -H bash -lc 'ssh-keyscan -H <HV1> <HV2> ... >> /var/www/.ssh/known_hosts'
sudo chmod 644 /var/www/.ssh/known_hosts

# развернуть публичный ключ панели на гипервизоры
sudo -u www-data -H ssh-copy-id -i /var/www/.ssh/id_ed25519.pub webvirt@<HV>
# (или скопировать ключ через root, если пароли выключены)

# проверка ssh и libvirt
sudo -u www-data -H ssh -o PreferredAuthentications=publickey webvirt@<HV> true
sudo -u www-data -H virsh -c "qemu+ssh://webvirt@<HV>/system" list --all
```

**Зачем:** панель соединяется с libvirt по `qemu+ssh` от имени `webvirt`. Рекомендуется в `~webvirt/.ssh/authorized_keys` поставить префикс `from="IP_панели"`.

---

# 8) Добавление compute в WVC (UI)

В панели → **Computes → Add**

- Name: `<имя>`
    
- Hostname: `<IP/имя гипервизора>`
    
- Login: `webvirt`
    
- Connection: **SSH (qemu+ssh)**
    

Проверьте **Storage** (пул `default` и, при необходимости, создайте `iso`) и **Networks** (мосты).

---

# 9) Резервное копирование панели (+ротация)

`/usr/local/sbin/backup-webvirtcloud.sh`

```bash
#!/usr/bin/env bash
set -euo pipefail
TS="$(date +%F_%H%M%S)"
DST_DIR="/var/backups/webvirtcloud"
ARCH="${DST_DIR}/wvc_${TS}.tgz"
KEEP_DAYS=14
mkdir -p "$DST_DIR"
TMPROOT="$(mktemp -d)"; trap 'rm -rf "$TMPROOT"' EXIT

# безопасная копия БД
if command -v sqlite3 >/dev/null; then
  sqlite3 /srv/webvirtcloud/db.sqlite3 ".backup '$TMPROOT/srv/webvirtcloud/db.sqlite3'"
else
  mkdir -p "$TMPROOT/srv/webvirtcloud"
  cp -a /srv/webvirtcloud/db.sqlite3 "$TMPROOT/srv/webvirtcloud/"
fi

# нужные пути
mkdir -p "$TMPROOT/etc/nginx/conf.d" "$TMPROOT/etc/supervisor/conf.d" \
         "$TMPROOT/srv/webvirtcloud/webvirtcloud" "$TMPROOT/srv/webvirtcloud/conf" \
         "$TMPROOT/srv/webvirtcloud/static" "$TMPROOT/var/www"
cp -a /srv/webvirtcloud/webvirtcloud/settings.py "$TMPROOT/srv/webvirtcloud/webvirtcloud/"
cp -a /srv/webvirtcloud/conf/. "$TMPROOT/srv/webvirtcloud/conf/" || true
cp -a /srv/webvirtcloud/static/. "$TMPROOT/srv/webvirtcloud/static/" || true
cp -a /etc/nginx/conf.d/webvirtcloud.conf "$TMPROOT/etc/nginx/conf.d/"
cp -a /etc/supervisor/conf.d/webvirtcloud.conf "$TMPROOT/etc/supervisor/conf.d/"
[ -d /var/www/.ssh ] && cp -a /var/www/.ssh "$TMPROOT/var/www/.ssh" || true

tar -C "$TMPROOT" -czf "$ARCH" .
sha256sum "$ARCH" > "${ARCH}.sha256"
find "$DST_DIR" -type f -name 'wvc_*.tgz*' -mtime +${KEEP_DAYS} -delete
echo "OK -> $ARCH"
```

```bash
sudo chmod +x /usr/local/sbin/backup-webvirtcloud.sh
sudo /usr/local/sbin/backup-webvirtcloud.sh
echo '15 2 * * * root /usr/local/sbin/backup-webvirtcloud.sh' | sudo tee /etc/cron.d/wvc-backup >/dev/null
```

**Зачем:** ежедневный архив в `/var/backups/webvirtcloud`, хранение 14 дней, быстрое восстановление.

---

# 10) Логи и аудит

- Включить rsyslog → Graylog (адрес сервера/порт из вашей инфраструктуры).
    
- В Nginx (корпоративном) вести стандартный access/error.
    
- На панели можно держать только error; при отладке временно включать access.
    

---

# 11) Обновления и перезагрузки

Скрипт ежемесячного апдейта с логированием в syslog/Graylog (из нашего шага 6):

`/usr/local/sbin/wvc-monthly-upgrade.sh` — `apt update && dist-upgrade`, `needrestart -r a`, проверка `/var/run/reboot-required`.  
Cron: `15 3 1 * * root /usr/local/sbin/wvc-monthly-upgrade.sh`.

---

# 12) Безопасность (чек-лист)

- Панель слушает только :80 и пускает **только** корпоративный Nginx (`allow 10.38.22.65;`).
    
- Корпоративный Nginx — только TLS 1.2/1.3, HSTS, строгий набор шифров, ACL по подсетям.
    
- У `webvirt` вход **по ключу**, в `sshd_config`:
    
    ```
    Match User webvirt
        PasswordAuthentication no
        PubkeyAuthentication yes
        AuthenticationMethods publickey
    ```
    
    и `from="IP_панели"` в `authorized_keys`.
    
- Ключи `www-data` в `/var/www/.ssh/` — права 700 на каталог, 600 на приватный ключ и known_hosts — 644.
    
- Регулярные бэкапы + восстановление «на сухую».
    
- Разграничение ролей в WVC (группы/права) — выдаём минимум.
    

---

# 13) Типовые проверки (smoke-tests)

- `sudo -u www-data -H virsh -c 'qemu+ssh://webvirt@<HV>/system' list --all`
    
- Веб-вход, `ALLOWED_HOSTS`/CSRF нет ошибок, HSTS в заголовках.
    
- **Console** (noVNC/SPICE): в логах панели должны появиться `GET /novncd/?token=...` и/или `/socket.io/...` со статусом **101**.
    
- Создание ВМ из ISO, снапшот, клон, удаление.
    
- Бэкап создался и `sha256sum -c` прошёл.
    

---

# 14) Частые проблемы и быстрые фиксы

- **400 Bad Request при входе:**  
    Неверный Host/Proto. На корпоративном Nginx в `location /` добавьте:
    
    ```
    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-Proto $scheme;
    ```
    
    На панели в `location /` не затирайте `X-Forwarded-Proto` на `http`. Проверьте `ALLOWED_HOSTS`/`CSRF_TRUSTED_ORIGINS`.
    
- **Пустая консоль / 502 на `/novncd/`:**  
    `novncd`/`socketiod` не запустились или слушают не тот порт. В supervisor используйте:
    
    ```
    ... novncd --host 127.0.0.1 --port 6080
    ... socketiod -d --host 127.0.0.1 --port 6081
    ```
    
    В WVC укажите `WS_PUBLIC_HOST/PORT/PATH` и аналогичные для Socket.IO.
    
- **`Permission denied (publickey)` при добавлении гипервизора:**  
    Ключ ещё не установлен у `webvirt`. Скопируйте `/var/www/.ssh/id_ed25519.pub` на хост и добавьте в `~webvirt/.ssh/authorized_keys` (с `from="IP_панели"`).
    
- **CSRF 403:**  
    Добавьте имя в `CSRF_TRUSTED_ORIGINS` как **https-URL**.
    

---

# 15) Масштабирование и эксплуатация

- Горизонтально добавляйте computes (qemu+ssh), центральная панель остаётся одна.
    
- Для большого количества ВМ — выносите базы образов (ISO/шаблоны) в общий NFS/CEPH-RBD, подключайте пулами в libvirt.
    
- Периодически чистите «мусорные» снапшоты/образы.
    
- Документируйте IP/имена compute, версии libvirt/qemu, мосты/сети, storage pools.
    

---

Если хочешь — сделаю сокращённый **чек-лист PDF** или Ansible-плейбук по этой методичке.