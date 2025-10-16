#prometheus #grafana #node_exporter

# 0) TL;DR — быстрый чек‑лист
1. Обнови `inventory` (при смене IP/FQDN):
   - `ex24 ansible_host=10.38.16.3`, `ex25 ansible_host=10.38.16.2` и т.п.
2. Почисти старые SSH host key → прими новые:
   ```bash
   ssh-keygen -R ex24; ssh-keygen -R ex25
   ssh-keygen -R 10.38.16.3; ssh-keygen -R 10.38.16.2
   ssh-keyscan -H -t ed25519 ex24 10.38.16.3 >> ~/.ssh/known_hosts
   ssh-keyscan -H -t ed25519 ex25 10.38.16.2 >> ~/.ssh/known_hosts
   ```
3. Проверь Ansible доступ по паролю через Vault:
   ```bash
   ansible all -i inventory/hosts.ini --limit ex24,ex25 -m ping --ask-vault-pass
   ```
4. Раскати роль `node_exporter`:
   ```bash
   ansible-playbook -i inventory/hosts.ini playbooks/node_exporter.yml \
     --limit ex24,ex25 --ask-vault-pass
   ```
5. Открой порт 9100/tcp (если роль не делает это): firewalld/ufw/iptables.
6. Добавь таргеты в Prometheus (static/file_sd) и сделай reload.
7. Проверь: `curl http://ex24:9100/metrics`, Prometheus → *Status → Targets*, Grafana → Node Exporter dashboard.

---

# 1) Предпосылки и принципы
- Управление — через **Ansible** с паролями, защищёнными **Vault**.
- На хостах используем **node_exporter** как systemd‑сервис (порт **9100/tcp**).
- Таргеты в **Prometheus** — через `static_configs` либо `file_sd`.
- После **переустановки** или **смены IP** всегда:
  1) чистим старые SSH host key; 2) актуализируем `inventory`; 3) проверяем Ansible‑доступ; 4) раскатываем роль.

---

# 2) Обновление inventory при новых/«переопределённых» хостах
## 2.1 Пример `inventory/hosts.ini`
```ini
[all]
ex24 ansible_host=10.38.16.3
ex25 ansible_host=10.38.16.2

[node]
ex24
ex25
```
**Пояснения:**
- `ansible_host` — фактический IP/имя для подключения (удобно при смене IP).
- Группа `[node]` — если плейбук/роль таргетируется по группе.

## 2.2 Пользователь и пароли через Vault
Пример `host_vars/ex24/vault.yml` (зашифрован Ansible Vault):
```yaml
ansible_user: ksbadmin
ansible_password: !vault |
  <зашифрованная_строка>
ansible_become: true
ansible_become_method: sudo
ansible_become_password: !vault |
  <зашифрованная_строка>
```
Сгенерировать шифровки:
```bash
ansible-vault encrypt_string 'ПарольSSH' --name ansible_password
ansible-vault encrypt_string 'ПарольSudo' --name ansible_become_password
```
Запуск с Vault:
```bash
# Пароль спросят интерактивно
ansible -i inventory/hosts.ini ... --ask-vault-pass
# или из файла
ansible -i inventory/hosts.ini ... --vault-password-file .vault_pass.txt
```

---

# 3) Починка SSH после переустановки (host key)
## 3.1 Очистить конфликтующие ключи и принять новые
```bash
ssh-keygen -R ex24; ssh-keygen -R ex25
ssh-keygen -R 10.38.16.3; ssh-keygen -R 10.38.16.2
ssh-keyscan -H -t ed25519 ex24 10.38.16.3 >> ~/.ssh/known_hosts
ssh-keyscan -H -t ed25519 ex25 10.38.16.2 >> ~/.ssh/known_hosts
```
**Пояснения:**
- `ssh-keygen -R <host>` — удаляет старую запись из `~/.ssh/known_hosts`.
- `ssh-keyscan` — подтягивает новый публичный ключ; `-H` — хэширует имя в файле; `-t ed25519` — современный тип ключей.

## 3.2 Быстрая ручная проверка паролем (опционально)
```bash
ssh -o PubkeyAuthentication=no -o PreferredAuthentications=password \
    root@ex24 'hostname -f; id -un'
ssh -o PubkeyAuthentication=no -o PreferredAuthentications=password \
    root@ex25 'hostname -f; id -un'
```
**Пояснения:**
- Форсируем парольную аутентификацию (как в вашей среде). Убедимся, что логин/пароль валидны.

---

