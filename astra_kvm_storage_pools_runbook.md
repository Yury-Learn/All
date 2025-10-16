# Методичка: создание и эксплуатация пулов хранения (storage pools) в Astra KVM/libvirt

> Цель: получить надёжную, воспроизводимую схему размещения дисков ВМ и ISO на отдельном диске (`/dev/sdb`) c пулом типа **dir**. Примеры и команды приведены для системного соединения `qemu:///system`.

---

## 0. Предпосылки и оговорки

- **Риски**: операции разметки/форматирования стирают данные на выбранном диске. Проверьте устройство дважды.
- **Права**: пользователь должен иметь доступ к libvirt (обычно через группы `kvm`, `libvirt`, `libvirt-qemu`, `libvirt-admin`).
- **Имена и пути**: в примерах используются:
  - Точка монтирования: `/mnt/data`
  - Каталоги пулов: `/mnt/data/libvirt/images` и `/mnt/data/libvirt/iso`
  - Имена пулов: `images`, `iso`
  - Формат образов по умолчанию: `qcow2`

---

## 1) Подготовка отдельного диска `/dev/sdb`

### 1.1. Инвентаризация и проверка сигнатур
```bash
lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINT /dev/sdb
sudo wipefs -n /dev/sdb   # только посмотреть существующие сигнатуры
```

### 1.2. Разметка GPT и создание раздела на весь диск
```bash
sudo parted -s /dev/sdb mklabel gpt
sudo parted -s /dev/sdb mkpart kvm_data ext4 1MiB 100%
sudo partprobe /dev/sdb
```

### 1.3. Файловая система ext4 с меткой
```bash
sudo mkfs.ext4 -L kvm_data /dev/sdb1
```

### 1.4. Монтирование и автоподключение через `/etc/fstab`
```bash
sudo mkdir -p /mnt/data
sudo mount /dev/sdb1 /mnt/data
sudo blkid /dev/sdb1   # возьмите UUID
```
Вставьте строку в `/etc/fstab` (без кавычек):
```
UUID=<ВАШ-UUID> /mnt/data ext4 defaults,noatime 0 2
```
Проверка:
```bash
sudo umount /mnt/data
sudo mount -a
mount | grep ' /mnt/data '
df -h /mnt/data
```

### 1.5. Каталоги под пулы и права
```bash
sudo mkdir -p /mnt/data/libvirt/{images,iso}
sudo chown -R libvirt-qemu:kvm /mnt/data/libvirt
sudo chmod -R 0775 /mnt/data/libvirt
sudo chmod g+s /mnt/data/libvirt /mnt/data/libvirt/images /mnt/data/libvirt/iso
```

> **Примечание по безопасности (Astra):** при включённых политике/МСК убедитесь, что контекст/метки безопасности позволяют qemu/libvirtd работать с каталогами. Если применяются PDP/МЭЗ, согласуйте уровни доступа.

---

## 2) Создание storage pools в libvirt (тип `dir`)

### 2.1. Проверка доступа к `qemu:///system`
```bash
virsh -c qemu:///system pool-list --all
```

Если получаете отказ, добавьте пользователя в группы и перелогиньтесь:
```bash
sudo usermod -a -G kvm,libvirt,libvirt-qemu,libvirt-admin <user>
```

### 2.2. Определение и запуск пулов `images` и `iso`
```bash
# images -> /mnt/data/libvirt/images
sudo virsh -c qemu:///system pool-define-as images dir - - - - /mnt/data/libvirt/images
sudo virsh -c qemu:///system pool-build images
sudo virsh -c qemu:///system pool-start images
sudo virsh -c qemu:///system pool-autostart images

# iso -> /mnt/data/libvirt/iso
sudo virsh -c qemu:///system pool-define-as iso dir - - - - /mnt/data/libvirt/iso
sudo virsh -c qemu:///system pool-build iso
sudo virsh -c qemu:///system pool-start iso
sudo virsh -c qemu:///system pool-autostart iso
```
Проверка:
```bash
virsh -c qemu:///system pool-list --all
virsh -c qemu:///system pool-info images
virsh -c qemu:///system pool-info iso
```

---

## 3) Базовые операции с томами (volumes)

### 3.1. Создание диска ВМ (qcow2)
```bash
virsh -c qemu:///system vol-create-as images vm-demo.qcow2 20G --format qcow2
virsh -c qemu:///system vol-info --pool images vm-demo.qcow2
virsh -c qemu:///system vol-path --pool images vm-demo.qcow2
qemu-img info "$(virsh -c qemu:///system vol-path --pool images vm-demo.qcow2)"
```

**Продвинуто (скорость записи):**
```bash
# Предвыделение метаданных
qemu-img create -f qcow2 -o preallocation=metadata /mnt/data/libvirt/images/fastdisk.qcow2 50G
# Полная предвыделенная аллокация (занимает сразу весь объём)
qemu-img create -f qcow2 -o preallocation=full /mnt/data/libvirt/images/full50.qcow2 50G
```

### 3.2. ISO в пуле `iso`
Скопируйте ISO в каталог и обновите список:
```bash
# пример: sudo cp /path/to/OS.iso /mnt/data/libvirt/iso/
virsh -c qemu:///system vol-list iso
```

