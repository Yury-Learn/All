 • April 5 at 10:35

Утилита **hping3** — это сетевой инструмент, способный отправлять пакеты TCP/IP и отображать целевые ответы, как это делает программа ping с ICMP.

Эта утилита умеет обрабатывать фрагментацию, отправлять пакеты с произвольными данными и флагами, менять размеры пакетов, и даже может использоваться для передачи файлов. С помощью этой утилиты вы можете выполнять, например, следующие действия:

- проверять правила брандмауэра;
- сканировать порты хоста в сети;
- тестировать производительность сети с использованием различных протоколов;
- передавать файлы в обход брандмауэра;
- выполнять трассировку по определённым портам;
- использовать для изучения TCI/IP.

Утилита устанавливается из стандартных репозиториев:

```
# apt install hping3
```

### Обычный ping

Выполнить обычный **icmp ping** можно с помощью опции **--icmp**. Дополнительно можем указать количество отправляемых пакетов с момощью опции **-c** <число>, без этой опции пинг будет бесконечным. Также можем указать размер данных в пакете с помощью опции **-d** <число байт>

```
$ sudo hping3 -c 4 -d 100 --icmp 192.168.0.35
HPING 192.168.0.35 (ens18 192.168.0.35): icmp mode set, 28 headers + 100 data bytes
len=128 ip=192.168.0.35 ttl=64 id=37431 icmp_seq=0 rtt=3.9 ms
len=128 ip=192.168.0.35 ttl=64 id=37468 icmp_seq=1 rtt=3.8 ms
len=128 ip=192.168.0.35 ttl=64 id=37559 icmp_seq=2 rtt=3.8 ms
len=128 ip=192.168.0.35 ttl=64 id=37662 icmp_seq=3 rtt=3.7 ms

--- 192.168.0.35 hping statistic ---
4 packets transmitted, 4 packets received, 0% packet loss
round-trip min/avg/max = 3.7/3.8/3.9 ms
```

В примере выше мы отправляет 4 пакета icmp с заголовками в 28 байт и 100 байт данных.

### Ping TCP порта

Пропинговать TCP/IP порт можно пакетами с флагом **syn**, это делается опцией **--syn**, который нужно указать вместо **--icmp**.

Дополнительно мы можем указать порт назначения с помощью опции **-p** <номер порта>. И ещё можем использовать опцию **-V**, чтобы получать больше информации:

```
$ sudo hping3 -V -c 4 -d 200 -p 22 --syn 192.168.0.35
using ens18, addr: 192.168.0.27, MTU: 1500
HPING 192.168.0.35 (ens18 192.168.0.35): S set, 40 headers + 200 data bytes
len=44 ip=192.168.0.35 ttl=64 DF id=0 tos=0 iplen=44
sport=22 flags=SA seq=0 win=64240 rtt=7.9 ms
seq=1637605271 ack=613658406 sum=637a urp=0

len=44 ip=192.168.0.35 ttl=64 DF id=0 tos=0 iplen=44
sport=22 flags=SA seq=1 win=64240 rtt=7.8 ms
seq=1068505220 ack=1772243286 sum=9602 urp=0

len=44 ip=192.168.0.35 ttl=64 DF id=0 tos=0 iplen=44
sport=22 flags=SA seq=2 win=64240 rtt=7.8 ms
seq=2426710448 ack=798929700 sum=9602 urp=0

len=44 ip=192.168.0.35 ttl=64 DF id=0 tos=0 iplen=44
sport=22 flags=SA seq=3 win=64240 rtt=7.7 ms
seq=4126088940 ack=274957911 sum=9602 urp=0


--- 192.168.0.35 hping statistic ---
4 packets transmitted, 4 packets received, 0% packet loss
round-trip min/avg/max = 7.7/7.8/7.9 ms
```

Здесь мы отправляем пакеты с флагом **S**, размер заголовка пакетов равен 40 байтам, а размер данных 200 байтам.

Среднее время за которое пакет был отправлен и вернулся ответ = 7.8 ms.

### Сканирование портов

Мы можем просканировать порты с помощью опции **--scan**, затем нужно указать диапазон портов или служебное слово known (все общеизвестные порты). Дополнительно нужно указать какими пакетами выполнять сканирование, начинать исследование лучше с **--syn**.

```
$ sudo hping3 --scan known --syn 192.168.0.35
Scanning 192.168.0.35 (192.168.0.35), port known
264 ports to scan, use -V to see all the replies
+----+-----------+---------+---+-----+-----+-----+
|port| serv name |  flags  |ttl| id  | win | len |
+----+-----------+---------+---+-----+-----+-----+
   22 ssh        : .S..A...  64     0 64240    44
   80 http       : .S..A...  64     0 64240    44
```

Из вывода видно что на хосте 192.168.0.35 прослушиваются следующие порты: 22 (ssh) и 80 (http).

### Трасировка пакетов

Для того чтоб ывыполнить трассировку до определённого сетевого хоста нужно воспользоваться опцией **--traceroute**. Дополнительно вы можете указать протокол, с помощью которого вы хотите выполнять трассировку,

