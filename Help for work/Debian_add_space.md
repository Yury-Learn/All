### Если в конце ошибка (resize2fs: Read-only file system While checking for on-line resizing support)
то делаем след шаг --->>> #sudo mount -vo remount,rw /    или #sudo mount -o remount,rw /

Для начала проверим версию:

$ cat /etc/debian_version
11.1
В дальнейшем нам потребуется выполнять действия от пользователя root, подключимся под этим пользователем:

### su -
Password:
Теперь посмотрим размер файловой системы, выполнив df -h

### df -h
Filesystem      Size  Used Avail Use% Mounted on
udev            944M     0  944M   0% /dev
tmpfs           192M  500K  192M   1% /run
/dev/sda1        19G  990M   17G   6% /
tmpfs           960M     0  960M   0% /dev/shm
tmpfs           5.0M     0  5.0M   0% /run/lock
tmpfs           192M     0  192M   0% /run/user/1000
Наш системный раздел /dev/sda1 смонтированный в / имеет размер 19 Гб.

Посмотрим вывод fdisk -l:

### fdisk -l

Disk /dev/sda: 20 GiB, 21474836480 bytes, 41943040 sectors
Disk model: Virtual Disk
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 4096 bytes
I/O size (minimum/optimal): 4096 bytes / 4096 bytes
Disklabel type: dos
Disk identifier: 0x73000288

Device     Boot    Start      End  Sectors  Size Id Type
/dev/sda1  *        2048 39942143 39940096   19G 83 Linux
/dev/sda2       39944190 41940991  1996802  975M  5 Extended
/dev/sda5       39944192 41940991  1996800  975M 82 Linux swap / Solaris
В данном примере у нас 1 диск /dev/sda размером 20 гигабайт, который разбит на 3: /dev/sda1, /dev/sda2 и /dev/sda5. Как помните, нас интересует диск /dev/sda1 с типом Linux.

Увеличение размера диска
В среде виртуализации увеличиваем размер жесткого диска нашей виртуальной машины. Если ваша среда виртуализации позволяет это сделать без выключения машины, то измените размер диска и выполните:

### echo 1 > /sys/block/sda/device/rescan
Если нет возможности увеличить диск без выключения виртуальной машины, то выключаем и меняем размер. Я увеличил диск до 25 гигабайт, запускаем машину и проверяем:

### fdisk -l

Disk /dev/sda: 25 GiB, 26843545600 bytes, 52428800 sectors
Disk model: Virtual Disk
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 4096 bytes
I/O size (minimum/optimal): 4096 bytes / 4096 bytes
Disklabel type: dos
Disk identifier: 0x73000288

Device     Boot    Start      End  Sectors  Size Id Type
/dev/sda1  *        2048 39942143 39940096   19G 83 Linux
/dev/sda2       39944190 41940991  1996802  975M  5 Extended
/dev/sda5       39944192 41940991  1996800  975M 82 Linux swap / Solaris

Внимание! Перед тем, как приступить к дальнейшим работам по расширению системного раздела, обязательно сделайте резервную копию данных!

После увеличения размера диска необходимо увеличить сам раздел. Я специально установил Debian с разбивкой на разделы как предлагал установщик, имея ввиду, что многие так и поступят. И что мы видим? Что мы не сможем просто так расширить раздел /dev/sda1, т.к. сразу за ним следует sda5. Поэтому сначала потребуется передвинуть его в конец диска (где как раз и находятся добавленные сектора), а уже потом расширить сам sda1. Но если у вас в выводе fdisk только один раздел или он находится в конце диска (смотрите по конечным секторам) – можете сразу перейти к пункту Debian 11 увеличение раздела диска.

Перенос раздела с подкачкой в конец диска
Тут сразу необходим оговориться, что мы будем переносить раздел с swap (подкачкой), поэтому его можно будет просто удалить и создать новый. Если же требуется двигать разделы с данными, то это другая задача, её проще решать с помощью GParted на Live CD и в данной статье мы её рассматривать не будем.

Для начала отключаем подкачку:

### swapoff -a
Запускам fdisk с указанием нашего диска (/dev/sda):

### fdisk /dev/sda

Welcome to fdisk (util-linux 2.36.1).
Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.
Сделаем ремарку, что все изменения в fdisk нужно делать осторожно, с пониманием. Но знайет, что пока вы не сохраните изменения (w) всегда можно выйти без каких либо последствий.

