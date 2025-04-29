#esxi


| Name                          | Network |
| ----------------------------- | ------- |
| sentry_itconn(20.223)         | 20      |
| it_conn_landing(10.38.20.108) | 20      |
| it_conn(10.38.20.247)         | 20      |

```powershell
cd 'C:\Program Files\VMware\VMware OVF Tool\'
& .\ovftool.exe 'vi://172.18.1.22/sentry_itconn(20.223)' F:\VMBU
```

& 'C:\Program Files\VMware\VMware OVF Tool\ovftool.exe' 'vi://172.18.1.6/VeeamBackup17(172.18.1.7)' "E:\VM\"

Через утилиту OVF Tools (CLI)
Example: 
```powershell
& 'C:\Program Files\VMware\VMware OVF Tool\ovftool.exe' --noSSLVerify -ds="Data2" -dm="thin" -n="Prometeus" "D:\VM\Prometeus\Prometeus.ovf" vi://172.18.1.10
Система попросит указать Username/Password
```

--noSSLVerify - не требовать проверки SSL.
-ds= указываем название хранилища сервера.
-dm= указывает метод разворачивания thin или thick 
-n= указываем название, которое будет на ESXi



При появлении ошибки связанной с сетью, добавляем сетевой интерфейс "VMkernel" с таким же названием на ESXi. (Позже можно будет удалить)