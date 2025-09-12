# Руководство: развёртывание Astra.IDE через импорт готового диска (QEMU/KVM)



---

## 1) Требования и подготовка хоста

- Astra Linux SE 1.8 (или совместимая), с установленными средствами виртуализации:
    
    ```bash
    sudo apt update
    sudo apt -y install qemu-kvm libvirt-daemon-system libvirt-clients virt-manager ovmf p7zip-full libguestfs-tools
    sudo systemctl enable --now libvirtd
    ```
    
- Пользователь состоит в группах: `kvm`, `libvirt`, `libvirt-admin`, `libvirt-qemu` (после добавления — перелогиниться):
    
    ```bash
    sudo usermod -aG kvm,libvirt,libvirt-admin,libvirt-qemu $USER
    ```
    
    Роль/группы для работы с libvirt в Astra описаны в оф. базе знаний. ([Astra Linux](https://wiki.astralinux.ru/brest/2.9/ald-227545766.html?utm_source=chatgpt.com "ALD"))
    
- Поддержка UEFI (OVMF) для ВМ — пакеты OVMF входят в состав Astra; используем прошивку UEFI при необходимости. ([Astra Linux](https://wiki.astralinux.ru/download/attachments/263053568/1.7.4_Ruk_KSZ_1.pdf?api=v2&modificationDate=1684313216788&version=3&utm_source=chatgpt.com "Руководство по КСЗ. Часть 1. РУСБ.10015-01 97 01-1"))
    

---

## 2) Создание системного storage-pool и размещение образа

1. Создайте и запустите **system**-pool `default` в стандартном каталоге:
    
    ```bash
    sudo mkdir -p /var/lib/libvirt/images
    sudo chown -R libvirt-qemu:kvm /var/lib/libvirt/images
    sudo chmod 0755 /var/lib/libvirt/images
    
    sudo virsh -c qemu:///system pool-define-as default dir - - - - "/var/lib/libvirt/images"
    sudo virsh -c qemu:///system pool-start default
    sudo virsh -c qemu:///system pool-autostart default
    sudo virsh -c qemu:///system pool-list --all
    ```
    
    (Работа c пулами/томами — штатный механизм libvirt в Astra; использование OVMF для UEFI описано в руководствах по QEMU/KVM.) ([Astra Linux](https://wiki.astralinux.ru/spaces/flyingpdf/pdfpageexport.action?pageId=3277699&utm_source=chatgpt.com "QEMU/KVM Astra Linux"))
    
2. Распакуйте архив с образом и переименуйте том понятным именем:
    
    ```bash
    sudo 7z x "/home/ksb/linux_wine_epsilon1.6.7z" -o/var/lib/libvirt/images
    sudo mv /var/lib/libvirt/images/linux-wine-epsilon1.6.qcow2 /var/lib/libvirt/images/astraide.qcow2
    sudo chown libvirt-qemu:kvm /var/lib/libvirt/images/astraide.qcow2
    sudo chmod 0644 /var/lib/libvirt/images/astraide.qcow2
    sudo virsh -c qemu:///system pool-refresh default
    sudo virsh -c qemu:///system vol-list default
    ```
    

---

## 3) Определение режима загрузки (UEFI или BIOS)

Проверьте разметку импортируемого диска:

```bash
sudo virt-filesystems -a /var/lib/libvirt/images/astraide.qcow2 -l
```

- Если присутствует маленький **vfat**-раздел (ESP ~100–600 МБ) — образ рассчитан на **UEFI** и нужно использовать OVMF. В Astra приводятся типовые пути OVMF (формат файлов может быть `.qcow2` или `.fd` в зависимости от сборки):  
    `x86-64: /usr/share/OVMF/OVMF_CODE_4M.(qcow2|fd)` и `…/OVMF_VARS_4M.(qcow2|fd)`. ([Astra Linux](https://wiki.astralinux.ru/spaces/flyingpdf/pdfpageexport.action?pageId=3277699&utm_source=chatgpt.com "QEMU/KVM Astra Linux"))
    
- Если ESP нет — загрузка в режиме **BIOS** (SeaBIOS по умолчанию).
    

---

## 4) Импорт диска и создание ВМ в **virt-manager** (GUI)

1. Откройте **virt-manager** → подключение **QEMU/KVM — System**.
    
2. «Создать новую ВМ» → **Импорт существующего диска** → **Browse → Volumes** → выберите **pool `default` → `astraide.qcow2`** (не «Custom path»).
    
3. Выберите тип ОС: Linux/Astra/Debian.
    
4. Ресурсы по проекту: **CPU: 4**, **RAM: 8192 MB**.
    
5. Отметьте **Customize configuration before install** → **Begin Installation**.
    
6. В настройках домена:
    
    - **Overview**: **Chipset = Q35**.  
        Если в п.3 обнаружен ESP — **Firmware = UEFI (OVMF)**, Secure Boot **Off**. В Astra отдельно описаны особенности UEFI-ВМ и внутренние снапшоты. ([Astra Linux](https://wiki.astralinux.ru/pages/viewpage.action?pageId=3277425&utm_source=chatgpt.com "Виртуализация QEMU/KVM в Astra Linux"))
        
    - **Boot Options**: включите **Boot Menu**, первым **Hard Disk**.
        
    - **Disk** (`astraide.qcow2`): **Bus type = SATA** (это надёжнее для импортированных образов, ожидающих `/dev/sda`).
        
    - **NIC**: сеть `default` (NAT), **model = virtio**.
        
    - **Display**: **SPICE** (по умолчанию).
        
    - **Channel**: добавьте **org.qemu.guest_agent.0** (VirtIO serial), если его нет. (Назначение `qemu-guest-agent` в Astra подробно описано в KB.) ([Astra Linux](https://wiki.astralinux.ru/kb/naznachenie-optsii-qemu-guest-agent-v-parametrah-vm-191108448.html?utm_source=chatgpt.com "Назначение опции qemu-guest-agent в параметрах ВМ"))
        

---

## 5) Первый запуск и типовые исправления загрузки

- Если ВМ стартует — отлично, переходите к шагу 6.
    
- Если видите `grub>`/чёрный экран при UEFI:
    
    1. В консоли `grub>` попробуйте подцепить конфигурацию:
        
        ```
        ls
        ls (hd0,gpt3)/boot/grub/
        configfile (hd0,gpt3)/boot/grub/grub.cfg
        ```
        
    2. Если не помогает — загрузитесь с ISO Astra/Debian в **Rescue**, выполните `chroot` и переустановите загрузчик (UEFI-вариант):
        
        ```bash
        mount /dev/sda3 /mnt
        mkdir -p /mnt/boot/efi
        mount /dev/sda2 /mnt/boot/efi
        mount --bind /dev /mnt/dev
        mount --bind /proc /mnt/proc
        mount --bind /sys /mnt/sys
        chroot /mnt
        grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=linux
        update-grub
        exit
        sync
        ```
        
    
    В Astra есть официальная памятка по устранению отказов запуска UEFI-ВМ (с нюансами OVMF/NVRAM). ([Astra Linux](https://wiki.astralinux.ru/pages/viewpage.action?pageId=339484309&utm_source=chatgpt.com "Устранение отказов запуска виртуальных машин UEFI в ..."))
    

---

## 6) Интеграция с хостом: гостевой агент и SPICE

Внутри гостя установите агент и SPICE-клиентские компоненты:

```bash
sudo apt update
sudo apt -y install qemu-guest-agent spice-vdagent
sudo systemctl enable --now qemu-guest-agent
```

Для «горячих» операций (бэкапы, корректная остановка, получение IP адресов) наличие `qemu-guest-agent` — требование из руководств Astra. ([Astra Linux](https://wiki.astralinux.ru/pages/viewpage.action?pageId=53644617&utm_source=chatgpt.com "\"Горячее\" резервное копирование виртуальных машин ..."))

На хосте можно получить IP ВМ:

```bash
sudo virsh -c qemu:///system domifaddr astraide
```

---

## 7) (Опционально) Оптимизация производительности диска

После стабильной загрузки гостя переведите диск на **VirtIO**/**VirtIO-SCSI**:

1. Внутри гостя добавьте модули в initramfs:
    

```bash
echo -e "virtio_blk\nvirtio_pci\nvirtio_scsi\nvirtio_net" | sudo tee /etc/initramfs-tools/modules
sudo update-initramfs -u
sudo update-grub
```

2. Выключите ВМ и в **virt-manager** поменяйте **Bus type** на **VirtIO** (или подключите через контроллер **VirtIO SCSI**).  
    (Использование UEFI-прошивок OVMF и параметры загрузки для virt-install/virt-manager приводятся в оф. руководствах по QEMU/KVM от Astra.) ([Astra Linux](https://wiki.astralinux.ru/spaces/flyingpdf/pdfpageexport.action?pageId=3277699&utm_source=chatgpt.com "QEMU/KVM Astra Linux"))
    

---

## 8) Снимки, резервное копирование и обслуживание

- **Внутренние снимки** для UEFI-ВМ поддерживаются при использовании подходящих OVMF-прошивок; см. официальные рекомендации. ([Astra Linux](https://wiki.astralinux.ru/pages/viewpage.action?pageId=3277425&utm_source=chatgpt.com "Виртуализация QEMU/KVM в Astra Linux"))
    
- **Горячее резервное копирование**: убедитесь, что в госте активен `qemu-guest-agent` (см. шаг 6), затем применяйте ваши средства бэкапа согласно политике; в Astra есть заметка с ключевыми условиями. ([Astra Linux](https://wiki.astralinux.ru/pages/viewpage.action?pageId=53644617&utm_source=chatgpt.com "\"Горячее\" резервное копирование виртуальных машин ..."))
    

---

## 9) Типовые ошибки и решения

- **«access denied: QEMU» при операциях libvirt**  
    Убедитесь, что используете подключение **`qemu:///system`** (а не session) и пользователь состоит в группах `kvm`, `libvirt`, `libvirt-admin`, `libvirt-qemu`. Политики доступа и групповые роли задокументированы в Astra (ALD/KB). ([Astra Linux](https://wiki.astralinux.ru/brest/2.9/ald-227545766.html?utm_source=chatgpt.com "ALD"))
    
- **UEFI-ВМ не стартует, OVMF/NVRAM**  
    Проверьте соответствие прошивок OVMF (CODE/VARS), при необходимости пересоздайте файл NVRAM и/или выполните восстановление загрузчика в госте (см. раздел 5 и памятку по отказам UEFI-запуска). ([Astra Linux](https://wiki.astralinux.ru/pages/viewpage.action?pageId=339484309&utm_source=chatgpt.com "Устранение отказов запуска виртуальных машин UEFI в ..."))
    
- **Не видно IP/«чистое» выключение**  
    Установите и запустите `qemu-guest-agent` в госте (см. раздел 6). ([Astra Linux](https://wiki.astralinux.ru/kb/naznachenie-optsii-qemu-guest-agent-v-parametrah-vm-191108448.html?utm_source=chatgpt.com "Назначение опции qemu-guest-agent в параметрах ВМ"))
    

---

## 10) Краткий чек-лист запуска

1. `libvirtd` запущен, пользователь в нужных группах. ([Astra Linux](https://wiki.astralinux.ru/brest/2.9/ald-227545766.html?utm_source=chatgpt.com "ALD"))
    
2. `default` storage-pool создан и **system**-уровня. ([Astra Linux](https://wiki.astralinux.ru/spaces/flyingpdf/pdfpageexport.action?pageId=3277699&utm_source=chatgpt.com "QEMU/KVM Astra Linux"))
    
3. Образ распакован как `astraide.qcow2` в `/var/lib/libvirt/images`.
    
4. Разметка проверена (`virt-filesystems`), выбран режим **UEFI (OVMF)** или **BIOS**. ([Astra Linux](https://wiki.astralinux.ru/spaces/flyingpdf/pdfpageexport.action?pageId=3277699&utm_source=chatgpt.com "QEMU/KVM Astra Linux"))
    
5. ВМ создана в **virt-manager**: Chipset **Q35**, Disk **SATA**, NIC **virtio**, Display **SPICE**, Guest Agent **включён**. ([Astra Linux](https://wiki.astralinux.ru/kb/naznachenie-optsii-qemu-guest-agent-v-parametrah-vm-191108448.html?utm_source=chatgpt.com "Назначение опции qemu-guest-agent в параметрах ВМ"))
    
6. При необходимости выполнено восстановление GRUB (UEFI) по памятке. ([Astra Linux](https://wiki.astralinux.ru/pages/viewpage.action?pageId=339484309&utm_source=chatgpt.com "Устранение отказов запуска виртуальных машин UEFI в ..."))
    
7. (Опционально) Перевод диска на **VirtIO/virtio-scsi** после обновления initramfs. ([Astra Linux](https://wiki.astralinux.ru/spaces/flyingpdf/pdfpageexport.action?pageId=3277699&utm_source=chatgpt.com "QEMU/KVM Astra Linux"))
    

---

### Приложение A. Полезные команды

```bash
# список доменов и IP (требует qemu-guest-agent)
sudo virsh -c qemu:///system list --all
sudo virsh -c qemu:///system domifaddr astraide

# просмотр XML с прошивкой/загрузкой
sudo virsh -c qemu:///system dumpxml astraide | sed -n '1,160p'

# инфо об образе
sudo qemu-img info /var/lib/libvirt/images/astraide.qcow2

# быстрая копия (если поддерживается reflink)
sudo cp --reflink=auto /var/lib/libvirt/images/astraide.qcow2 /var/lib/libvirt/images/astraide.bak.qcow2
```

---

### Примечание по документации

- **UEFI/OVMF, virt-install/virt-manager, пути прошивок и особенности UEFI-ВМ** — официальные материалы Astra по QEMU/KVM. ([Astra Linux](https://wiki.astralinux.ru/spaces/flyingpdf/pdfpageexport.action?pageId=3277699&utm_source=chatgpt.com "QEMU/KVM Astra Linux"))
    
- **UEFI-ВМ и внутренние снимки, работа с OVMF** — заметка в базе знаний Astra. ([Astra Linux](https://wiki.astralinux.ru/pages/viewpage.action?pageId=3277425&utm_source=chatgpt.com "Виртуализация QEMU/KVM в Astra Linux"))
    
- **Роли/группы виртуализации** — ALD/KB Astra. ([Astra Linux](https://wiki.astralinux.ru/brest/2.9/ald-227545766.html?utm_source=chatgpt.com "ALD"))
    
- **qemu-guest-agent: назначение и горячее резервное копирование** — статьи KB Astra. ([Astra Linux](https://wiki.astralinux.ru/kb/naznachenie-optsii-qemu-guest-agent-v-parametrah-vm-191108448.html?utm_source=chatgpt.com "Назначение опции qemu-guest-agent в параметрах ВМ"))
    

---

4  sudo apt install astra-kvm
    5  sudo usermod -a -G libvirt-admin $USER
    6  sudo usermod -a -G kvm,libvirt,libvirt-qemu,libvirt-admin root
    7  sudo usermod -a -G kvm,libvirt,libvirt-qemu,libvirt-admin administrator
    8  exec su - $USER
    9  sudo systemctl status libvirtd

   12  sudo usermod -aG kvm,libvirt,libvirt-admin,libvirt-qemu $USER

ls /var/lib/libvirt/
ls -ld /var/lib/libvirt/
ls -ld /var/lib/libvirt/images/
sudo chown -R libvirt-qemu:kvm /var/lib/libvirt/images
sudo chmod 0755 /var/lib/libvirt/images
sudo virsh -c qemu:///system pool-define-as default dir - - - - "/var/lib/libvirt/images"
sudo virsh -c qemu:///system pool-start default
sudo virsh -c qemu:///system pool-autostart default
sudo virsh -c qemu:///system pool-list --all
sudo 7z x "/home/administrator/linux_wine_epsilon1.6.7z" -o/var/lib/libvirt/images/
sudo mv /var/lib/libvirt/images/linux-wine-epsilon1.6.qcow2 /var/lib/libvirt/images/astraide.qcow2
sudo chown libvirt-qemu:kvm /var/lib/libvirt/images/astraide.qcow2
sudo chmod 0644 /var/lib/libvirt/images/astraide.qcow2
sudo virsh -c qemu:///system pool-refresh default
sudo virsh -c qemu:///system vol-list default
