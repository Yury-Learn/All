---
tags: netapp
---
Чтобы выполнить указанные шаги по подготовке хранилища NFS на NetApp, выполните следующие шаги:

### 1. Создание группы и пользователя на NetApp
1. Подключитесь к вашему NetApp хранилищу с помощью консоли управления или SSH.
2. Выполните следующие команды для создания группы `kvm` и пользователя `vdsm` с указанными идентификаторами.

```shell
::> set -privilege advanced
```

3. Создайте группу `kvm` с идентификатором 36:

```shell
::> vserver services unix-group add -vserver <vserver_name> -name kvm -id 36
```

4. Создайте пользователя `vdsm` с идентификатором 36 и добавьте его в группу `kvm`:

```shell
::> vserver services unix-user add -vserver <vserver_name> -name vdsm -id 36 -primary-gid 36
```

### 2. Настройка прав доступа на экспортированный каталог
1. На NetApp создайте каталог (если он еще не создан) для экспорта:

```shell
::> volume create -vserver <vserver_name> -volume <volume_name> -aggregate <aggregate_name> -size <size>
::> volume mount -vserver <vserver_name> -volume <volume_name> -junction-path /data
```

2. Установите право собственности на каталог `/data`:

```shell
::> volume file-directory modify -vserver <vserver_name> -path /data -user 36 -group 36 -security-style unix
```

3. Установите права доступа на каталог:

```shell
::> volume file-directory modify -vserver <vserver_name> -path /data -mode 0755
```

### 3. Изменение настроек NFS-экспорта
1. Откройте файл настроек NFS-экспорта на вашем NetApp. Для этого можно использовать команду:

```shell
::> vserver export-policy rule create -vserver <vserver_name> -policyname <policy_name> -clientmatch <client_ip> -protocol nfs3 -ro-rule any -rw-rule any -anon 36
```

Здесь `<vserver_name>` - имя вашего виртуального сервера, `<policy_name>` - имя политики экспорта, `<client_ip>` - IP-адрес клиента, которому разрешен доступ.

2. Добавьте или измените параметры `anonuid` и `anongid`:

```shell
::> export-policy rule modify -vserver <vserver_name> -policyname <policy_name> -ruleindex 1 -anon 36
```

### 4. Проверка и монтирование NFS
1. Проверьте настройки экспорта:

```shell
::> vserver export-policy rule show -vserver <vserver_name>
```

2. На сервере, где будет использоваться NFS, смонтируйте экспортированный каталог:

```shell
sudo mkdir -p /mnt/data
sudo mount -t nfs <NetApp_IP>:/data /mnt/data
```

3. Убедитесь, что каталог смонтирован правильно и права доступа установлены корректно:

```shell
ls -ld /mnt/data
```

### Обобщение
Эти шаги позволят вам настроить NFS-экспорт на вашем NetApp хранилище с правильными учетными записями и правами доступа, чтобы ваш сервер Redvirt мог использовать эти каталоги для хранения данных. Не забудьте заменить `<vserver_name>`, `<volume_name>`, `<aggregate_name>`, `<size>`, `<policy_name>`, `<client_ip>`, `<NetApp_IP>` и другие параметры на актуальные для вашей конфигурации.