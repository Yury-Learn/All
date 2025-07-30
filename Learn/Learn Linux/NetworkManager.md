#bash #linux #network #nmcli


Проверка состояния подключения к сети:
	`nmcli networking connectivity check`
	>	full

Список доступных подключений:
	`nmcli connection show`

Информация о подключении **System enp0s31f6**:
	`nmcli connection show "System enp0s31f6"`

Деактивировать подключение **System enp0s31f6**:
	`nmcli conn down "System enp0s31f6"`

Изменить подключение **System enp0s31f6** с DHCP на Static:
	`nmcli con mod "System enp0s31f6" ipv4.method manual ipv4.address 192.168.0.40/24 ipv4.gateway 192.168.0.1`

Указать DNS-сервер:
	`nmcli connection modify "System enp0s31f6" ipv4.dns 192.168.0.122`

Добавить DNS-сервер к имеющимся:
	`nmcli connection modify "System enp0s31f6" +ipv4.dns 8.8.8.8`

Изменить подключение **System enp0s31f6** на DHCP:
	`nmcli con mod "System enp0s31f6" ipv4.method auto`