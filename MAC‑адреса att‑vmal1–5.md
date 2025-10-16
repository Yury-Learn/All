# MAC‑адреса att‑vmal1–5 — техническая памятка (25.09.2025)

Документ фиксирует замену MAC‑адресов на виртуальных машинах **att‑vmal1…5**, описывает последовательность действий, проверки, траблшутинг и откат.

---

## 1. Область применения и цель

- **Цель:** безопасно поменять MAC‑адреса NIC внутри определений доменов libvirt и убедиться в работоспособности сети после изменений.
    
- **Затронутые ВМ:** att‑vmal1, att‑vmal2, att‑vmal3, att‑vmal4, att‑vmal5.
    
- **Ожидаемый результат:** у каждой ВМ установлен новый MAC, сеть поднимается автоматически, связность подтверждена, изменения задокументированы.
    

## 2. Среда

- Гипервизор: **att‑al18**, libvirt/KVM (`qemu:///system`).
    
- Сеть хоста: мост **br1** (физический порт **eno1**), VLAN: 310/320/330/340/350/360 (NetworkManager).
    
- Модель NIC в ВМ: **virtio**.
    
- Libvirt‑сеть `default`: **не активна** (не используется).
    

## 3. Обозначения (плейсхолдеры)

- `<IFACE>` — **имя сетевого интерфейса** в гостевой ОС (например, `enp1s0`, `ens3`). Узнать: `ip -br link`.
    
- `<PROFILE>` — **имя профиля NetworkManager** (например, `Проводное соединение 1`). Узнать: `nmcli -f NAME,UUID,TYPE,DEVICE,STATE con show` (колонка **NAME**; привязка к устройству — колонка **DEVICE**).
    
- `<gateway>` — шлюз соответствующей /28‑сети ВМ (см. таблицу ниже).
    

## 4. Новые соответствия IP ↔ VM ↔ MAC

|VM|IP (маска /28)|Новый MAC|Шлюз|
|---|---|---|---|
|att‑vmal1|172.19.2.2|**52:54:00:A4:A2:D0**|172.19.2.1|
|att‑vmal2|172.19.3.2|**52:54:00:58:1D:E9**|172.19.3.1|
|att‑vmal3|172.19.4.2|**52:54:00:91:85:FA**|172.19.4.1|
|att‑vmal4|172.19.5.2|**52:54:00:9E:D6:5D**|172.19.5.1|
|att‑vmal5|172.19.6.2|**52:54:00:D4:A8:8F**|172.19.6.1|

> Все адреса принадлежат диапазону QEMU (52:54:00:xx:xx:xx) и уникальны.

---

## 5. План изменений (высокоуровневый)

1. Снять бэкап XML каждого домена (`virsh dumpxml`).
    
2. Поочерёдно остановить ВМ (`virsh shutdown`).
    
3. В `virsh edit <vm>` заменить значение `<mac address='…'>` в секции `<interface …>`.
    
4. Запустить ВМ, проверить на хосте (libvirt) и внутри гостя (IP/MAC/пинг шлюза).
    
5. Повторить для всех ВМ. Зафиксировать изменения в инвентаризации.
    

---

## 6. Команды (на хосте **att‑al18**)

### 6.1 Бэкап XML

```bash
BACKUP_DIR="/root/vm-xml/backup_$(date +%F_%H%M)"; mkdir -p "$BACKUP_DIR"
for vm in att-vmal1 att-vmal2 att-vmal3 att-vmal4 att-vmal5; do
  virsh -c qemu:///system dumpxml "$vm" > "$BACKUP_DIR/${vm}.xml";
done
```

### 6.2 Замена MAC (шаблон на одну ВМ)

```bash
VM=att-vmalX
NEWMAC=52:54:00:AA:BB:CC

virsh -c qemu:///system shutdown "$VM"
virsh -c qemu:///system edit "$VM"   # заменить <mac address='…'> на $NEWMAC в секции <interface type='bridge'>
virsh -c qemu:///system start "$VM"
virsh -c qemu:///system domiflist "$VM"  # столбец MAC должен показать $NEWMAC
```

### 6.3 Верификация (хост и гость)

**На хосте:**

```bash
virsh -c qemu:///system domiflist att-vmal1
virsh -c qemu:///system domiflist att-vmal2
virsh -c qemu:///system domiflist att-vmal3
virsh -c qemu:///system domiflist att-vmal4
virsh -c qemu:///system domiflist att-vmal5
```

**Внутри гостя (пример):**

```bash
ip -br link
ip -br a
ping -c3 <gateway>
```

