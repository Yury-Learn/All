#linux #bash

# Состояние дисков
`df -h` -h human readable
du -sh /tmp количество места занимаемое файлами в /tmp
df -i  inodes
lsblk блочные устройства

apt install smartmontools
smartctl -a /dev/sda инфо о диске
cat /proc/mdstat RAID
# Процессы

iostat
iotop какие процессы пишут читают 
top us - user режим sy -system idle простой wa ввод/ввывод
htop
vmstat - memory
free -m
cat /proc/meminfo

ps aux -процессы снапшот
# Сеть

netstat -tulpn сокеты
ss -lntu

ip a  настройки интерфейсов
ifconfig

netstat -rn -маршрутизация
ip r

nslookup
dig @8.8.8.8 ya.ru исрользуем dns сервер гугла
dig -t mx ya.ru запрос mx-записи ya.ru

curl -v telnet://127.0.0.1:22 проверка порта через telnet
tcpdump -i any port 9100 -nn проверка пакетов
# Логи
tail -f -n50 /var/log/syslog -f d прямом эфире -n50 последние 50 строчек
/var/log/auth.log вход в систему
/var/log/kernel.log -ядро
dmesg -T

journalctl -xeu nginx