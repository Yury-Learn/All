#nfs #redvirt

---

#  Настройка и подключение NFS-домена в РЕД Виртуализации

---

## 1. Подготовка NFS-сервера (`rv-guest.ksb.local`)

### 1.1 Установка необходимых пакетов

```bash
dnf install -y nfs-utils
```

### 1.2 Включение и запуск сервисов

```bash
systemctl enable --now rpcbind.service nfs-server.service
```

Проверка:

```bash
systemctl status rpcbind.service nfs-server.service
```

---

##  2. Создание экспортируемого каталога

### 2.1 Создаём каталог

```bash
mkdir -p /export/redvirt-storage
```

### 2.2 Устанавливаем владельца (UID 36 = `vdsm`, GID 36 = `kvm`)

```bash
chown 36:36 /export/redvirt-storage
chmod 755 /export/redvirt-storage
```

Проверка:

```bash
ls -ld /export/redvirt-storage
```

Ожидаемый вывод:

```
drwxr-xr-x. 3 vdsm kvm ...
```

---

##  3. Настройка экспорта NFS

### 3.1 Редактируем `/etc/exports`

```bash
echo "/export/redvirt-storage *(rw,insecure,nohide,all_squash,anonuid=36,anongid=36,no_subtree_check)" >> /etc/exports
```

### 3.2 Применяем экспорт

```bash
exportfs -ra
exportfs -v
```

Ожидаемый вывод:

```
/export/redvirt-storage
    <world>(sync,wdelay,nohide,no_subtree_check,anonuid=36,anongid=36,sec=sys,rw,insecure,root_squash,all_squash)
```

---

##  4. Настройка Firewall (если используется)

Открываем порты:

```bash
firewall-cmd --add-service=nfs --permanent
firewall-cmd --add-service=mountd --permanent
firewall-cmd --add-service=rpc-bind --permanent
firewall-cmd --reload
```

---

##  5. Настройка SELinux (если включен)

### Временно отключить для теста:

```bash
setenforce 0
```

### Или установить нужный контекст:

```bash
chcon -Rt nfs_t /export/redvirt-storage
```

---

##  6. Проверка на клиенте (`rv-host1`)

```bash
showmount -e rv-guest.ksb.local
```

Ожидаемый вывод:

```
Export list for rv-guest.ksb.local:
/export/redvirt-storage *
```

Можно дополнительно примонтировать вручную:

```bash
mount -t nfs rv-guest.ksb.local:/export/redvirt-storage /mnt/test
```

---

##  7. Добавление хранилища NFS в РЕД Виртуализации

**Через GUI (раздел 10.2.2 из документа):**

1. Перейти: **Хранилище → Домены хранения → Добавить**
    
2. Тип: `NFS`
    
3. Имя: `redvirt-storage`
    
4. Сервер: `rv-guest.ksb.local`
    
5. Путь: `/export/redvirt-storage`
    
6. Формат: **V4** или **V3** (в зависимости от версии NFS)
    
7. Подтвердить добавление
    

⚠️ Каталог **должен быть пустой**, иначе появится ошибка `Physical device initialization failed`.

---

##  Готово!

После успешного подключения домен должен появиться как **активный NFS-домен хранения** в интерфейсе РЕД Виртуализации.

---

###  Дополнительно

- UID 36 (`vdsm`) — это системный пользователь РЕД Виртуализации, которому должен принадлежать каталог.
    
- Используется `all_squash` + `anonuid/anongid`, чтобы все NFS-запросы шли от `vdsm`.
    
- Опция `nohide` нужна, если в каталоге будут монтироваться другие подкаталоги, и ты хочешь, чтобы клиент их видел.
    

---