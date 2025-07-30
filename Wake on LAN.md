#   Как удаленно разбудить Linux по сети с помощью Wake On Lan?

• May 13 at 10:57

С помощью функции Wake-on-LAN (WoL) вы можете удаленно разбудить Linux компьютер, отправив по сети Ethernet специальный широковещательный пакет (magic packet) с MAC адресом компьютера, который нужно включить.

Перед включением WoL в Linux, нужно убедиться, что ваша материнская плата поддерживает эту функцию и включить ее в настройка BIOS. Перезагрузите компьютер и откройте настройки BIOS (UEFI). Название параметра WoL может отличаться в зависимости от модели материнской платы и версии прошивки. Эта опция может называться Wake on PCI/PCI-E, Power или Resume on PCI/PCI-E, S5 Wake on LAN. Найдите и включите эту опцию, сохраните настройки BIOS.

Для управления Wake On LAN в Linux обычно используется утилита **ethtool**. Установите ее:

`$ sudo apt install ethtool`

Выведите список сетевых интерфесов:

`$ ifconfig`

Скопируйте имя вашего LAN интерфейса Ethernet и выполните команду:

`$ sudo ethtool enp3s0 | grep "Wake-on"`

[

](http://desktop-app-resource/photo/5912241844559918206/5081221152046068652)

ethtool - включить Wake On Lan в Linux

В данном случае WoL отключена (**d** — disabled).

Включите Wake on LAN для адаптера:

`$ sudo ethtool --change enp3s0 wol g`

Статус параметра Wake On Lan должен измениться на **g** (Wake on MagicPacket).

Ошибка `netlink error: cannot enable unsupported WoL mode (offset 36)` указывает на то, что WoL не поддерживается сетевым адаптером или отключен в BIOS Теперь вы можете удаленно разбудить ваш хост Linux. Однако параметр WoL сетевого интерфейса сбросится при перезагрузке. Есть несколько способ автоматического включения Wake on LAN для адаптера при загрузке. Во многих дистрибутивах Linux (Ubuntu, Rocky, Debian) для управления сетевыми настройками используется **NetworkManager**. В NetworkManager включить WoL для адаптера можно командами nmcli:

`$ nmcli con show`

Скопируйте имя Ethernet подключения (wired в этом примере) и включите WoL:

`$ sudo nmcli c modify "wired" 802-3-ethernet.wake-on-lan magic`

Проверьте, что Wake on LAN включен:

`$ nmcli c show "wired" | grep 802-3-eth`

[

](http://desktop-app-resource/photo/5914881149207950202/5081221152046068652)

nmcli включить WOL для сетевого адаптера в Linux (Ubuntu)

В других дистрибутивах Linux можно включить WakeOnLan при загрузке через systemd. Создайте новый юнит systemd:

`$ sudo systemctl edit wol.service --full --force`

Добавьте следующие строки:

```
[Unit]
Description=Enable Wake-on-LAN
After=network-online.target
[Service]
Type=oneshot
ExecStart=/sbin/ethtool --change enp3s0 wol g
[Install]
 WantedBy=network-online.target
```

[

](http://desktop-app-resource/photo/5912182732925023412/5081221152046068652)

создать systemd unit для WoL

Включите сервис:

`$ sudo systemctl daemon-reload`

`$ sudo systemctl enable wol.service`

`$ sudo systemctl start wol.service`

Проверьте, то сервис запущен:

`$ systemctl status wol`

Теперь можно протестировать, как будет работать Wake on Lan на этом хосте. Скопируйте MAC адреса сетевого адаптера, для которого вы включили WoL.

[

](http://desktop-app-resource/photo/5912617692853023839/5081221152046068652)

ifconfig - скопировать MAC адрес сетевой карты

Проверьте, включен ли в Linux спящий режим:

`$ sudo systemctl status sleep.target suspend.target hibernate.target hybrid-sleep.target`

Отправьте компьютер с Linux в спящий режим:

`$ sudo systemctl suspend`

В Linux для отправки magic packet можно использовать утилиту `wakeonlan` или `etherwake` :

`$ sudo apt-get install wakeonlan etherwake`

Чтобы удаленно разбудить компьютер, укажите его MAC адрес (компьютеры находится в одной LAN, т.к. WoL пакет не маршрутизируется):

`$ wakeonlan <MAC-address>`

Или

`$ etherwake <MAC-address>`

Компьютер должен включиться после получения магического пакета. Обратите внимание, что для работы WoL не нужно открывать порт в файерволе Linux. Широковещательный UDP пакет WoL принимается и обрабатывается непосредсвенно сетевой картой без использования сетевого стека Linux.

[

](http://desktop-app-resource/photo/5912443390195250265/5081221152046068652)

unsupported WoL mode (offset 36)

Wrong layout?