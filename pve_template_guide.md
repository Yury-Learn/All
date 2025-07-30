
# 📘 Руководство: Создание шаблона виртуальной машины с Cloud-Init в Proxmox VE

## 1. 📦 Создание виртуальной машины

1. В Web-интерфейсе Proxmox нажмите **Create VM**
2. Укажите:
   - **ID**: 131 (пример)
   - **Name**: `ubuntu-template`
   - **ISO Image**: выберите ISO-дистрибутив (например, `ubuntu-22.04`)
3. Настрой:
   - **System → Machine**: `q35`
   - **BIOS**: `OVMF (UEFI)` или `SeaBIOS`
   - **Graphics**: `Serial0`
   - **SCSI Controller**: `VirtIO SCSI`
   - **Disk**: `scsi0`, тип `qcow2`, хранилище (например `SAS_storage`)
   - **Network Model**: `VirtIO (paravirtualized)`
4. Установите ОС.

## 2. 🛠 Настройка внутри VM

После установки войди в VM через консоль/SSH и выполни:

```bash
sudo apt update && sudo apt install -y qemu-guest-agent cloud-init
sudo systemctl enable --now qemu-guest-agent
sudo cloud-init clean
sudo rm -f /etc/ssh/ssh_host_*
sudo rm -f /etc/machine-id && sudo touch /etc/machine-id
history -c
```

## 3. 🧊 Завершение подготовки и остановка

```bash
sudo shutdown now
```

## 4. 🔧 Добавление Cloud-Init диска

```bash
qm set 131 --ide2 SAS_storage:cloudinit
qm set 131 --boot c --bootdisk scsi0
qm set 131 --serial0 socket --vga serial0
qm set 131 --agent enabled=1
```

## 5. 🧬 Преобразование в шаблон

```bash
qm template 131
```

## 6. 📥 Клонирование из шаблона

```bash
qm clone 131 200 --name ubuntu-vm200 --full
```

Или:

```bash
qm clone 131 201 --name ubuntu-vm201 --linked
```

## 7. ⚙ Настройка Cloud-Init параметров

```bash
qm set 200 \
  --ciuser=devops \
  --cipassword=Secret123 \
  --ipconfig0="ip=192.168.10.200/24,gw=192.168.10.1" \
  --hostname=ubuntu-vm200 \
  --sshkey="$(cat ~/.ssh/id_rsa.pub)"
```

## 8. 🚀 Запуск VM

```bash
qm start 200
```

## 🧾 Сводная таблица команд

| Действие                    | Команда                                                                 |
|-----------------------------|-------------------------------------------------------------------------|
| Установка агентов           | `apt install cloud-init qemu-guest-agent`                              |
| Добавить Cloud-Init диск    | `qm set <VMID> --ide2 ...`                                             |
| Установить boot-параметры   | `qm set <VMID> --boot c --bootdisk scsi0`                              |
| Включить агент              | `qm set <VMID> --agent enabled=1`                                      |
| Преобразовать в шаблон      | `qm template <VMID>`                                                   |
| Клонировать VM              | `qm clone <TEMPLATE_VMID> <NEW_VMID> --name <name> [--full|--linked]` |
| Настроить cloud-init        | `qm set <VMID> --ciuser --ipconfig0=...`                               |
| Запустить VM                | `qm start <VMID>`                                                      |

## 🧠 Полезные советы

- **Linked clone** — экономит место, но зависит от шаблона.
- **Full clone** — полностью автономен, занимает больше места.
- Убедись, что VM использует **VirtIO** для сети и дисков.
- Можно создать `user-data` YAML-файл и подключить через `--cicustom`.
