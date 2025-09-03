
---

## 0) Предпосылки

- DSM включена **User Home Service**: `/var/services/homes -> /volume1/homes`.
    
- На обоих NAS создан пользователь `ksbadmin` с HOME; на приёмнике есть `backup`.
    
- Достаточно прав администратора (sudo) на приёмнике.
    

---

## 1) Ключи SSH (на источнике)

```bash
# создать ~/.ssh и ключ
sudo -u ksbadmin -H sh -lc 'mkdir -p ~/.ssh && chmod 700 ~/.ssh'
sudo -u ksbadmin -H sh -lc 'ssh-keygen -t ed25519 -N "" -f ~/.ssh/id_ed25519'

# залить публичный ключ на приёмник
sudo -u ksbadmin -H sh -lc 'cat ~/.ssh/id_ed25519.pub' | \
ssh -p 22 ksbadmin@10.38.22.27 \
  'umask 077; mkdir -p "$HOME/.ssh"; cat >> "$HOME/.ssh/authorized_keys"; chmod 600 "$HOME/.ssh/authorized_keys"'

# проверка
ssh -p 22 -o PasswordAuthentication=no ksbadmin@10.38.22.27 'echo OK && id && /usr/bin/rsync --version'
```

---

## 2) Файл исключений (через vi)

```bash
sudo vi /tmp/rsync-exclude.txt
```

Вставьте:

```
@eaDir/
#recycle/
#snapshot/
lost+found/
Thumbs.db
.DS_Store
ehthumbs.db
```

Права:

```bash
sudo chown ksbadmin:users /tmp/rsync-exclude.txt
sudo chmod 644 /tmp/rsync-exclude.txt
```

---

## 3) Подготовить каталог на приёмнике

```bash
ssh -p 22 -o PasswordAuthentication=no ksbadmin@10.38.22.27 'mkdir -p /volume1/archieve-nas2 && ls -ld /volume1/archieve-nas2'
# при необходимости дать временные права записи (чтобы rsync мог писать)
ssh -p 22 ksbadmin@10.38.22.27 'sudo chown -R ksbadmin:users /volume1/archieve-nas2'
```

---

## 4) Rsync: dry-run → полный прогон → дельты → финал

> Мы копируем **без переноса владельцев/групп/бита прав** и **без ACL/xattrs**.  
> Используем `--inplace` (не создаёт `.tmp`) — **не сочетать с `-S/--sparse`**.

**Dry-run (проверка):**

```bash
rsync -avnH --inplace --no-o --no-g --no-perms \
  --exclude-from=/tmp/rsync-exclude.txt \
  --rsync-path="/usr/bin/rsync" \
  -e 'ssh -p 22 -o PasswordAuthentication=no' \
  /volume1/Archive/  ksbadmin@10.38.22.27:/volume1/archieve-nas2/
```

**Полный первичный синк:**

```bash
rsync -aH --inplace --no-o --no-g --no-perms \
  --info=progress2 --partial \
  --exclude-from=/tmp/rsync-exclude.txt \
  --rsync-path="/usr/bin/rsync" \
  -e 'ssh -p 22 -o PasswordAuthentication=no' \
  /volume1/Archive/  ksbadmin@10.38.22.27:/volume1/archieve-nas2/
```

**Дельты (повторять по мере изменений):** та же команда, что выше.

**Финал (freeze источника → зеркалирование):**

1. В DSM на источнике перевести `/volume1/Archive` в **Read-Only** (SMB/NFS).
    
2. Убедиться, что записи остановились.
    
3. Сначала dry-run, затем реально:
    

```bash
rsync -navH --inplace --no-o --no-g --no-perms --delete \
  --exclude-from=/tmp/rsync-exclude.txt --rsync-path="/usr/bin/rsync" \
  -e 'ssh -p 22 -o PasswordAuthentication=no' \
  /volume1/Archive/  ksbadmin@10.38.22.27:/volume1/archieve-nas2/

rsync -aH --inplace --no-o --no-g --no-perms --delete \
  --info=progress2 --exclude-from=/tmp/rsync-exclude.txt --rsync-path="/usr/bin/rsync" \
  -e 'ssh -p 22 -o PasswordAuthentication=no' \
  /volume1/Archive/  ksbadmin@10.38.22.27:/volume1/archieve-nas2/
```

---

## 5) Закрепить владельца и ACL (на приёмнике)

**Владелец `backup:users`:**

