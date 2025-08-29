
# Методичка: управление виртуализацией KVM/libvirt (virsh, virt-install, XML)

> Актуально для Astra Linux (Debian-семейство), Debian/Ubuntu, RHEL/Alma/Rocky с установленными QEMU/KVM и libvirt.  
> Примеры используют мост `br26` (VLAN 26 уже поднят на хосте) и типовые параметры 2 vCPU / 4 ГБ / 50 ГБ.
>
> Сопутствующая документация: [Рекомендации Astra Linux](https://wiki.astralinux.ru/pages/viewpage.action?pageId=3277425)

## Содержание
1. [Терминология и пакеты](#терминология-и-пакеты)
2. [Быстрый старт (TL;DR)](#быстрый-старт-tldr)
3. [Основные команды управления ВМ (шпаргалка)](#основные-команды-управления-вм-шпаргалка)
4. [Создание ВМ](#создание-вм)
   - [Через ISO (virt-install)](#через-iso-virt-install)
   - [Импорт готового диска](#импорт-готового-диска)
   - [Клонирование и подготовка](#клонирование-и-подготовка)
   - [Cloud-init образ](#cloudinit-образ)
   - [Создание по XML (регистрация/временный запуск)](#создание-по-xml-регистрациявременный-запуск)
5. [Ежедневное управление](#ежедневное-управление)
   - [Жизненный цикл и автозапуск](#жизненный-цикл-и-автозапуск)
   - [Консоль/VNC/SPICE](#консольvncspice)
   - [Изменение ресурсов (vCPU/RAM)](#изменение-ресурсов-vcpuram)
   - [Диски и сети «на лету»](#диски-и-сети-на-лету)
   - [Снимки (snapshots)](#снимки-snapshots)
   - [Инвентаризация и диагностика](#инвентаризация-и-диагностика)
   - [Редактирование XML](#редактирование-xml)
   - [Сервисы libvirt](#сервисы-libvirt)
6. [Удаление ВМ и очистка ресурсов](#удаление-вм-и-очистка-ресурсов)
7. [Сеть и хранилища (кратко)](#сеть-и-хранилища-кратко)
8. [Практические советы и безопасность](#практические-советы-и-безопасность)
9. [Приложение: шаблон XML (UEFI/OVMF)](#приложение-шаблон-xml-uefiovmf)
10. [Приложение: шаблон XML (BIOS/legacy)](#приложение-шаблон-xml-bioslegacy)

---

## Терминология и пакеты

- **Домен** — виртуальная машина (VM) в терминах libvirt.
- **Регистрация ВМ** — сохранение XML в libvirt (`virsh define`).  
  Временный (не зарегистрированный) запуск — `virsh create vm.xml`.
- **Пулы/тома** — storage-пулы и их тома (volumes), управляемые libvirt.
- **Сети** — виртуальные сети libvirt или бриджи хоста (в примерах — `br26`).

### Пакеты (Debian/Astra)
```bash
sudo apt update
sudo apt install -y qemu-kvm libvirt-daemon-system libvirt-clients \
  virtinst virt-manager bridge-utils ovmf cloud-utils \
  libguestfs-tools virt-viewer
```

---

## Быстрый старт (TL;DR)

```bash
# 1) Создать диск
qemu-img create -f qcow2 /var/lib/libvirt/images/al18.qcow2 50G

# 2) Установка из ISO
virt-install --name al18 --memory 4096 --vcpus 2 --cpu host --machine q35 \
  --disk path=/var/lib/libvirt/images/al18.qcow2,format=qcow2,bus=virtio \
  --cdrom /isos/AstraLinux-1.8.iso \
  --network bridge=br26,model=virtio \
  --graphics spice --os-variant debian12

# 3) Базовое управление
virsh list --all
virsh start al18
virsh shutdown al18
virsh autostart al18
```

---

## Основные команды управления ВМ (шпаргалка)

> Ниже — краткий перечень «must know» команд `virsh` для повседневной работы.

### Обзор и состояние
```bash
virsh list --all                 # список ВМ (работающие и остановленные)
virsh dominfo <vm>              # краткая информация о ВМ
virsh domstate <vm>             # состояние (running, shut off, paused...)
```

### Жизненный цикл
```bash
virsh start <vm>                # запуск
virsh shutdown <vm>             # штатное выключение (ACPI)
virsh reboot <vm>               # перезагрузка
virsh destroy <vm>              # принудительное выключение (как «power off»)
virsh suspend <vm>              # пауза (заморозка)
virsh resume <vm>               # снять с паузы
```

### Автозапуск
```bash
virsh autostart <vm>            # включать ВМ при старте хоста
virsh autostart <vm> --disable  # отключить автозапуск
```

### Консоль и графика
```bash
virsh console <vm>              # текстовая консоль (выход: Ctrl+])
virsh vncdisplay <vm>           # VNC-дисплей (:0, :1 ...)
virsh domdisplay <vm>           # SPICE/VNC URI, если использовано
```

### Ресурсы (горячие изменения где поддерживается)
```bash
virsh setvcpus <vm> 2 --live --config   # изменить число vCPU
virsh setmem   <vm> 4G --live --config  # изменить текущую память
virsh setmaxmem <vm> 8G --config        # верхняя граница (для ballooning)
```

### Диски
```bash
virsh domblklist <vm> --details         # какие диски подключены
virsh attach-disk <vm> /path/disk.qcow2 vdb \
  --subdriver qcow2 --targetbus virtio --live --config
virsh detach-disk <vm> vdb --live --config
virsh blockresize <vm> vda 80G          # онлайн-расширение диска устройства vda
```

### Сеть
```bash
virsh domiflist <vm>                    # список NIC
virsh domifaddr <vm>                    # IP адреса (если гость репортит)
virsh attach-interface --domain <vm> --type bridge --source br26 \
  --model virtio --live --config
virsh detach-interface --domain <vm> --type bridge --mac <MAC> \
  --live --config
# (опционально) включить/выключить линк без удаления интерфейса:
virsh domif-setlink <vm> <target> up|down --persistent
```

### Снимки (snapshots)
```bash
virsh snapshot-create-as <vm> pre-upgrade "Перед обновлением"
virsh snapshot-list <vm>
virsh snapshot-revert <vm> pre-upgrade
virsh snapshot-delete <vm> pre-upgrade
```

### Имя, XML и регистрация
```bash
virsh edit <vm>                          # правка XML
virsh dumpxml <vm> > /root/backup.xml    # бэкап XML
virsh define /path/vm.xml                # зарегистрировать ВМ по XML
virsh create /path/vm.xml                # запустить без регистрации (временный)
# Переименование (если поддерживается вашей версией libvirt):
virsh domrename <old> <new>
```

### Удаление
```bash
virsh shutdown <vm>
virsh undefine <vm> \
  --remove-all-storage --nvram --managed-save --snapshots-metadata
```

---

## Создание ВМ

### Через ISO (virt-install)

```bash
# диск ВМ
qemu-img create -f qcow2 /var/lib/libvirt/images/al18.qcow2 50G

# запуск установки
virt-install \
  --name al18 \
  --memory 4096 --vcpus 2 \
  --cpu host --machine q35 \
  --disk path=/var/lib/libvirt/images/al18.qcow2,format=qcow2,bus=virtio \
  --cdrom /isos/AstraLinux-1.8.iso \
  --network bridge=br26,model=virtio \
  --graphics spice \
  --os-variant debian12
```

### Импорт готового диска
```bash
virt-install \
  --name deb12 \
  --memory 4096 --vcpus 2 --cpu host --machine q35 \
  --disk path=/var/lib/libvirt/images/deb12-template.qcow2,format=qcow2,bus=virtio \
  --network bridge=br26,model=virtio \
  --import --graphics spice
```

### Клонирование и подготовка
```bash
virt-clone --original al18 --name al18-clone --auto-clone
# очистка идентификаторов/ключей перед вводом в сеть
virt-sysprep -d al18-clone
```

### Cloud-init образ
```bash
# базовый диск
qemu-img create -f qcow2 /var/lib/libvirt/images/cloudvm.qcow2 20G
qemu-img resize /var/lib/libvirt/images/cloudvm.qcow2 +30G

# seed.iso (user-data/meta-data)
cloud-localds /var/lib/libvirt/images/seed.iso user-data meta-data

virt-install \
  --name cloudvm \
  --memory 4096 --vcpus 2 --cpu host --machine q35 \
  --disk /var/lib/libvirt/images/cloudimg.qcow2,device=disk,bus=virtio \
  --disk /var/lib/libvirt/images/seed.iso,device=cdrom \
  --network bridge=br26,model=virtio \
  --import --graphics none
```

### Создание по XML (регистрация/временный запуск)

**Регистрация:** `virsh define vm.xml`  
**Временный запуск без регистрации:** `virsh create vm.xml`

1) Подготовить диск (и при UEFI — NVRAM):
```bash
qemu-img create -f qcow2 /var/lib/libvirt/images/att-vmal1.qcow2 50G

# UEFI (OVMF) — создаём копию переменных
sudo install -d /var/lib/libvirt/qemu/nvram
sudo cp /usr/share/OVMF/OVMF_VARS.fd /var/lib/libvirt/qemu/nvram/att-vmal1_VARS.fd
```

2) Взять шаблон из раздела «Приложение: XML», сохранить `att-vmal1.xml` и **вписать UUID**:
```bash
uuidgen  # скопировать в <uuid>...</uuid>
```

3) Зарегистрировать и запустить:
```bash
virsh define /root/vm-xml/att-vmal1.xml
virsh start att-vmal1
virsh autostart att-vmal1
```

4) Временный запуск (без регистрации), затем сохранить текущую конфигурацию:
```bash
virsh create /root/vm-xml/att-vmal1.xml
virsh dumpxml att-vmal1 > /root/vm-xml/att-vmal1.saved.xml
virsh define /root/vm-xml/att-vmal1.saved.xml
```

---

## Ежедневное управление

### Жизненный цикл и автозапуск
```bash
virsh start <vm>
virsh shutdown <vm>
virsh reboot <vm>
virsh suspend <vm>; virsh resume <vm>
virsh destroy <vm>                 # эквивалент «выдернуть питание»
virsh autostart <vm>               # включать ВМ при загрузке хоста
virsh autostart <vm> --disable
```

### Консоль/VNC/SPICE
```bash
virsh console <vm>                 # выйти: Ctrl+]
virsh vncdisplay <vm>              # номер VNC для клиента
```

### Изменение ресурсов (vCPU/RAM)
> Флаги: `--live` — немедленно, `--config` — сохранить в XML.
```bash
virsh setvcpus <vm> 2 --live --config
virsh setmem   <vm> 4G --live --config
virsh dominfo  <vm>
```

### Диски и сети «на лету»
```bash
# добавить диск
qemu-img create -f qcow2 /var/lib/libvirt/images/al18-data.qcow2 100G
virsh attach-disk <vm> /var/lib/libvirt/images/al18-data.qcow2 vdb \
  --subdriver qcow2 --targetbus virtio --live --config

# отцепить диск
virsh detach-disk <vm> vdb --live --config

# добавить NIC в br26
virsh attach-interface --domain <vm> --type bridge --source br26 \
  --model virtio --live --config

# отцепить NIC по MAC
virsh detach-interface --domain <vm> --type bridge --mac <MAC> \
  --live --config
```

### Снимки (snapshots)
```bash
virsh snapshot-create-as <vm> pre-upgrade "Перед обновлением"
virsh snapshot-list <vm>
virsh snapshot-revert <vm> pre-upgrade
virsh snapshot-delete <vm> pre-upgrade
```

### Инвентаризация и диагностика
```bash
virsh list --all
virsh domiflist <vm>                   # сетевые интерфейсы
virsh domblklist <vm> --details        # подключённые диски
virsh domifaddr <vm>                   # IP адреса (если гостевой агент/репортинг)
virsh domstats <vm> --vcpu --balloon --block --interface

virsh net-list --all                   # сети libvirt
virsh pool-list --all                  # storage-пулы
virsh vol-list <pool>                  # тома внутри пула
```

### Редактирование XML
```bash
export EDITOR=vi
virsh edit <vm>
```

### Сервисы libvirt
```bash
# классический демон
systemctl status libvirtd

# разнесённые демоны (современные дистрибутивы)
systemctl status virtqemud virtnetworkd virtstoraged
```

---

## Удаление ВМ и очистка ресурсов

```bash
# 1) Проверить и штатно остановить
virsh list --all
virsh dominfo <vm>
virsh shutdown <vm>

# 2) Принудительное выключение (если зависла)
virsh destroy <vm>

# 3) Снять регистрацию и удалить управляемые ресурсы
virsh undefine <vm> \
  --remove-all-storage \
  --nvram \
  --managed-save \
  --snapshots-metadata
```

> **Важно:** если диск/том подключён НЕ из storage-пула libvirt (например, внешний LVM или произвольный файл), его удаляют **отдельно**. Сначала посмотри, что именно подключено:
```bash
virsh domblklist <vm> --details
# затем rm или lvremove для соответствующих путей/томов
```

---

## Сеть и хранилища (кратко)

```bash
# сети
virsh net-list --all
virsh net-info <net>
virsh net-dumpxml <net>

# storage
virsh pool-list --all
virsh pool-info <pool>
virsh vol-list <pool>
```

---

## Практические советы и безопасность

1. **QCOW2 + discard:** в XML для дисков используйте `discard='unmap'` и включайте `fstrim` в гостях по cron/timer — это экономит место на хосте.
2. **CPU:** режим `<cpu mode='host-passthrough'/>` даёт максимум совместимости с текущим хостом.
3. **UEFI/OVMF:** пути до `OVMF_CODE.fd`/`OVMF_VARS.fd` отличаются по дистрибутивам. Проверьте:
   ```bash
   dpkg -L ovmf | egrep 'OVMF_(CODE|VARS).*\.fd$'
   # или
   rpm -ql edk2-ovmf | egrep 'OVMF_(CODE|VARS).*\.fd$'
   ```
4. **Гостевой агент:** установите и запустите `qemu-guest-agent` в гостях, чтобы работали `domifaddr`, quiesce-снимки и аккуратное завершение.
5. **Снапшоты:** перед критичными изменениями делайте snapshot. Для высоконагруженных БД используйте средства БД (fsfreeze, pg_start_backup и т.п.) или внешние бэкапы.
6. **Клонирование:** после `virt-clone` всегда выполняйте `virt-sysprep` (сброс ключей, udev и т.д.) и меняйте hostname/IP.
7. **XML-правки:** делайте бэкап: `virsh dumpxml <vm> > backup.xml` перед `virsh edit`.
8. **Автозапуск:** включайте `virsh autostart` только для нужных ВМ и учитывайте порядок старта сервисов внутри гостя.
9. **Изоляция сети:** для VLAN используйте бриджи/интерфейсы хоста (например, `eno2.26` → `br26`) и подключайте ВМ к соответствующему мосту.

---

## Приложение: шаблон XML (UEFI/OVMF)

```xml
<domain type='kvm'>
  <name>att-vmal1</name>
  <uuid>REPLACE-WITH-UUID</uuid>
  <memory unit='MiB'>4096</memory>
  <currentMemory unit='MiB'>4096</currentMemory>
  <vcpu placement='static'>2</vcpu>

  <os>
    <type arch='x86_64' machine='q35'>hvm</type>
    <loader readonly='yes' type='pflash'>/usr/share/OVMF/OVMF_CODE.fd</loader>
    <nvram>/var/lib/libvirt/qemu/nvram/att-vmal1_VARS.fd</nvram>
    <boot dev='hd'/>
  </os>

  <features>
    <acpi/><apic/>
  </features>

  <cpu mode='host-passthrough'/>
  <clock offset='utc'/>
  <on_poweroff>destroy</on_poweroff>
  <on_reboot>restart</on_reboot>
  <on_crash>restart</on_crash>

  <devices>
    <disk type='file' device='disk'>
      <driver name='qemu' type='qcow2' discard='unmap'/>
      <source file='/var/lib/libvirt/images/att-vmal1.qcow2'/>
      <target dev='vda' bus='virtio'/>
    </disk>

    <interface type='bridge'>
      <source bridge='br26'/>
      <model type='virtio'/>
    </interface>

    <graphics type='spice' autoport='yes'/>
    <video><model type='virtio'/></video>
    <memballoon model='virtio'/>

    <channel type='unix'>
      <target type='virtio' name='org.qemu.guest_agent.0'/>
    </channel>

    <rng model='virtio'>
      <backend model='random'>/dev/urandom</backend>
    </rng>

    <input type='tablet' bus='usb'/>
  </devices>
</domain>
```

**Замены перед `virsh define`:**
- `REPLACE-WITH-UUID` → вывод `uuidgen`
- Пути к `OVMF_CODE.fd`/`VARS.fd` проверьте в вашей ОС

---

## Приложение: шаблон XML (BIOS/legacy)

> Отличается от UEFI-варианта тем, что **нет** блоков `<loader>` и `<nvram>`.

```xml
<domain type='kvm'>
  <name>att-vmal1</name>
  <uuid>REPLACE-WITH-UUID</uuid>
  <memory unit='MiB'>4096</memory>
  <currentMemory unit='MiB'>4096</currentMemory>
  <vcpu placement='static'>2</vcpu>

  <os>
    <type arch='x86_64' machine='q35'>hvm</type>
    <boot dev='hd'/>
  </os>

  <features>
    <acpi/><apic/>
  </features>

  <cpu mode='host-passthrough'/>
  <clock offset='utc'/>
  <on_poweroff>destroy</on_poweroff>
  <on_reboot>restart</on_reboot>
  <on_crash>restart</on_crash>

  <devices>
    <disk type='file' device='disk'>
      <driver name='qemu' type='qcow2' discard='unmap'/>
      <source file='/var/lib/libvirt/images/att-vmal1.qcow2'/>
      <target dev='vda' bus='virtio'/>
    </disk>

    <interface type='bridge'>
      <source bridge='br26'/>
      <model type='virtio'/>
    </interface>

    <graphics type='spice' autoport='yes'/>
    <video><model type='virtio'/></video>
    <memballoon model='virtio'/>

    <channel type='unix'>
      <target type='virtio' name='org.qemu.guest_agent.0'/>
    </channel>

    <rng model='virtio'>
      <backend model='random'>/dev/urandom</backend>
    </rng>

    <input type='tablet' bus='usb'/>
  </devices>
</domain>
```
