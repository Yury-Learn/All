---
sticker: emoji//1f90c
---
#vmmanager #vmm #ksb
## Установка OC

- Установка
1. На шаге **Установка базовой системы** выберите **Ядро для установки** — linux-5.15-generic или linux-6.1-generic.
2. На шаге **Выбор программного обеспечения**:
    1. Выберите следующие компоненты:
        1. **Средства Виртуализации**.
        2. **Консольные утилиты**.
        3. **Средства удаленного подключения SSH**.
    2. Убедитесь, что остальные компоненты отключены.
3. На шаге **Дополнительные настройки ОС**:
    1. Выберите уровень защищенности "Орел" или "Воронеж".
    2. Убедитесь, что отключены опции:  
        1. **Замкнутая программная среда**.
        2. **Запрет установки бита исполнения**.
        3. **Запрет исполнения скриптов пользователя**.

###  Настройка репозитариев 
> /etc/apt/sources.list

```
# Основной репозиторий

deb [https://dl.astralinux.ru/astra/stable/1.7_x86-64/repository-main/](https://dl.astralinux.ru/astra/stable/1.7_x86-64/repository-main/)     1.7_x86-64 main contrib non-free

# Оперативные обновления основного репозитория

deb [https://dl.astralinux.ru/astra/stable/1.7_x86-64/repository-update/](https://dl.astralinux.ru/astra/stable/1.7_x86-64/repository-update/)   1.7_x86-64 main contrib non-free

# Базовый репозиторий

deb [https://dl.astralinux.ru/astra/stable/1.7_x86-64/repository-base/](https://dl.astralinux.ru/astra/stable/1.7_x86-64/repository-base/)     1.7_x86-64 main contrib non-free

# Расширенный репозиторий

deb [https://dl.astralinux.ru/astra/stable/1.7_x86-64/repository-extended/](https://dl.astralinux.ru/astra/stable/1.7_x86-64/repository-extended/) 1.7_x86-64 main contrib non-free
```

- Обновление после настройки репозитариев
```sh
apt update && apt full-upgrade
```

### Настройки системы
===В файле **/etc/network/interfaces** настройте сетевую конфигурацию со статическим IP-адресом:===
```sh
mcedit /etc/hosts
```
```
sudo systemctl restart networking
```

В файле **/etc/sudoers** разрешите выполнение команд от имени суперпользователя: 

```sql
%astra-admin ALL=(ALL:ALL) NOPASSWD: ALL
%sudo ALL=(ALL:ALL) NOPASSWD: ALL
```

```
sudo usermod -a -G astra-admin,kvm,libvirt,libvirt-qemu,libvirt-admin <user>
```

```
systemctl enable --now ntp
ntpq -p
```

```
apt install -y lvm2
```

### iSCSI
```
apt install -y open-iscsi
```

1. Отредактируйте файл **/etc/iscsi/iscsid.conf:**
    
    1. Раскомментируйте строки:
        
        ```undefined
        node.session.auth.authmethod = CHAP
        ```
        
    2. Раскомментируйте параметры node.session.auth.username, node.session.auth.password. Укажите id пользователя и пароль, заданные в настройках ACL для таргета:
        
        ```xml
        node.session.auth.username = <id>
        node.session.auth.password = <pass>
        ```
        
        Пояснения
        
2. Для ОС Astra Linux:
    1. Включите автоматическое подключение к хранилищу. Для этого в конфигурационном файле **/etc/iscsi/iscsid.conf**:
        
        1. Раскомментируйте строку: 
            
            ```undefined
            node.startup=automatic
            ```
            
              
            
        2. Закомментируйте строку: 
            
            ```undefined
            node.startup=manual
            ```
            
    2. Перезапустите сервис iscsid: 
        
        ```sh
        systemctl restart iscsid.service
        ```
        
3. Проверьте доступ к таргету:
    
    ```xml
    iscsiadm -m discovery -t sendtargets -p <target ip>
    ```
    
    Пояснения к команде
    
    Пример успешного выполнения команды
    
    ```undefined
    192.0.2.123:3260,1
    iqn.2020-02.example.com:MyTarget1
    ```
    
4. Подключитесь к таргету:
    
    ```sql
    iscsiadm -m node --login
    ```
    
    ```sh
    iscsiadm --mode node --target <target name> --portal <target ip> --logout
    ```
    
```sh
iscsiadm --mode node --target iqn.2000-01.com.synology:nas1.vmm1repo.26a04855ea0 --portal 10.38.16.15 --login
```
```sh
iscsiadm --mode node --target iqn.2004-04.com.qnap:ts-1283xu-rp:iscsi.vmm.7e775a --portal 10.38.16.3 --login

```
- Убедитесь, что таргет подключён как блочное устройство:
    ```undefined
    lsblk
    ```

## Установка ПО на узлы кластера

1. Подключитесь к серверу по SSH с правами пользователя root. 
2. Подключите ISO-образ платформы: 
    
    ```bash
    mount -o loop <path_to_iso> /mnt
    ```
    
    Пояснения к команде
    
3. Запустите скрипт установки: 
    
    ```bash
    cd /mnt/vmmanager6_kvm_node && sudo sh install.sh
    ```
    
4. Дождитесь окончания установки. Если установка завершилась успешно, то в терминале появится сообщение вида:
    
    ```sql
    Complete!
    Done. Next - add this node to VMmanager 6
    ```

## Диагностика

### Network
 - все адреса должны быть прописаны **статикой**


### libvirtd

```
systemctl start libvirtd.socket
```

```
systemctl stop libvirtd-ro.socket
systemctl stop libvirtd-admin.socket
systemctl stop libvirtd.socket
systemctl stop libvirtd.service
systemctl start libvirtd-tls.socket
systemctl start libvirtd-ro.socket
systemctl start libvirtd-admin.socket
systemctl start libvirtd.socket
```
Заодно смотрим **status**  служб, иногда нужно запустить сервис **enable**. Для этого сначала останавливаем **libvirtd.service** и запускаем нужную, после стартуем **libvirtd.service**

## Портал
https://10.38.16.249
service@ksb-soft.ru
vdnJgCodYPVjZi9rb

| Имя          |     | host                                                          | login               | password                             | IPMI Login    | IPMI Pass        |
| ------------ | --- | ------------------------------------------------------------- | ------------------- | ------------------------------------ | ------------- | ---------------- |
| Qtech1Silver | 1   | 10.38.16.25<br>10.38.22.248<br>10.38.23.248 / gw 10.38.23.253 | ksb<br>root         | <f,jxrfKtnftn25!<br><f,jxrfKtnftn26! |               |                  |
| node2-esxi3  |     | 10.38.16.8<br>10.38.22.251<br>10.38.23.2251<br>               | ksb                 | БабочкаЛетает45!                     | Administrator | <f,jxrfKtnftn34! |
| portal       |     | https://10.38.16.249/auth/login                               | service@ksb-soft.ru | vdnJgCodYPVjZi9rb                    |               |                  |
| node3        |     | 10.38.16.23<br>10.38.22.252<br>10.38.23.252                   | ksb<br>root         | <f,jxrfKtnftn46!<br><f,jxrfKtnftn47! |               |                  |
|              |     |                                                               |                     |                                      |               |                  |