Вводим p, чтобы посмотреть на список разделов:

Command (m for help): p
Disk /dev/sda: 25 GiB, 26843545600 bytes, 52428800 sectors
Disk model: Virtual Disk
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 4096 bytes
I/O size (minimum/optimal): 4096 bytes / 4096 bytes
Disklabel type: dos
Disk identifier: 0x73000288

Device     Boot    Start      End  Sectors  Size Id Type
/dev/sda1  *        2048 39942143 39940096   19G 83 Linux
/dev/sda2       39944190 41940991  1996802  975M  5 Extended
/dev/sda5       39944192 41940991  1996800  975M 82 Linux swap / Solaris

Partition 2 does not start on physical sector boundary.
Тут нас интересует общее число секторов на диске (52428800) и число секторов под раздел подкачки (1996800). Ещё отметим, что логический диск /dev/sda2 (который был создан автоматически) никуда не смонтирован и пересекается с /dev/sda5. Возможно это баг автоматической разбивки, мы просто удалим его.


Удаляем раздел с подкачкой 5 и логический раздел 2 (команда d):
(***При этом удаляется только запись о разделе, сами данные остаются на диске!***)

Command (m for help): d
Partition number (1,2,5, default 5): 5

Partition 5 has been deleted.

Command (m for help): d
Partition number (1,2, default 2): 2

Partition 2 has been deleted.

И посмотрим, что у нас получилось:

Command (m for help): p
Disk /dev/sda: 25 GiB, 26843545600 bytes, 52428800 sectors
Disk model: Virtual Disk
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 4096 bytes
I/O size (minimum/optimal): 4096 bytes / 4096 bytes
Disklabel type: dos
Disk identifier: 0x73000288

Device     Boot Start      End  Sectors Size Id Type
/dev/sda1  *     2048 39942143 39940096  19G 83 Linux
Теперь заново создадим раздел с подкачкой, но уже в конце диска. Создаем новый раздел с помощью n:

Command (m for help): n
Partition type
p primary (1 primary, 0 extended, 3 free)
e extended (container for logical partitions)
Select (default p):
Нас попросят выбрать тип раздела, для создаваемого /dev/sda2 выбираем логический e:

Указываем порядковый номер раздела 2:

Partition number (2-4, default 2): 2
Далее потребуется указать начало раздела. Если мы хотим оставит размер подкачки таким же как он и был, то из последнего сектора диска /dev/sda (52428800) вычитаем число секторов, на которых располагался раздел /dev/sda2 (1996800) и получаем 50432000:

First sector (39942144-52428799, default 39942144): 50432000
Последним сектором указываем последний сектор диска:

Last sector, +/-sectors or +/-size{K,M,G,T,P} (50431998-52428799, default 52428799): 52428799

Created a new partition 2 of type 'Extended' and of size 975 MiB.
Теперь изменим его тип, нажав t, указав раздел 2 и код 82 для файла подкачки:

Command (m for help): t
Partition number (1,2, default 2): 2
Hex code or alias (type L to list all): 82

Changed type of partition 'Extended' to 'Linux swap / Solaris'.
Посмотрим, что у нас получилось:

Command (m for help): p
Disk /dev/sda: 25 GiB, 26843545600 bytes, 52428800 sectors
Disk model: Virtual Disk
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 4096 bytes
I/O size (minimum/optimal): 4096 bytes / 4096 bytes
Disklabel type: dos
Disk identifier: 0x73000288

Device     Boot    Start      End  Sectors  Size Id Type
/dev/sda1  *        2048 39942143 39940096   19G 83 Linux
/dev/sda2       50432000 52428799  1996800  975M 82 Linux swap / Solaris
Сохраняем внесенные изменения w:

Command (m for help): w
The partition table has been altered.
Syncing disks.
После этого fdisk завершит свою работу и мы можем создать swap (указывайте свой новый раздел подкачки!):

### mkswap /dev/sda2

Setting up swapspace version 1, size = 975 MiB (1022357504 bytes)
no label, UUID=be9928b0-ce1b-44f1-b925-a94fffac5b2e
Копируем UUID, его надо будет указать в fstab, чтобы он работал после перезагрузки. Открываем любым текстовым редактором:

