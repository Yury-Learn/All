# Проблема скачивания файлов из репозитория ru archive ubuntu.
	sudo nano /etc/resolv.conf

Найти строку "nameserver"
Заменить ip на другой DNS (8.8.8.8 - пример)

Можно повторно выполнить sudo apt-get update


# Шаги по исправлению ошибки
1. SSH
2. sudo nano /etc/apt/sources.list
3. Заменить "ru.archive.ubuntu.com" на "archive.ubuntu.com"
4. Ctrl + O что бы сохранить изменения (Ctrl + X >>> YES)
5. Проверяем sudo apt update