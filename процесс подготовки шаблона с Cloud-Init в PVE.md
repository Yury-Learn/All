#cloud-init #pve 

---

## 🔧 Полный процесс подготовки шаблона с **Cloud-Init** в PVE

---

### 1. 📦 Создание новой VM

#### Через Web-интерфейс:

- **Create VM**
    
- Укажи:
    
    - _VM ID_: например `9000`
        
    - _Name_: `ubuntu-ci-template`
        
    - _ISO Image_: выбери ISO с поддержкой Cloud-Init (например, `ubuntu-22.04-live-server.iso`)
        
- На вкладке **System**:
    
    - BIOS: `OVMF (UEFI)` (если планируешь использовать UEFI) или `SeaBIOS`
        
    - Machine: `q35`
        
    - **Important**: выбери **SCSI** для диска, **VirtIO** для сети
        
- **Диск**: поставь `scsi0`, формат `qcow2`, хранилище `local-lvm` (или любое другое)
    
- **Network**: `VirtIO (paravirtualized)`
    

---

### 2. 🛠 Установка ОС внутри VM

Установи ОС как обычно (Ubuntu/Debian/CentOS и др.).

После установки:

```bash
sudo apt update && sudo apt install cloud-init qemu-guest-agent -y
sudo systemctl enable --now qemu-guest-agent
```

Проверь наличие конфигурации Cloud-Init:

```bash
cat /etc/cloud/cloud.cfg
```

Убедись, что там есть `datasource_list: [ NoCloud, ConfigDrive ]`.

---

### 3. 🧹 Подготовка образа

Очисти все уникальные данные:

```bash
sudo cloud-init clean
sudo rm -f /etc/ssh/ssh_host_*
sudo truncate -s 0 /var/log/wtmp /var/log/btmp
sudo rm -f /etc/machine-id
sudo touch /etc/machine-id
history -c
```

---

### 4. 🔒 Выключи VM

```bash
qm shutdown 9000
```

---

### 5. ➕ Добавь диск cloud-init

В консоли Proxmox или Web-интерфейсе:

```bash
qm set 9000 --ide2 local-lvm:cloudinit
qm set 9000 --boot c --bootdisk scsi0
qm set 9000 --serial0 socket --vga serial0
```

Это создаёт виртуальный Cloud-Init-диск.

---

### 6. 🧊 Преврати в шаблон

```bash
qm template 9000
```

---

## 🚀 Клонирование шаблона

```bash
qm clone 9000 101 --name ubuntu-test --full
```

---

## ⚙ Настройка Cloud-Init для клонированной VM

```bash
qm set 101 \
  --ciuser=ansible \
  --cipassword=SuperSecret123 \
  --sshkey="$(cat ~/.ssh/id_rsa.pub)" \
  --ipconfig0="ip=192.168.122.101/24,gw=192.168.122.1" \
  --hostname=ubuntu-test
```

### Пояснение параметров:

|Параметр|Назначение|
|---|---|
|`--ciuser`|Имя пользователя, которое создаст Cloud-Init|
|`--cipassword`|Пароль этого пользователя|
|`--sshkey`|Публичный SSH-ключ|
|`--ipconfig0`|Сетевые настройки интерфейса `net0`|
|`--hostname`|Имя хоста|

---

## 📋 Проверка

1. Запусти VM:
    
    ```bash
    qm start 101
    ```
    
2. Подключись через SSH:
    
    ```bash
    ssh ansible@192.168.122.101
    ```
    

---

## ✨ Пример Cloud-Init конфигурации (опционально)

Если хочешь указать кастомный **user-data**:

```bash
qm set 101 --cicustom "user=local:snippets/my-user.yaml"
```

А файл `my-user.yaml` может быть таким:

```yaml
#cloud-config
hostname: test-vm
users:
  - name: ansible
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    ssh_authorized_keys:
      - ssh-rsa AAAAB3...
```

---

## ✅ Результат

Ты получаешь шаблон, из которого можно **массово и быстро клонировать** виртуальные машины с уникальными параметрами: именами, IP, паролями и SSH-доступом.

---

### 📎 A. Как задать скрипт, который будет выполняться после старта VM через cloud-init?

### 📎 B. Как использовать внешний `user-data` и `meta-data` для CI?

### 📎 C. Как передать сразу сетевой интерфейс через DHCP без указания IP вручную?