### Настройка сетевого интерфейса
	sudo apt install net-tools


### Утилита для настройки сетевого интерфейса
	sudo nmtui


### Перезагрузка сети
	sudo systemctl restart networking.service


 
### Файл настроек LAN Debian/Ubuntu
	nano /etc/network//interfaces


	DHCP вкл
	auto ens192
	iface ens192 inet dhcp


	DHCP откл
	auto ens192
	iface ens192 inet static
	adress 10.38.22.31
	netmask 255.255.255.0
	 gateway 10.38.22.1

### Настраиваем DNS Server
	редактируем /etc/resolv.conf
	cat /etc/resolv.conf (отобразит текущий сервер)

	после редактирования данного файла, ничего перезагружать не нужно.
	Можно проверить с помощью утилиты nslookup.exe 
	Пример: nslookup yandex.ru

### Добавление статических маршрутов
Редактировать надо /etc/network/interface
	up ip route add 192.168.5.0/24 via 192.168.0.10

Пиши данное правило с новой строки. При загрузке сервера правило будет запускатся автоматически.
