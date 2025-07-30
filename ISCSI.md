#iSCSI 
# Краткий справочник

  типовой сценарий употребения iscsi:  
  
- сначала мы находим нужные нам target, для этого мы должны знать IP/dns-имя инициатора: — это команда **send targets**.  
```
iscsiadm -m discovery -t st -p 192.168.0.1
```
- список найденного для логина
```
iscsiadm -m node
```
- залогиниться, то есть подключиться и создать блочное устройство
```
iscsiadm -m node -l -T iqn.2011-09.example:data
```
 - вывести список того, к чему подключились
```
iscsiadm -m session
```
- вывести его же, но подробнее — в самом конце вывода будет указание на то, какое блочное устройство какому target'у принадлежит
```
iscsiadm -m session -P3
```
- вылогиниться из конкретной
```
iscsiadm - m session -u -T iqn.2011-09.example:data
```
- залогиниться во все обнаруженные target'ы
```
iscsiadm -m node -l
```
- вылогиниться из всех target'ов
```
iscsiadm -m node -u
```
- удалить target из обнаруженных
```
iscsiadm -m node --op delete -T iqn.2011-09.example:data
```

# Примеры настройки
```sh
iscsiadm -m discovery -t st -p IP_адрес; iscsiadm -m node -l
```

```sh
iscsiadm --mode node --target <target name> --portal <target ip> --logout
```

```sh
iscsiadm --mode node --target iqn.1992-08.com.netapp:sn.312f34171c7111eba0d6d039ea212413:vs.4 --portal 192.244.244.105 --login
```

```sh
iscsiadm -m discovery -t sendtargets -p <target ip>
```

```
mcedit /etc/iscsi/iscsid.conf
```
	node.startup = automatic


```
sed -i 's/node.startup = manual/node.startup = automatic/' /etc/iscsi/iscsid.conf
```
Отредактируйте файл **/etc/iscsi/iscsid.conf:**

1. Раскомментируйте строки:
    
    ```
    node.startup=automatic
    ```
