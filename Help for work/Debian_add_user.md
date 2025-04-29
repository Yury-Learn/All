---
tags: linux, bash, users
---
- Вам необходимо активировать режим суперпользователя, установить команду sudo и добавить своего пользователя в группу sudo
```sh
su -
apt-get install sudo -y
usermod -aG sudo yourusername
```
- Для создания новой учетной записи пользователя операционной системы с именем username с помощью команды adduser, выполните следующую команду:
``` sh
sudo adduser username
```

- Добавляем права SUDO для нового пользователя
```sh
sudo usermod -aG sudo username
```