# 4) Проверка доступности Ansible
```bash
ansible all -i inventory/hosts.ini --limit ex24,ex25 -m ping --ask-vault-pass
```
**Пояснения:**
- `-m ping` — базовая проверка модуля и Python на целевых.
- Если Python отсутствует (минимальные образы), сначала:
  ```bash
  ansible all -i inventory/hosts.ini --limit ex24,ex25 -m raw -a 'uname -a' --ask-vault-pass
  # установить python3
  ansible all -i inventory/hosts.ini --limit ex24,ex25 -b -m raw \
    -a 'apt-get update && apt-get install -y python3 || dnf install -y python3'
  ```

---

# 5) Раскатка роли node_exporter
## 5.1 Сухой прогон (рекомендуется)
```bash
ansible-playbook -i inventory/hosts.ini playbooks/node_exporter.yml \
  --limit ex24,ex25 --check --diff --ask-vault-pass
```
**Пояснения:**
- `--check` — покажет, что **изменится**, но без применения.
- `--diff` — визуализирует различия по файлам (юнит, конфиги).

## 5.2 Применение
```bash
ansible-playbook -i inventory/hosts.ini playbooks/node_exporter.yml \
  --limit ex24,ex25 --ask-vault-pass
```
**Обычно роль делает:**
- Создаёт пользователя, кладёт бинарь `/usr/local/bin/node_exporter`.
- Устанавливает `systemd`‑юнит `/etc/systemd/system/node_exporter.service`.
- Флаги по умолчанию:
  - `--web.listen-address=":9100"` — слушать на всех интерфейсах.
  - (опционально) `--collector.systemd`, `--collector.textfile.directory=/var/lib/node_exporter/textfile_collector` — если включены в переменных роли.
- Делает `daemon-reload`, `enable`, `start`.

## 5.3 Пример systemd‑юнита (на случай ручной проверки)
```ini
[Unit]
Description=Prometheus Node Exporter
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter \
  --web.listen-address=":9100" \
  --collector.systemd \
  --collector.textfile.directory=/var/lib/node_exporter/textfile_collector

[Install]
WantedBy=multi-user.target
```
**Пояснения ключей:**
- `--web.listen-address` — адрес/порт, на которых слушает экспортер.
- `--collector.systemd` — метрики по unit’ам systemd.
- `--collector.textfile.directory` — каталог для ваших пользовательских метрик (файлы `*.prom`).

---

# 6) Открытие порта 9100/tcp (если не делает роль)
## 6.1 firewalld
```bash
ansible all -i inventory/hosts.ini --limit ex24,ex25 -b -m firewalld \
  -a 'port=9100/tcp state=enabled permanent=true'
ansible all -i inventory/hosts.ini --limit ex24,ex25 -b -m command -a 'firewall-cmd --reload'
```
## 6.2 ufw
```bash
ansible all -i inventory/hosts.ini --limit ex24,ex25 -b -m ufw \
  -a 'rule=allow port=9100 proto=tcp'
```
## 6.3 iptables (временное решение)
```bash
ansible all -i inventory/hosts.ini --limit ex24,ex25 -b -m command \
  -a 'iptables -I INPUT -p tcp --dport 9100 -j ACCEPT'
```

---

# 7) Интеграция с Prometheus
## 7.1 Вариант A — `static_configs` в `prometheus.yml`
```yaml
scrape_configs:
  - job_name: 'node'
    scrape_interval: 15s
    static_configs:
      - targets:
          - 'ex24:9100'
          - 'ex25:9100'
```
**Пояснения:**
- `job_name` — имя джоба; используйте ваш существующий `node`.
- `targets` — список адресов `host:port`.

## 7.2 Вариант B — `file_sd` (рекомендуется при частых изменениях)
`/etc/prometheus/file_sd/node.json`:
```json
[
  {"labels": {"job": "node"},
   "targets": ["ex24:9100", "ex25:9100"]}
]
```
В `prometheus.yml` должен быть `file_sd_configs`:
```yaml
- job_name: 'node'
  file_sd_configs:
    - files:
      - /etc/prometheus/file_sd/*.json
```

## 7.3 Применение конфигурации Prometheus
```bash
# если включён lifecycle API
curl -X POST http://localhost:9090/-/reload
# либо перезапуск сервиса
sudo systemctl restart prometheus
```

---

# 8) Верификация
## 8.1 На хостах
```bash
systemctl status node_exporter --no-pager -l
curl -s http://127.0.0.1:9100/metrics | head -n 5
```
Ожидаем строку `node_exporter_build_info{...} 1`.

## 8.2 С управляющего узла
```bash
curl -s http://ex24:9100/metrics | head -n 5
curl -s http://ex25:9100/metrics | head -n 5
```

## 8.3 В Prometheus и Grafana
- Prometheus → **Status → Targets** → job `node` → `ex24:9100`, `ex25:9100` должны быть `UP`.
- Grafana → ваш Node Exporter dashboard (например, 1860/12486) — новые хосты видны в переменной `instance`.