### 6.4 Быстрая проверка всех ВМ (хост)

```bash
# ожидания
declare -A want=(
  [att-vmal1]=52:54:00:A4:A2:D0
  [att-vmal2]=52:54:00:58:1D:E9
  [att-vmal3]=52:54:00:91:85:FA
  [att-vmal4]=52:54:00:9E:D6:5D
  [att-vmal5]=52:54:00:D4:A8:8F
)

ok=1
for vm in "${!want[@]}"; do
  have=$(virsh -c qemu:///system domiflist "$vm" | awk 'NR>2 && NF{print $5; exit}')
  printf "%-10s have=%s  want=%s\n" "$vm" "$have" "${want[$vm]}"
  [[ "${have,,}" == "${want[$vm],,}" ]] || ok=0
done
[[ $ok -eq 1 ]] && echo "==> MAC совпадают у всех ВМ" || echo "==> ВНИМАНИЕ: есть расхождения"
```

**FDB моста (появится после трафика):**

```bash
bridge fdb show br br1 | egrep -i '52:54:00:(a4:a2:d0|58:1d:e9|91:85:fa|9e:d6:5d|d4:a8:8f)' || echo "ОК: записи появятся после трафика"
```

---

## 7. Траблшутинг (после замены)

### 7.1 Нет пинга сразу после старта

- Подождать 30–120 сек (обновление ARP/таблиц коммутатора/шлюза).
    
- «Толкнуть» исходящим трафиком: `ping <gateway>` или `arping <gateway>`.
    

### 7.2 Sticky/Port‑Security на коммутаторе

- Очистить/обновить привязки MAC на порту uplink к **eno1/br1**.
    

### 7.3 Привязка MAC внутри гостя

- **NetworkManager (NM):**
    
    ```bash
    # Показать все профили и их привязку
    nmcli -f NAME,UUID,TYPE,DEVICE,STATE con show
    
    # Удалить клон‑MAC, если он задан
    nmcli con mod "<PROFILE>" 802-ethernet.cloned-mac-address ""
    
    # Убедиться, что профиль привязан к имени интерфейса, а не к MAC
    nmcli con mod "<PROFILE>" connection.interface-name <IFACE>
    
    # Применить изменения
    nmcli con down "<PROFILE>"; nmcli con up "<PROFILE>"
    # При необходимости: systemctl restart NetworkManager
    ```
    
- **ifupdown (Debian/старые Astra):** убрать `hwaddress ether …` из `/etc/network/interfaces`, затем `ifdown <IFACE> || true; ifup <IFACE>` или `systemctl restart networking`.
    
- **Netplan (Ubuntu/Debian c netplan):** удалить `macaddress:` в `/etc/netplan/*.yaml`, затем `netplan generate && netplan apply`.
    
- **RHEL‑подобные (ifcfg‑*):** удалить `HWADDR=`/`MACADDR=` в `/etc/sysconfig/network-scripts/ifcfg-<iface>`, затем `nmcli con reload; nmcli con up "<PROFILE>"` или `systemctl restart NetworkManager`.
    
- **Udev‑правила:**
    
    ```bash
    grep -R "net.*persistent" /etc/udev/rules.d || true
    test -f /etc/udev/rules.d/70-persistent-net.rules && rm -f /etc/udev/rules.d/70-persistent-net.rules
    udevadm control --reload
    # (опционально для Debian‑подобных)
    update-initramfs -u
    ```
    

### 7.4 Имя интерфейса изменилось

```bash
# Узнать новое имя интерфейса
ip -br link

# Вариант A: перепривязать существующий профиль к новому имени (сохраняет IP/DNS)
nmcli con mod "<PROFILE>" connection.interface-name <IFACE>
nmcli con down "<PROFILE>"; nmcli con up "<PROFILE>"

# Вариант B: создать новый профиль с нужной статикой
nmcli con add type ethernet ifname <IFACE> con-name "${IFACE}-static" \
  ipv4.method manual ipv4.addresses 172.19.X.2/28 ipv4.gateway 172.19.X.1 \
  ipv4.dns 8.8.8.8 autoconnect yes
nmcli con up "${IFACE}-static"

# Отладка, если профиль не поднимается
journalctl -u NetworkManager -b --no-pager -n 200
```

---

## 8. Чек‑лист: если интерфейс внезапно переименовался (eth0/ens3/enpXsY)

**Симптомы:** после обновления ядра/драйвера/udev интерфейс получил иное имя; профиль сети не поднимается.

**Цель:** быстро вернуть сеть и зафиксировать стабильное имя.

### 8.1 Быстрый возврат связности (онлайн)

