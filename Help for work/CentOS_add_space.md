`Отключаем swap, если инструкция не сработала. После отключения swap нужно перезагрузить сервер, тогда место добавиться в нужную директорию`

### Это очень важный пункт. Обязательно проверьте вот что: дело в том, что диск разделенный на 4 раздела более не сможет быть расширен. Проверить это легко. Подключаемся к серверу CentOS и вводим команду fdisk -l:
	У вас пока только два раздела - /dev/sda1 и /dev/sda2. Можно создать еще два.
### Создаем новую партицию 
	fdisk /dev/sda
	Command (m for help): n
			жмем ключ "p"

### На следующем экране задаем номер для партиции. Так как у нас уже есть партиции /dev/sda1 и /dev/sda2, то следуя порядковому номеру, мы указываем цифру 3
	Partition number (1-4): 3
### В следующем пункте, мы рекомендуем нажать Enter дважды, то есть принять предложенные по умолчанию значения:
	First cylinder (392-1305, default 392): 
	Using default value 392
	Last cylinder or +size or +sizeM or +sizeK (392-1305, default 1305): 
	Using default value 1305
### Отлично. Теперь мы меняем типа нашего раздела. Для этого, в следующем меню нажимаем ключ t, указываем номер партиции, который только что создали (напомним, это был номер 3), 3, а в качестве Hex code укажем 8e, а дальше просто Enter:
	Command (m for help): t
	Partition number (1-4): 3
	Hex code (type L to list codes): 8e
	Changed system type of partition 3 to 8e (Linux LVM)
### Готово. Мы вернулись в основное меню утилиты fidsk. Сейчас ваша задача указать ключ w и нажать Etner, чтобы сохранить опции партиций на диске:
	Command (m for help): w
### После, что самое важное этого метода - перезагружать ничего не нужно! Нам просто нужно заново сканировать партиции утилитой partprobe:
	partprobe -s
### Если команда выше не работает, то попробует сделать с помощью partx:
	partx -v -a /dev/sda
### И если уже после этого у вас не появляется новая партиция - увы, вам придется согласовать время перезагрузки сервера и перезагрузить его. Успешным результатом этого шага будет вот такой вывод команды fdisk, где мы видим новую партицию:
	fdisk -l


### Расширяем логический раздел LV с новой партиции
Теперь наша задача следующая: создаем физический том (PV) из новой партиции, расширяем группу томов (VG) из под нового объема PV, а затем уже расширяем логический раздел LV. Звучит сложно, но поверьте, это легко!

Итак, по шагам: создаем новый физический том (PV). Важно: у вас может быть не /dev/sda3, а другая, 4, например, или вообще /dev/sdb3! Не забудьте заменять в командах разделы, согласно вашей инсталляции.
	# pvcreate /dev/sda3
	Physical volume "/dev/sda3" successfully created

### Отлично. Теперь находим группу томов (VG, Volume Group). А точнее, ее название. Делается это командой vgdisplay:
	# vgdisplay
	--- Volume group ---
	VG Name               MerionVGroup00 
	...

### Найдено. Наша VG называется MerionVGroup00. Теперь мы ее расширим из пространства ранее созданного PV командой vgextend:
	# vgextend MerionVGroup00 /dev/sda3
	Volume group "MerionVGroup00" successfully extended

### Теперь расширяем LV из VG. Найдем название нашей LV, введя команду lvs:
	#  lvs
  	LV      VG        Attr       LSize
  	MerionLVol00    MerionVGroup00 

### MerionLVol00 - найдено.Расширяем эту LV, указывая до нее путь командой lvextend /dev/MerionVGroup00/MerionLVol00 /dev/sda3:
	# lvextend /dev/MerionVGroup00/MerionLVol00 (в нашем примере было /dev/mapper/cl-root) /dev/sda3 
	Extending logical volume MerionLVol00 to 9.38 GB
	Logical volume MerionLVol00 successfully resized

### Почти у финиша. Единственное, что осталось, это изменить размер файловой системы в VG, чтобы мы могли использовать новое пространство. Используем команду resize2fs:
	# resize2fs /dev/MerionVGroup00/MerionLVol00 (в нашем примере было /dev/mapper/cl-root)
	resize2fs 1.39 (29-May-2006)
	Filesystem at /dev/MerionVGroup00/MerionLVol00 is mounted on /; on-line resizing required
	Performing an on-line resize of /dev/MerionVGroup00/MerionLVol00 to 2457600 (4k) blocks.
	The filesystem on /dev/MerionVGroup00/MerionLVol00 is now 2457600 blocks long.

	Готово. Проверяет доступное место командой df -h. Enjoy!

### Получаете ошибку в resize2fs: Couldn't find valid filesystem superblock
Если вы получили ошибку вида:

$ resize2fs /dev/MerionVGroup00/MerionLVol00
resize2fs 1.42.9 (28-Dec-2013)
resize2fs: Bad magic number in super-block while trying to open /dev/MerionVGroup00/MerionLVol00
Couldn't find valid filesystem superblock.
Это значит, что у вас используется файловая система формата XFS, вместо ext2/ext3. Чтобы решить эту ошибку, дайте команду xfs_growfs:

$  xfs_growfs /dev/MerionVGroup00/MerionLVol00
meta-data=/dev/MerionVGroup00/MerionLVol00 isize=256    agcount=4, agsize=1210880 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=0
data     =                       bsize=4096   blocks=4843520, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=0
log      =internal               bsize=4096   blocks=2560, version=2
         =                       sectsz=512   sunit=0 blks, lazy-coun
realtime =none                   extsz=4096   blocks=0, rtextents=0



### Как отключить Swap (своп) в Linux
 Чтобы проверить настройки подкачки в вашей системе, выполните следующую команду. 
 #free -mh 
 Для определения раздела подкачки выполните следующую команду.
 #blkid

 Для поиска раздела подкачки воспользуйтесь следующей командой.
 #lsblk

 Деактивируйте область подкачки, указанную выше, с помощью следующей команды.
 #swapoff /dev/mapper/cl-swap

 Вы также можете полностью отключить все области подкачки, используя следующую команду.
 swapoff -a

 Теперь выполните следующую команду, чтобы проверить, отключен ли своп.
 #free -mh

 Чтобы навсегда отключить подкачку, вам требуется удалить строку «swap» из файла /etc/fstab. Вот как это можно сделать.
 Комментируем строку с помощью "#" /dev/mapper/cl-swap none swap defaults 0 0 

 Далее осталось перезагрузить систему с помощью следующей команды.
 reboot

 После перезагрузки выполните команду, чтобы применить новые настройки.
 mount -a