---

# 9) «Переопределение» старых хостов (смена IP/FQDN/переустановка)
1. **Inventory:** обнови `ansible_host` (и группу, если нужно).
2. **SSH host key:** `ssh-keygen -R <имя|ip>` → `ssh-keyscan -H -t ed25519 ... >> known_hosts`.
3. **Vault‑доступы:** проверь `ansible_user/password/become_password` в `host_vars`/`group_vars`.
4. **Роль:** перезапусти плейбук с `--limit` на нужные хосты.
5. **Prometheus:** поправь `targets` (static/file_sd) и сделай reload.
6. **Grafana:** дашборды автоматически подхватят новые `instance`.

## 9.1 Перекрёстные FQDN после переустановки
Если `ex24` показывает `ex25.ksb.local` (и наоборот):
```bash
sudo hostnamectl set-hostname ex24.ksb.local
# при необходимости поправь /etc/hosts и DNS
```
Затем перезапусти `node_exporter` (чтобы лейбл `node_uname_info` и др. сошлись с ожидаемым именем) — не критично, но полезно для чистоты.

---

# 10) Откат / удаление node_exporter
```bash
sudo systemctl disable --now node_exporter
sudo rm -f /etc/systemd/system/node_exporter.service
sudo systemctl daemon-reload
sudo userdel -r node_exporter 2>/dev/null || true
sudo rm -f /usr/local/bin/node_exporter
# при необходимости закрыть порт в firewall
```
Исключи хост из `targets` (static/file_sd) и сделай reload Prometheus.

---

# 11) Частые ошибки и быстрая диагностика
- **REMOTE HOST IDENTIFICATION HAS CHANGED!** — очисти старый ключ: `ssh-keygen -R <имя|ip>`, снова добавь через `ssh-keyscan`.
- **Ansible: UNREACHABLE (Permission denied)** — проверь `ansible_user/password` в Vault, что подключаемся не к `root@...`, а к нужному пользователю.
- **Python не найден (ping падает)** — используй `-m raw` для одноразовой установки `python3`.
- **Порт 9100 закрыт** — открой через firewalld/ufw/iptables.
- **SELinux блокирует** — временно `setenforce 0` для диагностики, затем создай корректную политику (или настрой роль для правильных контекстов).
- **Дубликаты таргетов** — проверь, что `ex24:9100`/`ex25:9100` объявлены один раз (static vs file_sd).

---

# 12) Примеры файлов
## 12.1 Мини‑плейбук вызова роли
```yaml
# playbooks/node_exporter.yml
- hosts: node
  become: true
  roles:
    - role: node_exporter
```

## 12.2 Пример file_sd файла (управляется Ansible шаблоном)
```json
[
  {"labels": {"job": "node"},
   "targets": ["ex24:9100", "ex25:9100"]}
]
```

## 12.3 Пример host_vars с Vault
```yaml
# host_vars/ex24/vault.yml
ansible_user: ksbadmin
ansible_password: !vault |
  $ANSIBLE_VAULT;1.1;AES256;...
ansible_become: true
ansible_become_method: sudo
ansible_become_password: !vault |
  $ANSIBLE_VAULT;1.1;AES256;...
```

---

# 13) Контрольный прогон (команды по порядку)
```bash
# A. Inventory
vim inventory/hosts.ini

# B. SSH ключи
ssh-keygen -R ex24; ssh-keygen -R ex25
ssh-keygen -R 10.38.16.3; ssh-keygen -R 10.38.16.2
ssh-keyscan -H -t ed25519 ex24 10.38.16.3 >> ~/.ssh/known_hosts
ssh-keyscan -H -t ed25519 ex25 10.38.16.2 >> ~/.ssh/known_hosts

# C. Проверка Ansible
ansible all -i inventory/hosts.ini --limit ex24,ex25 -m ping --ask-vault-pass

# D. Раскатка роли
ansible-playbook -i inventory/hosts.ini playbooks/node_exporter.yml \
  --limit ex24,ex25 --ask-vault-pass

# E. Firewall (если нужно)
ansible all -i inventory/hosts.ini --limit ex24,ex25 -b -m firewalld \
  -a 'port=9100/tcp state=enabled permanent=true'
ansible all -i inventory/hosts.ini --limit ex24,ex25 -b -m command -a 'firewall-cmd --reload'

# F. Верификация
curl -s http://ex24:9100/metrics | head -n 5
curl -s http://ex25:9100/metrics | head -n 5

# G. Prometheus → добавить таргеты и reload
#   (static_configs или file_sd)
```

