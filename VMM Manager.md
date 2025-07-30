# FTP репо
1. /srv/repo/alse/{{d}}


https://10.38.22.104/auth/setup?token=99BF279763DEA6DC05BCE8EA20CAEDAC

Images repository URL http://10.38.22.104:5111/


`mount -o loop /srv/iso /mnt`
`cd /mnt/vmmanager6_kvm_node && sh install.sh`

### Скрипт установки
`mount -o loop <path_to_iso> /mnt`
`cd /mnt/vmmanager6_kvm_node && sh install.sh`

GAOVxyPVn2scz8C

Images repository URL http://10.38.22.104:5111/OSTemplate/vm6/windows


vmm-user
9O777inHD96lZW6
iqn.2004-04.com.qnap:ts-1283xu-rp:iscsi.vmmanager.7e775a

```sh
apt install -y open-iscsi
mcedit /etc/iscsi/initiatorname.iscsi
```

> 	InitiatorName=iqn.<year>-<month>.<reverse domain>:<initiator name>

`mcedit /etc/iscsi/iscsid.conf`
> 	node.session.auth.authmethod = CHAP
> 	node.session.auth.username = <id>
> 	node.session.auth.password = <pass>


1. Для ОС Astra Linux:
    1. Включите автоматическое подключение к хранилищу. Для этого в конфигурационном файле **/etc/iscsi/iscsid.conf**:
        
        1. Раскомментируйте строку: 

            `node.startup=automatic`
            
        2. Закомментируйте строку: 

            `node.startup=manual`

            
            
            
    2. Перезапустите сервис iscsid: 
    
        `systemctl restart iscsid.service`

2. Проверьте доступ к таргету:
    
    `iscsiadm -m discovery -t sendtargets -p <target ip>`
1. Подключитесь к таргету:
   `iscsiadm -m node --login`
   `iscsiadm --mode node --target <target name> --portal <target ip> --logout`  
```iscsiadm --mode node --target iqn.2004-04.com.qnap:ts-1283xu-rp:iscsi.vmmanager.7e775a --portal 10.38.22.6 --logout```
`iscsiadm -m node --login`

2. Убедитесь, что таргет подключён как блочное устройство:
    `lsblk`



