/etc/ssh/sshd_config

1. Открыть терминал. CTRL + ALT + T
	sudo apt update
	sudo apt install openssh-server
2. Проверить работу службы
	sudo systemctl status ssh
  Вывод должен быть следующий: 
   ssh.service - OpenBSD Secure Shell server Loaded: loaded (/lib/systemd/system/ssh.service; enabled; vendor preset: enabled) Active: active (running) since Mon 2020-06-01 12:34:00 CEST; 9h ago ...
3. Настроить брандмауэр UFW
	sudo ufw allow ssh

p.s: есть еще **nftables**.


#### Что бы отключить или включить SSH службу:
	sudo systemctl disable --now ssh
				или
	sudo systemctl enable --now ssh




#### Rocky Linux, убиваем процесс sshd
	pkill -HUP sshd

#### Либо перезагрузить службу
	sudo systemctl restart sshd