
#iptables #linux #bash
выполните следующую команду в терминале:

```
sudo apt-get install iptables
```

После установки iptables, необходимо создать правила для брандмауэра, которые будут определять, какие сетевые пакеты разрешены или запрещены. Для начала, создайте новый файл с правилами:

```
sudo nano /etc/iptables.rules
```

В этом файле вам нужно добавить правила для различных сетевых интерфейсов и услуг. Ниже приведен пример базовой конфигурации брандмауэра:

```
*filter
:INPUT DROP [0:0]
:FORWARD DROP [0:0]
:OUTPUT ACCEPT [0:0]
```

Разрешить входящие соединения на localhost

```
-A INPUT -i lo -j ACCEPT
```

Разрешить установленные и относящиеся соединения

```
-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
```

Разрешить ICMP (ping)

```
-A INPUT -p icmp -j ACCEPT
```

Разрешить SSH

```
-A INPUT -p tcp --dport 22 -j ACCEPT
```

Запретить все остальные входящие соединения

```
-A INPUT -j DROP
COMMIT
```

Сохраните файл и закройте редактор. Теперь необходимо применить созданные правила брандмауэра:

```
sudo iptables-restore < /etc/iptables.rules
```

Для автоматического применения правил при загрузке системы, добавьте следующую команду в файл /etc/rc.local перед строкой exit 0:

```
iptables-restore < /etc/iptables.rules
```

Настройка брандмауэра в ALT Linux завершена.