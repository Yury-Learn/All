#virsh #qemu #astra



- `virt-install` по умолчанию **регистрирует** ВМ в libvirt (эквивалент `virsh define`) и сразу её **запускает**.
    
- `virsh define vm.xml` — **зарегистрировать** (сохранить XML в libvirt).
    
- `virsh create vm.xml` — **запустить без регистрации** (временный «транзиентный» домен).
    
- `virsh undefine <vm>` — снять регистрацию (опция `--remove-all-storage` удалит управляемые диски).
    



# 1) Подготовка диска и (опционально) UEFI NVRAM

```bash
# диск ВМ
qemu-img create -f qcow2 /var/lib/libvirt/images/att-vmal1.qcow2 50G

# (если используешь UEFI/OVMF; путь может отличаться в твоей ОС)
# шаблон переменных UEFI обычно /usr/share/OVMF/OVMF_VARS.fd
install -d /var/lib/libvirt/qemu/nvram
cp /usr/share/OVMF/OVMF_VARS.fd /var/lib/libvirt/qemu/nvram/att-vmal1_VARS.fd
```

# 2) Пример XML-домена (bridge `br26`, UEFI, virtio)

Сохрани как `/root/vm-xml/att-vmal1.xml`:

```xml
<domain type='kvm'>
  <name>att-vmal1</name>
  <uuid>REPLACE-WITH-UUID</uuid>
  <memory unit='MiB'>4096</memory>
  <currentMemory unit='MiB'>4096</currentMemory>
  <vcpu placement='static'>2</vcpu>

  <os>
    <type arch='x86_64' machine='q35'>hvm</type>
    <!-- Для UEFI/OVMF: проверь пути OVMF_CODE/OVMF_VARS для твоей ОС -->
    <loader readonly='yes' type='pflash'>/usr/share/OVMF/OVMF_CODE.fd</loader>
    <nvram>/var/lib/libvirt/qemu/nvram/att-vmal1_VARS.fd</nvram>
    <boot dev='hd'/>
  </os>

  <features>
    <acpi/><apic/>
  </features>

  <!-- Лучше всего: host-passthrough -->
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

    <!-- cеть в br26 (VLAN 26 на стороне хоста уже реализован бриджем) -->
    <interface type='bridge'>
      <source bridge='br26'/>
      <model type='virtio'/>
    </interface>

    <graphics type='spice' autoport='yes'/>
    <video><model type='virtio'/></video>
    <memballoon model='virtio'/>

    <!-- qemu-guest-agent (установи агент в госте) -->
    <channel type='unix'>
      <target type='virtio' name='org.qemu.guest_agent.0'/>
    </channel>

    <!-- rng для лучшей энтропии -->
    <rng model='virtio'>
      <backend model='random'>/dev/urandom</backend>
    </rng>

    <input type='tablet' bus='usb'/>
  </devices>
</domain>
```

Замени `REPLACE-WITH-UUID` на реальный UUID:

```bash
uuidgen   # скопируй и вставь в XML
```

> Если нужен BIOS (legacy), просто **удали** из XML блоки `<loader>` и `<nvram>`.

# 3) Зарегистрировать и запустить

```bash
# зарегистрировать в libvirt
virsh define /root/vm-xml/att-vmal1.xml

# проверить, что в списке определённых доменов
virsh list --all

# запустить
virsh start att-vmal1

# настроить автозапуск при старте хоста
virsh autostart att-vmal1
```

# 4) Альтернатива: временный запуск без регистрации

```bash
virsh create /root/vm-xml/att-vmal1.xml   # запустит, но в libvirt не сохранит
# захотелось сохранить — дампни и «define»:
virsh dumpxml att-vmal1 > /root/vm-xml/att-vmal1.saved.xml
virsh define /root/vm-xml/att-vmal1.saved.xml
```

# 5) Ещё полезное по XML

- Редактирование зарегистрированной ВМ:
    
    ```bash
    export EDITOR=vi
    virsh edit att-vmal1
    ```
    
- Проверка устройств:
    
    ```bash
    virsh domiflist att-vmal1
    virsh domblklist att-vmal1 --details
    ```
    
- Снятие регистрации (с опциональным удалением управляемых дисков):
    
    ```bash
    virsh shutdown att-vmal1
    virsh undefine att-vmal1 --remove-all-storage --nvram --managed-save --snapshots-metadata
    ```
    
