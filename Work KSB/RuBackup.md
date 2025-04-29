#rubackup


`ksb /  Vjkjnjr73#`
`root / Vjkjnjr74#`
`grub /Grub_Astra`

Перед установкой клиентского и серверного пакетов необходимо

установить пакет **rubackup-common.deb** или **rubackup-common.rpm**.

Мастер-ключ рекомендуется распечатать при помощи утилиты hexdump, так как он может содержать неотображаемые на экране символы. Например:

```
hexdump master-key
```

### PostgreSQL

![[Install Postgres]]
postgres psql -c "alter user postgres password 'super_secret_db_password';"
	P0stgre_Rubackup

### Доп. Настройки

```sql
ALTER SYSTEM SET shared_buffers TO <your_value>;
```
```sql
ALTER SYSTEM SET work_mem TO "1GB";
```


postgresql 
rubackup / PtktysqXfq82!n



### Файл лицензии

Сервер RuBackup содержит в себе лицензию на выполнение резервного копирования общим объемом резервных копий 1 ТБ. При первом запуске сервер RuBackup попытается получить лицензионный файл от глобального лицензионного сервера RuBackup. Если выход в Интернет с сервера невозможен, обратитесь к своему поставщику с указанием hardware ID для получения лицензионного файла. Hardware ID можно узнать при

помощи следующей команды:

```bash
rubackup_server hwidrb_init
```

Copyright 2018-2022: LLC "RUBACKUP" Исключительные права принадлежат ООО "РУБЭКАП" Author is Andrey Kuznetsov

Version: 1.9

RuBackup hardware ID: 5253096d055899485ed2787eccfc57ae54ff04e76104856726c913732aa0c2b8

Лицензионный файл следует поместить в каталог /opt/rubackup/etc.


```sh
apt install mailutils libcurl4 nfs-kernel-server nfs-common libqt5sql5-psql postgresql-contrib
```

```sh
apt install pigz xz-utils nfs-client
```

```
sudo systemctl enable \ /opt/rubackup/etc/systemd/system/rubackup_client.service
```
```sh
systemctl daemon-reload
```
```sh
systemctl start rubackup_client
```
```sh
systemctl status rubackup_client
```