---
"": " "
"#linux": disk
tags: linux, disk, add
---
#   Небольшая шпаргалка по Parted

• August 12 at 22:46

Посмотреть перечень подключенных блочных устройств можно вот так:

```
sudo ljblk
[root@tst05 roman]# sudo lsblk
NAME        MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sda           8:0    0   40G  0 disk 
├─sda1        8:1    0    1G  0 part /boot
└─sda2        8:2    0   39G  0 part 
  ├─rl-root 253:0    0 35.1G  0 lvm  /
  └─rl-swap 253:1    0  3.9G  0 lvm  [SWAP]
sdb           8:16   0   10G  0 disk 
sdc           8:32   0   20G  0 disk 
sdd           8:48   0   30G  0 disk 
sr0          11:0    1  1.6G  0 rom  
[root@tst05 roman]# 
```

[

](http://desktop-app-resource/photo/5896392453165004313/5109934589472226122)

Как видно из вывода выше к своей тестовому серверу я подключил три дополнительных диска. Вот с ними и будем экспериментировать.

Перед выполнением любых операций с разделами убедитесь, что диск не используется операционной системой или приложением. Для работы с системным диском используйте любой Live дистрибутив.

### Создание нового раздела через parted

Самых ходовые сценарии в моей практики – это либо создание одного раздела, которые занимает весь диск, либо создание нескольких разделов на диске.

В примерах создания разделов используются новые неинициализированные диски.

#### Создание раздела на весь диск

Пример реализации такого сценария:

1. Открывает на редактирование таблицу разделов на нужном нам диске:

```
sudo parted /dev/sdb
```

2. Инициализируем диск с таблицей разделов GPT (можно создать MBR таблицу указав метку msdos):

```
mklabel gpt
```

3. Создаем раздел, который займет весь объем диска:

```
mkpart primary 1m 100%
```

4. Проверяем результат:

```
p
(parted) p                                                                
Model: QEMU QEMU HARDDISK (scsi)
Disk /dev/sdb: 10.7GB
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Disk Flags: 

Number  Start   End     Size    File system  Name     Flags
 1      1049kB  10.7GB  10.7GB               primary

(parted)
```

[

](http://desktop-app-resource/photo/5896715237137167910/5109934589472226122)

5. Последним шагом выполним проверку раздела на выравнивание:

```
align-check optimal 1
(parted) align-check optimal 1                                           
1 aligned
(parted)
```

[

](http://desktop-app-resource/photo/5896680748549780815/5109934589472226122)

6. Завершаем работу с утилитой parted:

```
q
```

Создание раздела завершено.

#### Создание нескольких разделов на диске

Немного расширим пример выше. Создадим два раздела на диске. Размер первого раздела 5 ГБ. Размер второго раздела 15 ГБ.

1. Открывает на редактирование таблицу разделов на нужном нам диске:

```
sudo parted /dev/sdc
```

2. Инициализируем диск с таблицей разделов GPT (можно создать MBR таблицу указав метку msdos):

```
mklabel gpt
```

3. Создаем первый раздел объемом 5 ГБ:

```
mkpart primary 1m 5G
```

4. Создаем второй раздел объемом 15 ГБ:

```
mkpart primary 5G 15G
```

4. Проверяем результат:

```
p
(parted) p                                                                
Model: QEMU QEMU HARDDISK (scsi)
Disk /dev/sdc: 21.5GB
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Disk Flags: 

Number  Start   End     Size    File system  Name     Flags
 1      1049kB  5000MB  4999MB               primary
 2      5000MB  20.0GB  15.0GB               primary

(parted) 
```



5. Последним шагом выполним проверку первого раздела на выравнивание:

```
align-check optimal 1
(parted) align-check optimal 1                                           
1 aligned
(parted)
```



6. Проверяем второй раздел на выравнивание:

```
align-check optimal 2
(parted) align-check optimal 2                                           
2 aligned
(parted)
```


7. Завершаем работу с утилитой parted:

```
q
```

Создание разделов завершено.

### Расширение раздела через parted

Остался последний – заключительный пример. И он на моей практике используется даже чаще, чем примеры выше вместе взятый. Это расширение раздела. Например, ваше приложение или сервер баз данных заполнили весь объем дискового пространства. Средствами гипервизора диск расширили, но теперь нужно скорректировать таблицу разделов. Вполне жизненная ситуация.

Приступим

1. Открывает на редактирование таблицу разделов на нужном нам диске:

```
sudo parted /dev/sdd
```

2. Проверим – какие разделы уже есть на диске:

```
p
(parted) p
Model: QEMU QEMU HARDDISK (scsi)
Disk /dev/sdd: 32.2GB
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Disk Flags: 

Number  Start   End     Size    File system  Name     Flags
 1      1049kB  5000MB  4999MB               primary

(parted) 
```



3. Как видно из вывода выше, на диске создан один раздел размером в 5ГБ. Хотя размер диска теперь составляет 32,2 ГБ. Расширим наш раздел:

```
resizepart 1 100%
```

4. Проверяем результат:

```
p
(parted) p                                                                
Model: QEMU QEMU HARDDISK (scsi)
Disk /dev/sdd: 32.2GB
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Disk Flags: 

Number  Start   End     Size    File system  Name     Flags
 1      1049kB  32.2GB  32.2GB               primary

(parted)
```



5. Последним шагом выполним проверку раздела на выравнивание:

```
align-check optimal 1
(parted) align-check optimal 1                                           
1 aligned
(parted)
```


6. Завершаем работу с утилитой parted:

```
q
```

Расширение раздела завершено.

