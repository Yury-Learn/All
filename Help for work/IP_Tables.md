#iptables #debian #linux 

 - Вот пример простейшего набора правил для веб сервера, где запрещено всё, что не разрешено явно (22,80,443 порты). Показываю для понимания принципа. 
 - ### default rules
```
iptables -P INPUT DROP
iptables -P INPUT DROP
iptables -P FORWARD DROP
```
### allow localhost
```
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
```
### allow established
```
iptables -A INPUT -p all -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -p all -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -p all -m state --state ESTABLISHED,RELATED -j ACCEPT
```
### allow ping
```
iptables -A INPUT -p icmp --icmp-type echo-reply -j ACCEPT
iptables -A INPUT -p icmp --icmp-type destination-unreachable -j ACCEPT
iptables -A INPUT -p icmp --icmp-type time-exceeded -j ACCEPT
iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT
```
### allow server connections
`iptables -A OUTPUT -o ens3 -j ACCEPT`
### allow ssh, www
```
iptables -A INPUT -i ens3 -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -i ens3 -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -i ens3 -p tcp --dport 443 -j ACCEPT
```
### logging
```
iptables -N block_in
iptables -N block_out
iptables -N block_fw
iptables -A INPUT -j block_in
iptables -A OUTPUT -j block_out
iptables -A FORWARD -j block_fw
iptables -A block_in -j LOG --log-level info --log-prefix "-IN-BLOCK-"
iptables -A block_in -j DROP
iptables -A block_out -j LOG --log-level info --log-prefix "-OUT-BLOCK-"
iptables -A block_out -j DROP
iptables -A block_fw -j LOG --log-level info --log-prefix "-FW-BLOCK-"
iptables -A block_fw -j DROP
```
- С такими правилами в лог будут попадать все заблокированные соединения во всех трех цепочках. В обычной работе это не нужно. Но если набор правил большой, бывает, что добавляете куда-то новое правило, а пакеты по какой-то причине не ходят. Такое бывает нередко, особенно когда между различных VPN  туннелей приходится трафиком управлять. Добавляете правила для логирования из этого примера и смотрите, нет ли ваших пакетов в списке заблокированных. Префиксы для разных цепочек помогают быстро грепать разные цепочки. Если находите заблокированные пакеты, разбираетесь, почему они там оказались. Вносите исправление в правила. Когда всё закончите, правила с логированием удаляете, чтобы не собирать ненужные логи.
### Make sure not to drop established connections.
`iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT`
### Allow SSH.
`iptables -A INPUT -p tcp -m state --state NEW --dport 22 -j ACCEPT`
###  Allow PostgreSQL.
`iptables -A INPUT -p tcp -m state --state NEW --dport 5432 -j ACCEPT`
### Allow all outbound, drop everything else inbound.
```
iptables -A OUTPUT -j ACCEPT
iptables -A INPUT -j DROP
iptables -A FORWARD -j DROP
```
### Only allow access to PostgreSQL port from the local subnet.
`iptables -A INPUT -p tcp -m state --state NEW --dport 5432 -s 192.168.1.0/24 -j ACCEPT`

---

### ДОБАВЛЕНИЕ НОВЫХ ПРАВИЛ
-  Чтобы добавить новое правило, используйте команду iptables -A. Например, чтобы заблокировать весь входящий трафик от IP-адреса 192.168.0.100, вы можете использовать следующую команду:
`iptables -A INPUT -s 192.168.0.100 -j DROP` 
- вставить новое правило в строку *5* с протоколом tcp порт 10051
`iptables -I INPUT 5 -p tcp --dport 10051 -j ACCEPT`


В этой команде -A INPUT добавляет новое правило в цепочку INPUT, -s 192.168.0.100 определяет исходный IP-адрес, а -j DROP указывает, что все пакеты, соответствующие этому правилу, должны быть отброшены.
### УДАЛЕНИЕ ПРАВИЛ
-  Чтобы удалить правило, вам нужно знать его номер в цепочке. Вы можете узнать номера правил, используя команду iptables -L --line-numbers. Затем вы можете удалить правило, используя команду iptables -D и номер правила. Например, чтобы удалить первое правило в цепочке INPUT, вы можете использовать следующую команду:-->
```
iptables -L --line-numbers
iptables -D INPUT 1 
```
---
### ИЗМЕНЕНИЕ ДЕФОЛТНОГО ПОЛИТИКИ
-  Вы можете изменить дефолтную политику для цепочки, используя команду iptables -P. Например, чтобы отклонить все входящие пакеты по умолчанию, вы можете использовать следующую команду:
`iptables -P INPUT DROP` 
---
### СОХРАНЕНИЕ И ВОССТАНОВЛЕНИЕ ПРАВИЛ
-  По умолчанию, правила iptables не сохраняются после перезагрузки системы. Чтобы сохранить текущие правила, вы можете использовать команду iptables-save. Это выведет текущие правила в формате, который можно использовать для восстановления с помощью команды iptables-restore. 
`iptables-save > /path/to/iptables/rules` 

- Затем, чтобы восстановить правила, вы можете использовать следующую команду:
`iptables-restore < /path/to/iptables/rules` 
### Сохраняем установленные правила брандмауэра iptables
- Запомните, что любые изменения, вносимые с помощью команды iptables исчезнут после перезагрузки сервера, если их не сохранить. 😉
Первым делом надо установить сохранялку: 
`apt install netfilter-persistent iptables-persistent`
далее после добавления правил — сохраним их в наш межсетевой экран
`netfilter-persistent save`

