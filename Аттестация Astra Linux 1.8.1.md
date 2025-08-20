# Prompt
## Подготовка
Новый проект "Виртуализация KVM на сервере с ОС Astra Linux 1.8"

1. Создай план по шагам по внедрению нашего проекта

2. Должно быть 3 одинаковых ВМ с Astra Linux 1.8 , 2 ВМ Debian 12 с установленным docker docker-compose.

3. Каждая ВМ будет иметь по 2 ядра 4 ОЗУ , настройки hdd по 50Gb, lvm , на папку home 5 Gb

4. hostname ВМ на Astra Linux att-vmal1 - 3 .ksb.local на Debian 12 att-vmd1 -2 .ksb.local
   ip ВМ 10.38.26.80-84/24 gw 10.38.26.1 dns 10.38.22.4

5.  hostname сервера att-al18.ksb.local ip 10.38.22.156/24
6. сеть 22.0/24 и 26.0/24 видят друг друга

Спрашивай любую информацию которая тебе пригодиться

## Информация

1. **Роли ВМ** - тестирование
2. **Тип виртуализации** – будем использовать **KVM напрямую** (через `libvirt`, `virt-manager`, `virsh`)
3. **Хранилище для ВМ** – На локальном диске сервера (LVM, qcow2)
4. **Доступ** – нужно ли обеспечить удалённое управление через Cockpit/virt-manager/VNC/
5. **Резервное копирование** – закладываем ли сразу план по бэкапам ВМчерез `virsh snapshot`
   
Нужен **подробный пошаговый гайд с командами** (например `virt-install ...`, `lvcreate ...`, конфиги сети и т.д.
  
## Установка


2.1 Загрузить модуль 8021q:

`echo 8021q | sudo tee /etc/modules-load.d/8021q.conf sudo modprobe 8021q`

2.2 Конфиг `/etc/network/interfaces.d/br26`:

```
sudo tee /etc/network/interfaces.d/br26 >/dev/null <<'EOF' # Uplink без адреса auto eno1 iface eno1 inet manual  # VLAN 26 без адреса auto eno1.26 iface eno1.26 inet manual     vlan-raw-device eno1  # Bridge для ВМ (L2-only) auto br26 iface br26 inet manual     bridge_ports eno1.26     bridge_stp off     bridge_fd 0     bridge_maxwait 0 EOF
```

2.3 Применение:

`sudo ifdown eno1 2>/dev/null || true sudo ifup eno1 sudo ifup eno1.26 sudo ifup br26 brctl show`

## XML

[[XML for Att.xml]]

- меняем имя диск путь_к_iso
- настраиваем поле <graphics> 
