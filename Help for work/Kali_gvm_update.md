### kali Проверить версию баз уязвимостей можно:
		https://127.0.0.1:9392/feedstatus или WEB >>> Administration >>> Feed Status

sudo apt update
sudo apt full-upgrade
потом ребут

sudo gvm-check-setup, если ругается что gvm не установлен, то gvm-setup, если он ругается на PostgreSQL, то поменять в конфигах порты, потом снова gvm-setup, потом gvm-check-setup

если gvm-check-setup прошел без ошибок, то greenbone-feed-sync


# Проверка портов 
	ss -4lnt (смотрим на каком порте кто сидит)
	Останавливаем каждый сервис по очереди.
	sudo systemctl stop postgresql@15-main.service
	Проверяем опять порты: ss -4lnt
	Останавливаем каждый сервис по очереди.
	sudo systemctl stop postgresql@16-main.service
	Проверяем опять порты: ss -4lnt

# Расположение PostgreSQL 
	cd /etc/postgresql/15/main
	cd ../../16/main

	Редактируем файл конфигурации
	sudo nano postgresql.conf (в 15 и 16 версиях)

	Меняем порт 15 версии на 5434
	Меняем порт 16 версии на 5432

# Запускаем службу postgreSQL
	sudo systemctl start postgresql@15-main.service
	sudo systemctl start postgresql@16-main.service

# Проверка статуса службы
	sudo systemctl status postgresql@15-main.service
	sudo systemctl status postgresql@16-main.service

# После обновления код доступа обновиться, его нужно будет записать типо:
	echo "123123123-123123123-123123-123123123-12312313" > gvm
	пароль будет храниться в директории /home