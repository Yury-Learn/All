---
tags:
  - bash
  - "#linux"
  - "#debian"
---
1. Для начала нужно узнать свой IP ifconfig. Это можно сделать с помощью утилиты Net-tools. Для этого нужно выполнить команду:
	`apt install net-tools
2. Далее небходимо отредактировать конфигурационный файл /etc/network/interfaces. Это можно сделать любым редактором, например Nano. Для этого необходимо выполнить команду: 
	# nano /etc/network/interfaces

	*Конфигурация по умолчанию выглядит вот так:*
	allow-hotplug ens33
	iface ens33 inet dhcp
3. Для настройки статического адреса нобходимо поменять настройки интерфейса с dhcp на static и ниже куазать адрес, маску, шлюз и серверы имен.
	*Ставим свои настройки*
	iface ens33 inet static
		address 192.168.10.12
		netmask 255.255.255.0
		gateway 192.168.10.1
		dns-nameservers 77.88.8.2 8.8.8.8

4. Для настройки нескольких адресов, необходимо добавить еще один интерфейс с тем же именем и дописать к нему номер. Далее так же указать данные адреса и маски.

	iface ens33 inet static
		address 192.168.10.12
		netmask 255.255.255.0
		gateway 192.168.10.1
		dns-nameservers 77.88.8.2 8.8.8.8
	auto ens33:1
	iface ens33:1 inet static
		address 192.168.0.2
		netmask 255.255.255.0

Use the following command to restart the server networking service. 
 sudo /etc/init.d/networking restart 
or 
sudo /etc/init.d/networking stop 
sudo /etc/init.d/networking start 
else 
sudo systemctl restart networking.

Once this is done, use the following command to check the server network status.