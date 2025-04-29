---
tags: iSCSI, iscsi, synology
---
# Создаём synology iscsi и подключаем в Ubuntu



## В Synology

переходим в SAN менеджер и создаем target

![](https://itscience.pro/pictures/izobrazhenie_2021-12-16_134256.png)

и сразу создаём, связанный с target LUN

нам нужно 30Тб, не заморачиваемся с гибкостью, нужна максимальная надёжность

дальше настраиваем в ubuntu

## в Ubuntu

устанавливаем софт

`sudo su apt update apt install open-iscsi`

редактируем конфиг

`mcedit /etc/iscsi/iscsid.conf`

меняем

`#***************** # Startup settings #*****************  # To request that the iscsi initd scripts startup a session set to "automatic". # node.startup = automatic # # To manually startup the session set to "manual". The default is manual. #node.startup = manual node.startup = automatic`

запрашиваем доступные таргеты с сервера

`iscsiadm -m discovery -t st -p <адрес сервера> ; sudo iscsiadm -m node -l'

![](https://itscience.pro/pictures/izobrazhenie_2021-12-16_160129.png)

когда у нас подключен LUN мы можем заняться созданием раздела и форматированием в btrfs  
для начала посмотрим, куда подключился LUN

`fdisk -l`

![](https://itscience.pro/pictures/izobrazhenie_2021-12-16_170905.png)

в нашем примере это /dev/sdb

создаем раздел на все свободное пространство (это будет радел GPT, иначе не сможем сделать больше 2 TiB).

`fdisk /dev/sdb`

![](https://itscience.pro/pictures/izobrazhenie_2021-12-16_171013.png)

как нам подсказывает помощь, сначала меняем тип раздела, жмём **g**, потом создаем новый раздел **n**, номер раздела 1, он у нас первый и единственный, размеры начала раздела и его конца по-умолчанию. Когда мы все проверили и нас все устроило, жмём **w** и записываем изменения.

![](https://itscience.pro/pictures/izobrazhenie_2021-12-16_171042.png)

ещё раз запускаем fdisk и смотрим результат

`fdisk -l`

![](https://itscience.pro/pictures/izobrazhenie_2021-12-16_171120.png)

мы получили раздел /dev/sdb1

теперь форматируем  
для начала установим btrfs-progs

`apt install btrfs-progs`

форматируем наш раздел

`mkfs.btrfs -L data /dev/sdb1`

![](https://itscience.pro/pictures/izobrazhenie_2021-12-16_172420.png)

подключаем раздел как папку /var

`mount /dev/sdb1 /mail`

смотрим uuid нашего раздела

`btrfs filesystem show /mail`

![](https://itscience.pro/pictures/izobrazhenie_2021-12-16_173113.png)

редактируем /etc/fstab для автоматического подключения

`mcedit /etc/fstab`

прописываем

`UUID=5d84eadf-6272-4b3f-8ac9-90a72108df11       /mail   btrfs   defaults    0 0`

перегружаем и проверяем

`reboot`