```bash
# с TTY (попросит пароль sudo)
ssh -t -p 22 ksbadmin@10.38.22.27 'sudo chown -R backup:users /volume1/archieve-nas2'
```

**ACL (шаблон: backup/admins — Full; users — Read-Only; наследование включено):**

```bash
ssh -p 22 ksbadmin@10.38.22.27 'sudo /usr/syno/bin/synoacltool -set "/volume1/archieve-nas2" \
 "user:backup:allow:rwxpdDaARWcCo:fd--","\
 group:administrators:allow:rwxpdDaARWcCo:fd--","\
 group:users:allow:r-x---a-R-c--:fd--","\
 everyone@:deny:rwxpdDaARWcCo:fd--" \
 && sudo chmod 2775 "/volume1/archieve-nas2" \
 && sudo /usr/syno/bin/synoacltool -get "/volume1/archieve-nas2"'
```

> Для RW группы `users` замените её строку на: `group:users:allow:rwxpdDaARWcCo:fd--`.

---

## 6) Публикация шары и smoke-тест

**SMB:** DSM → Файл-службы → SMB ВКЛ; Общие папки → Создать/Изменить шару на `/volume1/archieve-nas2`; выставить права (ACL).

**Быстрый тест с Linux:**

```bash
smbclient -L 10.38.22.27 -U backup
smbclient //10.38.22.27/archieve-nas2 -U backup -c 'ls'
smbclient //10.38.22.27/archieve-nas2 -U backup -c 'put /etc/hosts .conn_test && del .conn_test'
```

**Windows (CMD):**

```bat
net use Z: \\10.38.22.27\archieve-nas2 /user:backup
dir Z:\
copy %SystemRoot%\System32\drivers\etc\hosts Z:\.conn_test & del Z:\.conn_test
net use Z: /delete
```

---

## 7) Контроль целостности

```bash
# файлов и объём (должны совпадать)
ssh -p 22 -o PasswordAuthentication=no ksbadmin@10.38.22.27 \
 'find /volume1/archieve-nas2 -xdev -type f | wc -l; du -sh /volume1/archieve-nas2'
find /volume1/Archive -xdev -type f | wc -l; du -sh /volume1/Archive

# финальная дельта (пусто)
rsync -navH --inplace --no-o --no-g --no-perms \
  --exclude-from=/tmp/rsync-exclude.txt --rsync-path="/usr/bin/rsync" \
  -e 'ssh -p 22 -o PasswordAuthentication=no' \
  /volume1/Archive/  ksbadmin@10.38.22.27:/volume1/archieve-nas2/
```

---

## 8) Завершение и уборка

- Оставить старую шару **RO** на 3–7 дней, затем финальный dry-run и удаление.
    
- Удалить/понизить временные права `ksbadmin` на приёмнике (если выдавались).
    
- Сохранить `rsync-exclude.txt` в вашу документацию.
    

---

## 9) Частые ошибки и быстрые фиксы

- **`Permission denied (publickey,password)` / code 255** — не прошёл SSH: проверьте порт 22/ключи/что не запускали `sudo rsync` (или добавьте `-i ~ksbadmin/.ssh/id_ed25519`).
    
- **`rsync service is no running (code 43)`** — часто маска аутентификации/неверный порт.
    
- **`mkstemp … Permission denied (13)`** — нет прав создавать `.tmp`: используйте `--inplace` или временно дайте ACL на запись.
    
- **`rsync_xal_set … user.rsync.synoacl … denied (13)`** — не пишутся xattrs/ACL Synology: **не** используйте `-A -X` или запускайте удалённый rsync через `sudo`.
    
- **`--sparse cannot be used with --inplace`** — выбирайте что-то одно (в кейсе — `--inplace`).
    

---

## 10) Мини-шпаргалка vi

- Вставка — `i` → ввод текста → `Esc :wq Enter` (сохранить), `Esc :q! Enter` (выйти без сохранения).
    
- Поиск — `/строка` (`n` — далее).
    
- Удалить строку — `dd`, вставить из буфера — `p`.
    

---

### Готово

Перенос завершён; права и публикация настроены; smoke-тесты прошли.

---

**Вопросы для продолжения**  
A) Сгенерировать версию чеклиста с вашими именами/сетями/паролями, чтобы сразу положить в внутренний wiki?  
B) Нужны примеры автоподключения SMB: Linux `/etc/fstab` и Windows GPO (скрипт/политика)?  
C) Хотите шаблон для обратной миграции/DR (откат на старый NAS) — короткая памятка команд?