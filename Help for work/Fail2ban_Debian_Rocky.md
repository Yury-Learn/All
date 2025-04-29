### Установка
	sudo (apt|dnf) install fail2ban
	В роки обязательно надо сделать: sudo dnf install epel-release -y
### Редактирование 
	sudo nano /etc/fail2ban/jail.local

#### Создать файл логов
```
touch /var/log/auth.log
```
##### Настройки для Debian
```
[DEFAULT]
ignoreip = 127.0.0.1/8

[sshd]
enabled  = true
port     = 22
filter   = sshd
logpath  = /var/log/auth.log
maxretry = 6
findtime = 30m
bantime  = 4h
```

##### Настройки для Rocky
[DEFAULT]
ignoreip = 127.0.0.1/8

[sshd]
enabled  = true
port     = 22
filter   = sshd
banaction = iptables-multiport
maxretry = 10
findtime = 30m
bantime  = 4h

###### Перезапускаем службу.
```sh
sudo systemctl restart fail2ban
sudo systemctl enable fail2ban
```


maxretry = максимальное число попыток
findtime = в течение которого времени
bantime = время блокировки

ignoreip = 10.38.40.68 10.38.30.0/24 не попадет под БАН: 10.38.40.68 и целая подсеть .1 - .254

