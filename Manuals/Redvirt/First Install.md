---
tags: redvirt
---
  ## 1.  Установка РЕД ОС мин.сервер 
	  1. Программное ПО - min server
	  2. Настройка пользователей
	  3. root / Novgorod53_red
	  4. доступ по SHH
	  5. Network: Имя / Сеть

### 1. Tmux 

необязательно
```sh
dnf install tmux && touch ~/.tmux.conf && echo "set -g mouse on" >> ~/.tmux.conf && echo "setw -g mouse on" >> ~/.tmux.conf && echo "set -g terminal-overrides 'xterm*:smcup@:rmcup@'" >> ~/.tmux.conf && source ~/.bashrc && tmux source ~/.tmux.conf
```

```sh
sudo yum install ncurses ncurses-compat-libs 
sudo yum update ncurses
sudo yum install ncurses ncurses-compat-libs && sudo yum update ncurses
```

### 3.  настройка /etc/hosts
>	192.168.0.43 host1.test.redvirt *Хост-гипервизор*  
>	192.168.0.44 nfs.test.redvirt *NFS-хранилище*  
>	192.168.0.221 hosted-engine.test.redvirt *Менеджер РЕД Виртуализации

==**на всех серверах**==

Если забыли изменить имя
1. hostnamectl set-hostname


### 5. Скрипт подготовки
```sh
mkdir /mnt/iso
mount /tmp/rv73-pkgs-install.iso /mnt/iso
/mnt/iso/install.sh
```

### 6. Инициатор LUN

- Узнаем имя
	```sh
	more /etc/iscsi/initiatorname.iscsi
	```
	ISCSI_PRODUCT
	iqn.1994-05.com.redhat:bf60a6469e4e
	- Прописываем в NetApp в группу Gisno
	 Проверьте доступ к таргету:
```sh
        iscsiadm -m discovery -t sendtargets -p 192.244.244.105
        #iscsiadm -m node -l -T iqn.1992-08.com.netapp:sn.312f34171c7111eba0d6d039ea212413:vs.4#
```

- Автоподключение targets
```sh
cd /var/lib/iscsi/send_targets/
mcedit 192.244.244.105,3260/st_config
mcedit /var/lib/iscsi/send_targets/192.244.244.105,3260/st_config
```
>discoveryd = Yes


- Обновляем ядро
```sh
	dnf install -y kernel-lt-5.15.131-2.el7virt
```

- Выбираем ядро
```sh
chmod u+x ./kernel.sh
./kernel.sh
```
- ядро *el7virt8*

- Установить **Cockpit**
```sh
	systemctl enable --now cockpit.socket
	```

==REBOOT==
### 7. Bond-соединение

Настроить внутри bond (244 / 245)

8. проблема с **atop**
	Создайте резервную копию файла `/var/log/atop/atop_20240605` .  
	Не размещайте резервную копию в каталоге `/var/log/atop` .  
	После чего удалите файл `/var/log/atop/atop_20240605` и произведите перезапуск службы atop командой
	
	```
	systemctl restart atop
	```

9. Установка ПО, когда сервер в кластере
	```sh
	dnf install loginfo --enablerepo=* -y
	```

- После установки Ред ОС:
	
	1. Примонтировать диск
	2. Запустить скрипт
	3. Перезагрузить сервер
	4. Добавить на сервере engine и на установленных хостах в /etc/hosts доменное имя дополнительного хоста.
	5. Добавить хост через веб интерфейс по доменному имени, если на хосте должен работать engine при сбое другого хоста, то необходимо эту функцию включить.

graviton1.gisno.redvirt
192.168.53.76


## 2.  Установка гостевых агентов и драйверов в ВМ РЕД ОС 

Гостевые агенты и драйверы для РЕД Виртуализации предоставляются  
репозиторием для конкретной версии и редакции РЕД ОС.  
Процедура:  
1. Войдите в виртуальную машину РЕД ОС.  
2. Установите гостевой агент и зависимости:  
```sh
dnf install ovirt-guest-agent-common  
```
3. Запустите и включите службу ovirt-guest-agent:  
```sh
systemctl start ovirt-guest-agent  
systemctl enable ovirt-guest-agent 
systemctl enable --now ovirt-guest-agent
```
4. Запустите и включите службу qemu-guest-agent:  

```sh
systemctl start qemu-guest-agent  
systemctl enable qemu-guest-agent
systemctl enable --now qemu-guest-agent  
```

```sh
systemctl enable --now ovirt-guest-agent && systemctl enable --now qemu-guest-agent
```

Теперь гостевой агент передает информацию об использовании в Engine РЕД  
Виртуализации. Вы можете настроить гостевой агент в файле /etc/ovirt-guestagent.conf

- HA-Score

	1. HA-score — это значение от 0 до 3400. Оно отражает пригодность хоста для работы с виртуальной машиной engine.
		
		- 0 означает непригодный
		- 3400 значит все хорошо  

    1. Проверить оценку хостов можно командой приведенной ниже, значение Score. HA-score рассчитывается на основе статуса хоста, пинг, загрузка процессора, состояние шлюза и т. д.  Количество запущенных ВМ не влияет на оценку.

	```
	hosted-engine --vm-status
	```


https://redos.red-soft.ru/base/manual/utilites/grubby/?sphrase_id=472243


```
dnf install -y kernel-lt-5.15.131-2.el7virt
```


### NetApp

```
адрес
https://192.168.53.100

логин / пароль
admin
Zdrav53_hard!
```