- это может быть icmp, тогда указываем **--icmp**;
- или TCP/IP порт, тогда указываем **--syn -p** <номер порта>

Пример для **icmp**:

```
$ sudo hping3 --traceroute --icmp 1.1.1.1
HPING 1.1.1.1 (ens18 1.1.1.1): icmp mode set, 28 headers + 0 data bytes
hop=1 TTL 0 during transit from ip=182.168.0.10 name=_gateway
hop=1 hoprtt=3.9 ms
hop=2 TTL 0 during transit from ip=91.205.125.93 name=UNKNOWN
hop=2 hoprtt=3.9 ms
hop=3 TTL 0 during transit from ip=217.150.52.254 name=vrz02.vrz25.transtelecom.net
hop=3 hoprtt=3.8 ms
hop=4 TTL 0 during transit from ip=217.150.55.234 name=mskn15-Lo1.transtelecom.net
hop=4 hoprtt=11.8 ms
hop=5 TTL 0 during transit from ip=188.43.3.65 name=Cloudflare-msk-gw.transtelecom.net
hop=5 hoprtt=15.7 ms
len=28 ip=1.1.1.1 ttl=59 id=42837 icmp_seq=5 rtt=15.7 ms
len=28 ip=1.1.1.1 ttl=59 id=62159 icmp_seq=6 rtt=15.6 ms
len=28 ip=1.1.1.1 ttl=59 id=22257 icmp_seq=7 rtt=15.5 ms
--- 1.1.1.1 hping statistic ---
9 packets transmitted, 9 packets received, 0% packet loss
round-trip min/avg/max = 3.8/11.3/15.7 ms
```

Пример для **TCP**:

```
$ sudo hping3 --traceroute --syn -p 53 1.1.1.1
HPING 1.1.1.1 (ens18 1.1.1.1): S set, 40 headers + 0 data bytes
hop=1 TTL 0 during transit from ip=192.168.0.10 name=_gateway
hop=1 hoprtt=3.9 ms
hop=2 TTL 0 during transit from ip=91.205.125.93 name=UNKNOWN
hop=2 hoprtt=3.8 ms
hop=3 TTL 0 during transit from ip=217.150.52.254 name=vrz02.vrz25.transtelecom.net
hop=3 hoprtt=3.8 ms
hop=4 TTL 0 during transit from ip=217.150.55.234 name=mskn15-Lo1.transtelecom.net
hop=4 hoprtt=19.7 ms
hop=5 TTL 0 during transit from ip=188.43.3.65 name=Cloudflare-msk-gw.transtelecom.net
hop=5 hoprtt=19.7 ms
len=44 ip=1.1.1.1 ttl=59 DF id=0 sport=53 flags=SA seq=5 win=64240 rtt=11.6 ms
len=44 ip=1.1.1.1 ttl=59 DF id=0 sport=53 flags=SA seq=6 win=64240 rtt=11.6 ms
DUP! len=44 ip=1.1.1.1 ttl=59 DF id=0 sport=53 flags=SA seq=5 win=64240 rtt=1067.6 ms
len=44 ip=1.1.1.1 ttl=59 DF id=0 sport=53 flags=SA seq=7 win=64240 rtt=11.5 ms
DUP! len=44 ip=1.1.1.1 ttl=59 DF id=0 sport=53 flags=SA seq=6 win=64240 rtt=1075.6 ms
--- 1.1.1.1 hping statistic ---
9 packets transmitted, 12 packets received, -33% packet loss
round-trip min/avg/max = 3.8/273.0/1075.6 ms
```

### Передача текстового файла по ICMP

Передать текстовый файл по ICMP можно таким образом, на первом хосте запускаете ping. Указываете размер данных пакета (-d 200), чтобы туда влез файл, хотя если не влезет, то просто разделится на несколько пакетов. Подписываете файл с помощью секретной фразы (--sign <фраза>). И указываете, какой файл отправлять (--file /root/test.txt). Если файл влезает в 1 пакет, то можем добавить опцию -с 1.

На принимающей стороне нужно запустить **hping3** в режиме прослушивания с помощью опции --listen. Дополнительно нужно указать интерфейс с помощью опции-I <интерфейс>, и секретную фразу. Запускаем на принимающей стороне:

```
$ sudo hping3 -I eth0 --listen secret --icmp
```

Запускаем на передающей стороне :

```
$ sudo hping3 --icmp -c 1 -d 200 --sign secret --file /home/alex/test.txt 192.168.0.35
HPING 192.168.0.35 (ens18 192.168.0.35): icmp mode set, 28 headers + 200 data bytes
[main] memlockall(): No such file or directory
Warning: can't disable memory paging!
len=228 ip=192.168.0.35 ttl=64 id=23726 icmp_seq=0 rtt=3.9 ms

--- 192.168.0.35 hping statistic ---
1 packets transmitted, 1 packets received, 0% packet loss
round-trip min/avg/max = 3.9/3.9/3.9 ms
```

На принимающей стороне видим текст из файла.