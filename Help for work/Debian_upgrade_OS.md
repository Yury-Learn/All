# Полностью обновляем текущую систему: 
	apt update && apt upgrade && apt dist-upgrade && apt --purge autoremove
# Проверяем версию:
	cat /etc/debian_version

Нужно обновить файл с репозиториями /etc/apt/sources.list и заменим релиз с buster на bullseye.

	deb http://mirror.yandex.ru/debian bullseye main
	deb-src http://mirror.yandex.ru/debian bullseye main

	deb http://mirror.yandex.ru/debian bullseye-updates main
	deb-src http://mirror.yandex.ru/debian bullseye-updates main

	deb http://security.debian.org/ bullseye-security main
	deb-src http://security.debian.org/ bullseye-security main


	Старая запись была вида --- deb http://security.debian.org/ buster/updates main