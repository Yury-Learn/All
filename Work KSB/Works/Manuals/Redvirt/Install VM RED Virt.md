1. Создаём сервер [[Servers]]
	- HDD
	- Network
	- CPU / RAM
2. Параметры загрузки
	- прикрепить CD
	- Включить выбор Boot
3. Установка
	- Выбираем самостоятельную установку (Решение проблем / Установить в базовом граф. режиме)
	-  Диск автоматически
	- Сервер минимальный
	- Сеть + имя
	- ROOT  (убрать заблок. + запретить SSH) 
		-  Novgorod53_root
	-  Пользователь (сделать администратором)
		-  1cgisno
		-  Novgorod53_1c
4. После установки выключить, снять галочку выбор boot

5. Ставим tmux (дальше работаем в нём) tmux
	~/.tmux.conf
	Вставляем
>	set -g mouse on
>	setw -g mouse on
>	set -g terminal-overrides 'xterm*:smcup@:rmcup@'



6. Проверяем имя + сеть

7. Дальше 
```sh
dnf update -y
```

8. GuestAdditions
```sh
systemctl enable --now ovirt-guest-agent && systemctl enable --now qemu-guest-agent
```

reboot

Сервера
[[Servers]]