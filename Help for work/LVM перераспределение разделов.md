Имеется машина с тремя разделами LVM:

root@archiso ~ # lsblk 

NAME                  MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT

loop0                   7:0    0 365.4M  1 loop /run/archiso/sfs/airootfs

sda                     8:0    0    30G  0 disk 

├─sda1                  8:1    0   487M  0 part 

├─sda2                  8:2    0     1K  0 part 

└─sda5                  8:5    0  29.5G  0 part 

  ├─ubuntu--vg-root   254:0    0    10G  0 lvm  

  ├─ubuntu--vg-swap_1 254:1    0     1G  0 lvm  

  └─ubuntu--vg-home   254:2    0  18.5G  0 lvm  

sr0                    11:0    1   476M  0 rom  /run/archiso/bootmnt

Задача — уменьшить ubuntu--vg-root, а на освободившееся место — увеличить ubuntu--vg-home.

Система Ubuntu, машина сейчас запущена под Arch.

Проверяем разделы, все должны быть ACTIVE:

[root@archiso ~]# lvscan

ACTIVE            '/dev/ubuntu-vg/root' [10.00 GiB] inherit

ACTIVE            '/dev/ubuntu-vg/swap_1' [1.00 GiB] inherit

ACTIVE            '/dev/ubuntu-vg/home' [18.52 GiB] inherit

Содержание

- [/](https://rtfm.co.ua/linux-lvm-umenshit-home-uvelichit-root/#/root)root
- [/home](https://rtfm.co.ua/linux-lvm-umenshit-home-uvelichit-root/#/home)

/root

Начнём с root.

Порядок действий:

1. уменьшить размер файловой системы
2. уменьшить раздел logical volume

Важно не перепутать порядок действий. Один раз сонный делал такие изменения — убил раздел, к счастью — тоже на витуалке.

Проверяем целостность ФС:

[root@archiso ~]# e2fsck -f /dev/ubuntu-vg/root

e2fsck 1.43.4 (31-Jan-2017)

Pass 1: Checking inodes, blocks, and sizes

Pass 2: Checking directory structure

Pass 3: Checking directory connectivity

Pass 4: Checking reference counts

Pass 5: Checking group summary information

/dev/ubuntu-vg/root: 97684/654080 files (0.2% non-contiguous), 506679/2621440 blocks

Уменьшаем размер файловой системы до 5 GB:

[root@archiso ~]# resize2fs /dev/ubuntu-vg/root 5G

resize2fs 1.43.4 (31-Jan-2017)

Resizing the filesystem on /dev/ubuntu-vg/root to 1310720 (4k) blocks.

The filesystem on /dev/ubuntu-vg/root is now 1310720 (4k) blocks long.

Уменьшаем размер тома до 5gb:

[root@archiso ~]# lvreduce -L 5G /dev/ubuntu-vg/root

WARNING: Reducing active logical volume to 5.00 GiB.

THIS MAY DESTROY YOUR DATA (filesystem etc.)

Do you really want to reduce ubuntu-vg/root? [y/n]: y

Size of logical volume ubuntu-vg/root changed from 10.00 GiB (2560 extents) to 5.00 GiB (1280 extents).

Logical volume ubuntu-vg/root successfully resized.

Проверяем:

[root@archiso ~]# lsblk /dev/sda5

NAME                MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT

sda5                  8:5    0 29.5G  0 part

├─ubuntu--vg-root   254:0    0    5G  0 lvm

├─ubuntu--vg-swap_1 254:1    0    1G  0 lvm

└─ubuntu--vg-home   254:2    0 18.5G  0 lvm

/home

С помощью lvextend — увеличиваем размер ubuntu--vg-home на 5G:

[root@archiso ~]# lvextend -L +5G /dev/ubuntu-vg/home

Size of logical volume ubuntu-vg/home changed from 18.52 GiB (4741 extents) to 23.52 GiB (6021 extents).

Logical volume ubuntu-vg/home successfully resized.

Проверяем ФС:

[root@archiso ~]# e2fsck -f /dev/ubuntu-vg/home

e2fsck 1.43.4 (31-Jan-2017)

Pass 1: Checking inodes, blocks, and sizes

Pass 2: Checking directory structure

Pass 3: Checking directory connectivity

Pass 4: Checking reference counts

Pass 5: Checking group summary information

/dev/ubuntu-vg/home: 11/1215840 files (0.0% non-contiguous), 120370/4854784 blocks

И выполняем resize. Не укзываем размер, что бы занять 100% свободного места:

[root@archiso ~]# resize2fs -p /dev/ubuntu-vg/home

resize2fs 1.43.4 (31-Jan-2017)

Resizing the filesystem on /dev/ubuntu-vg/home to 6165504 (4k) blocks.

Begin pass 1 (max = 40)

Extending the inode table     XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX-

The filesystem on /dev/ubuntu-vg/home is now 6165504 (4k) blocks long.

Проверяем:

[root@archiso ~]#  /dev/sda5

NAME                MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT

sda5                  8:5    0 29.5G  0 part

├─ubuntu--vg-root   254:0    0    5G  0 lvm

├─ubuntu--vg-swap_1 254:1    0    1G  0 lvm

└─ubuntu--vg-home   254:2    0 23.5G  0 lvm

Бутаемся в Ubuntu и проверяем:

jmadmin@ubuntu:/$ lsblk  /dev/sda5

NAME                MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT

sda5                  8:5    0 29.5G  0 part

├─ubuntu--vg-root   252:0    0    5G  0 lvm  /

├─ubuntu--vg-swap_1 252:1    0    1G  0 lvm  [SWAP]

└─ubuntu--vg-home   252:2    0 23.5G  0 lvm  /home

Готово.