1. Узнать текущее имя: `ip -br link` — это `<IFACE>` (например, `ens3`, `enp1s0`).
    
2. Посмотреть активные профили NM и их привязку: `nmcli -f NAME,UUID,TYPE,DEVICE,STATE con show` — это `<PROFILE>` (например, `Проводное соединение 1`) и его привязка к `<IFACE>`.
    
3. Перепривязать профиль к новому имени (сохранит IP/DNS):
    
    ```bash
    PROF="<PROFILE>"; IFACE="<NEW_IFACE>"
    nmcli con mod "$PROF" connection.interface-name "$IFACE"
    nmcli con down "$PROF"; nmcli con up "$PROF"
    ```
    
4. Если профиль повреждён — создать новый с нужной статикой:
    
    ```bash
    IFACE="<NEW_IFACE>"
    nmcli con add type ethernet ifname "$IFACE" con-name "$IFACE-static" \
      ipv4.method manual ipv4.addresses 172.19.X.2/28 ipv4.gateway 172.19.X.1 \
      ipv4.dns 8.8.8.8 autoconnect yes
    nmcli con up "$IFACE-static"
    ```
    

### 8.2 Почему так случилось (диагностика)

```bash
# Что знает udev/systemd-link про интерфейс
udevadm info /sys/class/net/<IFACE> | sed -n '1,120p'
ls -l /etc/udev/rules.d/
grep -R "NamePolicy\|MACAddress\|Name=\|ATTR{address}" /etc/systemd/network /etc/udev/rules.d -n || true

# Драйвер/логи переименования
ethtool -i <IFACE> 2>/dev/null || true
dmesg | egrep -i "eth|enp|ens|predictable" | tail -n 100
```

### 8.3 Как зафиксировать стабильное имя (любой один способ)

- **A) Только NM (достаточно для ВМ):**
    
    ```bash
    nmcli con mod "<PROFILE>" connection.interface-name <IFACE>
    ```
    
- **B) systemd‑link (устойчиво к апдейтам):** `/etc/systemd/network/10-stable-iface.link`
    
    ```ini
    [Match]
    MACAddress=52:54:00:AA:BB:CC
    
    [Link]
    Name=<IFACE>
    ```
    
    Применить: `udevadm control --reload && udevadm trigger -c add -s net` (или перезагрузка).
    
- **C) udev‑правило (альтернатива B):** `/etc/udev/rules.d/70-net-names.rules`
    
    ```bash
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="52:54:00:AA:BB:CC", NAME="<IFACE>"
    ```
    
- **D) Отключить predictable names (грубый метод, чаще не нужен):** добавить в GRUB параметры `net.ifnames=0 biosdevname=0`, обновить загрузчик, перезагрузиться. Интерфейсы станут `eth0`, `eth1`, …
    

### 8.4 Проверка после фиксации

```bash
ip -br link
nmcli -f NAME,UUID,TYPE,DEVICE,STATE con show
ping -c3 <gateway>
journalctl -b -u systemd-udevd -u NetworkManager --no-pager -n 200
```

### 8.5 Откат

- Удалить созданные `.link`/udev‑rules → `udevadm control --reload && udevadm trigger`.
    
- Вернуть параметры ядра (если менялись) и обновить загрузчик.
    
- В NM вернуть прежний `connection.interface-name`.
    

---

## 9. Откат конфигурации домена из бэкапа XML

1. Остановить ВМ.
    
2. Восстановить определение: `virsh define <backup-xml>`.
    
3. Запустить ВМ и проверить MAC/связность.
    

```bash
VM=att-vmalX
BACKUP_DIR="/root/vm-xml/backup_YYYY-MM-DD_HHMM"
XML="$BACKUP_DIR/${VM}.xml"

virsh -c qemu:///system shutdown "$VM" || true
virsh -c qemu:///system define "$XML"
virsh -c qemu:///system start "$VM"
virsh -c qemu:///system domiflist "$VM"
```

**Примечания:**

- Если домен был удалён, `virsh define "$XML"` создаст его определение заново.
    
- Для UEFI (OVMF) проверьте в XML секцию `<os>/<loader>/<nvram>`: путь к vars‑файлу должен существовать. При ошибке можно временно удалить `<nvram>` и выполнить `define` — libvirt создаст vars по умолчанию.
    
- Убедитесь, что все пути к дискам в XML доступны хосту; при переносе хранилища обновите `<source file='…'>`.
    

---

## 10. История изменений

- **2025‑09‑25** — применены новые MAC на att‑vmal1…5; проверка связности: **OK**.