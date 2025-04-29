---
sticker: emoji//2620-fe0f
tags:
  - bash
  - linux
  - mdadm
  - raid
---
1. После обновления системы на одном сервере, в процессе последующей перезагрузки, система не поднялась с сообщением вида:  

>mdadm: Devices UUID-<very long number> and UUID-<another number> have the same name: md1
>mdadm: Duplicate MD device names in conf file were found.

Система не грузится, а через некоторое время BusyBox выводит приглашение:  

> (initramfs)

Один из симптомов заключается в том, что следующая команда не выдаёт ничего:  

`mdadm --detail --scan`

Причина была в том, что в файле */etc/mdadm/mdadm.conf* имеются устаревшие данные о дисковых разделах.  
  
2. С помощью следующей команды убедился, что новые данные определяются.  

`mdadm --examine --scan`

Записал обновлённые данные по разделам в конфиг mdadm:  

`mdadm --examine --scan > /etc/mdadm/mdadm.conf`

Запустил сборку массивов:  

`mdadm --assemble --scan`

Массивы обнаружились и собрались.  
  
Ввёл команду для выхода из BusyBox (initramfs) и дальнейшей загрузки системы:  

`exit`

3. Залогинился в загрузившейся системе обновил файл */etc/mdadm/mdadm.conf* в образе initramfs:  

```
 mdadm --examine --scan > /etc/mdadm/mdadm.conf
 update-initramfs -u
```

И отправил систему на перезагрузку. Система загрузилась нормально.  
  
4. Если из системы вынимался один из дисков, то отсутствующую половину зеркала можно добавить командами вида:  
```
mdadm --manage  /dev/md1 --add /dev/sda1
mdadm --manage /dev/md3 --add /dev/sda3
```

За процессом пересборки зеркала можно наблюдать в */proc/mdstat*.