---

**1. Примеры использования Iptables**
 - **Блокировка IP-адреса**
Чтобы заблокировать весь трафик от определенного IP-адреса, вы можете использовать следующую команду:
`iptables -A INPUT -s 192.168.0.100 -j DROP` 
- **Открытие порта для входящего трафика**
Чтобы открыть порт для входящего трафика, вы можете использовать следующую команду: 
`iptables -A INPUT -p tcp --dport 80 -j ACCEPT` 
 В этой команде -p tcp указывает на протокол (в данном случае TCP), --dport 80 указывает на порт (в данном случае 80), а -j ACCEPT указывает, что все пакеты, соответствующие этому правилу, должны быть приняты.
- **Настройка простого межсетевого экрана**
Вы можете использовать iptables для настройки простого межсетевого экрана. Например, вы можете разрешить весь исходящий трафик, разрешить входящий трафик только на определенные порты и отклонить все остальные входящие пакеты.-->
```
iptables -A OUTPUT -j ACCEPT iptables -A INPUT -p tcp --dport 22 -j ACCEPT iptables -A INPUT -p tcp --dport 80 -j ACCEPT iptables -A INPUT -p tcp --dport 443 -j ACCEPT iptables -P INPUT DROP 
```
В этом примере разрешен весь исходящий трафик, а входящий трафик разрешен только на порты 22 (SSH), 80 (HTTP) и 443 (HTTPS). Все остальные входящие пакеты отклоняются. 
####  Тут пожалуй стоит ещё добавить что сами правила могут быть добавлены двумя способами 
`sudo iptables -A ...`
-A сокращение от Append и означает что правило будет добавлено последовательно в самый низ после всех остальных правил.
Либо 
`sudo iptables -I ...`
-I сокращение от Insert и означает что правило будет добавлено в самый верх перед всеми остальными правилами.
Почему это так важно? Дело в том что принцип по которому работает Iptables - first match win. Что означает что фаервол будет идти последовательно по всем правилам сверху - вниз, до тех пор пока не найдёт совпадение. Поэтому лучше ставьте более важные правила выше.
Также следуйте правилу: generic правила, те в которых нет явного уточнения, например 
*sudo iptables -A INPUT -i lo -j ACCEPT* следует помещать ниже статичных правил. Статичные правила отличаются тем что там явно прописан ip либо порт.
#### Удаляем правила из iptables
- Самый простой вариант удалить правила по номеру. Для этого сначала отображаем все правила вместе с их порядковым номером 
`sudo iptables -L -n --line-numbers`
 - Находим номер правила которое хотим удалить. Номер находится в самом первом столбце. И удаляем это правило при помощи такой логики 
*sudo iptables [-t таблица] -D цепочка номер_правила*
Например
`sudo iptables -t filter -D INPUT 2`
Удалит правило №2 в таблице filter цепочки INPUT 

- Альтернативный способ удаления правил - по действию. Грубо говоря надо ввести кусок того что делает правило. Логика тут такая
*sudo iptables [-t таблица] -D цепочка спецификации_правила*
К спецификациям правила может относится IP адрес отправителя либо другие параметры правила, которые явно его определяют (порт, IP адрес назначения, протокол и др.) и выполняемое действие, например, -j ACCEPT.
Например
`sudo iptables -t filter -D INPUT -s 192.168.10.0/24 -j ACCEPT`
#### Очистка счётчиков цепочек

- Если вы хотите обнулять не сами правила iptables, а только их счётчики то это делается очень просто. Чтобы очистить счетчики для всех цепочек и правил, используйте опцию -Z отдельно: 
`sudo iptables --zero`
 - Чтобы очистить счетчики для всех правил конкретной цепочки, используйте опцию -Z и укажите название цепочки: -->
sudo iptables --zero INPUT
- Если вы хотите очистить счетчики для конкретного правила, укажите имя цепочки и номер правила. Например, для обнуления счетчиков первого правила в цепочке INPUT:
`sudo iptables --zero INPUT 1`

#### Сохранение и загрузка правил iptables
Ещё раз посмотрим наши правила с помощью
```
sudo iptables -L -v
iptables basic block added rules
```

На данный момент правила живут до того как мы не перезагрузим сервер 
-  Первым делом создаём специальную директорию
```sh
sudo mkdir -p /scripts/iptables
```

- Делаем текущего юзера (желательно не root) владельцем этой директории
```sh
sudo chown -R $USER:$USER /scripts/iptables
```

- Сохраняем все наши правила в эту директорию -->
```sh
sudo iptables-save > /scripts/iptables/iptables-rules
```

- Теперь же мы хотим чтобы все правила грузились при старте системы, поэтому создадим специальный скрипт 
```sh
sudo nano /etc/network/if-pre-up.d/iptables
```

- С таким содержанием
```
#!/bin/sh
iptables-restore < /scripts/iptables/iptables-rules
exit 0
```
и обязательно делаем этот скрипт исполняемым 
`chmod +x /etc/network/if-pre-up.d/iptables`
Теперь после перезагрузки все наши правила останутся. 