### nano /etc/fstab
Находим запись с типом swap (после комментария #swap was on) и там заменяем UUID на новый. Сохраняем и выходим.

Осталось только включить подкачку:

### swapon /dev/sda2
Debian 11 увеличение раздела диска
Выполним fdisk /dev/sda, где /dev/sda – метка нашего диска:

### fdisk /dev/sda

Welcome to fdisk (util-linux 2.36.1).
Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.

Вводим p, чтобы посмотреть на список разделов:

Command (m for help): p
Disk /dev/sda: 25 GiB, 26843545600 bytes, 52428800 sectors
Disk model: Virtual Disk
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 4096 bytes
I/O size (minimum/optimal): 4096 bytes / 4096 bytes
Disklabel type: dos
Disk identifier: 0x73000288

Device     Boot    Start      End  Sectors  Size Id Type
/dev/sda1  *        2048 39942143 39940096   19G 83 Linux
/dev/sda2       50432000 52428799  1996800  975M 82 Linux swap / Solaris
У вас могут быть другие разделы, главное, чтобы были свободные сектора после того раздела, который мы хотим расширить. Для этого мы в предыдущем разделе двигали swap в конец диска. У нас получилось, что sda1 заканчивается на секторе 39940096, а следующий раздел sda2 начинается на 50432000, а между ними есть свободные. Если же у вас расширяемый раздел один или он последний, то нужно смотреть на последний сектор раздела(39940096) и диска (50432000).

Чтобы расширить раздел требуется предварительно удалить информацию о нём. Для этого вводим d и указываем раздел (1 для /dev/sda1):

Command (m for help): d
Partition number (1-2, default 2): 1

Partition 1 has been deleted.
При этом удаляется только запись о разделе, сами данные остаются на диске!

Вводим n – создание нового раздела:

Command (m for help): n
Partition type
   p   primary (1 primary, 0 extended, 3 free)
   e   extended (container for logical partitions)
Указываем основной тип p:

Select (default p): p
Далее порядковый номер раздела 1 (который удалили):

Partition number (1,3,4, default 1): 1
Далее указываются начальный и конечный сектор. Обязательно проверьте, чтобы они совпадали со значениям, указанными через дефис. Таким образом мы используем все неразмеченное/свободное пространство:

First sector (2048-50431999, default 2048): 2048
Last sector, +/-sectors or +/-size{K,M,G,T,P} (2048-50431999, default 50431999): 50431999

Created a new partition 1 of type 'Linux' and of size 24 GiB.
Как видим, был создан раздел на 24 гигабайта с типом Linux filesystem.

Также будет задан вопрос, хотим ли мы удалить текущую файловую систему. Отвечаем отказом:

Partition #1 contains a ext4 signature.

Do you want to remove the signature? [Y]es/[N]o: N
И если, как в нашем случае, раздел был загрузочным – делаем его таковым:

Command (m for help): a
Partition number (1,2, default 1): 1
The bootable flag on partition 1 is enabled.
Осталось только сохранить таблицу разделов:

Command (m for help): w
Мы увидим сообщение, что таблица с разделами изменена, но так как устройство занято, изменения вступят в силу только после перезагрузки.

The partition table has been altered.
Failed to update system information about partition 1: Device or resource busy

The kernel still uses the old partitions. The new table will be used at the next reboot.
Syncing disks.
Перезагружаем виртуальную машину:

### reboot
Изменение размера файловой системы ext4
Теперь воспользуемся утилитой resize2fs (для ext4) для увеличения размера файловой системы:

### resize2fs /dev/sda1
resize2fs 1.46.2 (28-Feb-2021)
Filesystem at /dev/sda1 is mounted on /; on-line resizing required
old_desc_blocks = 3, new_desc_blocks = 4
The filesystem on /dev/sda1 is now 6303744 (4k) blocks long.
Проверяем результат:

### df -h
Filesystem      Size  Used Avail Use% Mounted on
udev            944M     0  944M   0% /dev
tmpfs           192M  496K  192M   1% /run
/dev/sda1        24G  1.1G   22G   5% /
tmpfs           960M     0  960M   0% /dev/shm
tmpfs           5.0M     0  5.0M   0% /run/lock
tmpfs           192M     0  192M   0% /run/user/1000