### 3.3. Создание ВМ с использованием пулов (CLI)
```bash
ISO_PATH="$(virsh -c qemu:///system vol-path --pool iso 'AstraLinux.iso')"
DISK_PATH="$(virsh -c qemu:///system vol-path --pool images vm-demo.qcow2)"

sudo virt-install \
  --connect qemu:///system \
  --name vm-demo \
  --memory 4096 --vcpus 2 \
  --disk "path=${DISK_PATH},bus=virtio,format=qcow2" \
  --cdrom "${ISO_PATH}" \
  --network bridge=br0,model=virtio \
  --graphics vnc \
  --os-variant auto \
  --noautoconsole
```
> Замените `bridge=br0` на актуальный мост в вашей системе (например, `br1`/`br26`).

### 3.4. Клоны, копии и проверка
```bash
# Клон внутри того же пула
virsh -c qemu:///system vol-clone --pool images vm-demo.qcow2 vm-demo-clone.qcow2

# «Холодная» копия для бэкапа (ВМ выключена)
virsh -c qemu:///system shutdown vm-demo
cp --sparse=always /mnt/data/libvirt/images/vm-demo.qcow2 /backup/vm-demo_$(date +%F).qcow2

# Проверка целостности
qemu-img check /mnt/data/libvirt/images/vm-demo.qcow2
```

---

## 4) Рекомендации по эксплуатации

- **Структура имен:** `vm-<role>-<env>-<id>.qcow2` (пример: `vm-web-prod-01.qcow2`).
- **Разделение пулов:** держите ISO отдельно от дисков ВМ (как в методичке).
- **Формат qcow2 vs raw:**
  - `qcow2` — снапшоты, тонкое выделение, компрессия (`qemu-img convert -O qcow2 -c`), удобно для общего сценария.
  - `raw` — максимум производительности/простота, но больше места; полезно для высоконагруженных БД/хранилищ.
- **Автозапуск:** включён через `pool-autostart`, не требует ручных действий после перезагрузки.
- **Мониторинг места:** следите за `df -h`, настраивайте алерты; учитывайте overprovisioning при qcow2.
- **Бэкапы:** желательно offline, либо используйте внешние инструменты/координаторы для online-бэкапов (qemu-guest-agent, snapshot + copy-on-write и т.п.).
- **Изоляция и безопасность:** права `libvirt-qemu:kvm`, `0775`, `g+s` — защищают от случайных проблем с доступом. При использовании политик/меток согласовывайте уровни доступа.

---

## 5) Частые проблемы и их решения

### 5.1. `ошибка: доступ запрещён: QEMU` при `pool-define-as`
- Добавьте пользователя в группы: `sudo usermod -a -G kvm,libvirt,libvirt-qemu,libvirt-admin <user>`
- Проверьте права каталогов: владелец `libvirt-qemu:kvm`, режим `0775`, `g+s`.
- Посмотрите логи: `journalctl -u libvirtd -n 100 --no-pager`.

### 5.2. Пул активен, но файлы не видны
- Обновите кэш: `virsh -c qemu:///system pool-refresh images` (или `iso`).
- Проверьте фактический путь и права.

### 5.3. `/etc/fstab` не монтирует `/mnt/data`
- Проверьте синтаксис строки (частая ошибка — лишние кавычки/символы).
- Пример корректной записи: `UUID=<uuid> /mnt/data ext4 defaults,noatime 0 2`.
- `sudo mount -a` и убедитесь, что раздел смонтирован.

### 5.4. Ошибки при создании дисков/томов
- Доступность пула: `virsh pool-info images`.
- Свободное место: `df -h /mnt/data`.
- Права: повторно примените `chown/chmod` на `/mnt/data/libvirt`.

---

## 6) Приложение: полезные команды-шпаргалка

```bash
# Список пулов / томов
virsh -c qemu:///system pool-list --all
virsh -c qemu:///system vol-list images

# Инфо и пути
virsh -c qemu:///system pool-info images
virsh -c qemu:///system vol-info --pool images vm-demo.qcow2
virsh -c qemu:///system vol-path --pool images vm-demo.qcow2

# Создание/удаление
virsh -c qemu:///system vol-create-as images name.qcow2 40G --format qcow2
virsh -c qemu:///system vol-delete --pool images name.qcow2

# Рефреш пула
virsh -c qemu:///system pool-refresh images

# Создание qcow2 напрямую
qemu-img create -f qcow2 /mnt/data/libvirt/images/name.qcow2 40G

# Информация/проверка образа
qemu-img info /mnt/data/libvirt/images/name.qcow2
qemu-img check /mnt/data/libvirt/images/name.qcow2

# Конвертация (с компрессией)
qemu-img convert -O qcow2 -c /path/src.img /mnt/data/libvirt/images/dst.qcow2
```

---

## 7) Заключение

После выполнения шагов у вас настроены два автозагружаемых пула хранения (диски ВМ и ISO) на отдельном диске с корректными правами и удобной схемой эксплуатации. Такой подход упрощает масштабирование, резервное копирование и обслуживание виртуальной инфраструктуры на Astra KVM/libvirt.

