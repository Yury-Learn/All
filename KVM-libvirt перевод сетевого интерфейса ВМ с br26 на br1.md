# KVM/libvirt: перевод сетевого интерфейса ВМ с `br26` на `br1`

> **Контекст**: создано 5 ВМ (например, `att-vmal1..5`). На хосте есть мосты `br0` и `br1`. Нужно у всех ВМ, у которых интерфейс пришит к `br26`, перевести его на `br1`.

---

## 1) Предварительные проверки

1. **Проверить наличие мостов и привязку физики**
    
    ```bash
    ip -br link show br0 br1 || true
    brctl show
    ```
    
    Убедитесь, что `br1` **UP** и является master для нужного физического интерфейса (`eno1` в нашем случае).
    
2. **Инвентаризация интерфейсов ВМ**
    
    ```bash
    for vm in att-vmal1 att-vmal2 att-vmal3 att-vmal4 att-vmal5; do
      echo "== $vm =="
      virsh domiflist "$vm"
    done
    ```
    
    Зафиксируйте, где `Source = br26`, а также их MAC — они пригодятся при перевеске.
    
3. **Бэкап XML всех ВМ** (обязательный шаг)
    
    ```bash
    mkdir -p /root/vm-xml-backup
    ts=$(date +%F-%H%M%S)
    for vm in att-vmal1 att-vmal2 att-vmal3 att-vmal4 att-vmal5; do
      virsh dumpxml "$vm" > "/root/vm-xml-backup/${vm}-${ts}.xml"
    done
    ```
    

> ⚠️ **Важно про сети**: если `br26` — это VLAN-сегмент (802.1q), а `br1` — untagged-сегмент, то после перевода ВМ окажутся в **другом L2/L3-сегменте**. Проверьте DHCP, шлюзы, статические маршруты, ACL/файрвол.

---

## 2) Два поддерживаемых способа

### Вариант A — «горячая» перестыковка (без перезагрузки ВМ)

- Отстыковываем интерфейс от `br26` и тут же пристыковываем к `br1` **с тем же MAC**.
    
- Плюсы: простой и быстрый, простой откат, простой контроль.
    
- Минусы: кратковременный (секунды) обрыв линка внутри гостя.
    

### Вариант B — через правку persistent XML + перезапуск ВМ

- Меняем `<source bridge='br26'/>` на `br1` в XML и перезапускаем ВМ.
    
- Плюсы: наглядно и повторяемо.
    
- Минусы: требуется остановка/запуск ВМ.
    

> Рекомендуется начать с **Варианта A** (горячо), при необходимости — прибегнуть к Варианту B.

---

## 3) Вариант A: «горячая» перестыковка (скрипт)

Скрипт:

```bash
#!/usr/bin/env bash
set -euo pipefail

# Список ВМ для обработки (правьте под себя):
VMS=(att-vmal1 att-vmal2 att-vmal3 att-vmal4 att-vmal5)
OLD_BR="br26"
NEW_BR="br1"

# Сухой прогон: показать, что будет сделано
if [[ "${1:-}" == "--dry-run" ]]; then
  for vm in "${VMS[@]}"; do
    mac=$(virsh domiflist "$vm" | awk -v b="$OLD_BR" '$3==b{print $5; exit}') || true
    if [[ -z "${mac:-}" ]]; then
      echo "[DRY] $vm: нет интерфейса на $OLD_BR — пропуск"
    else
      echo "[DRY] $vm: переключу MAC $mac с $OLD_BR на $NEW_BR"
    fi
  done
  exit 0
fi

for vm in "${VMS[@]}"; do
  echo "=== Обрабатываю $vm ==="
  mac=$(virsh domiflist "$vm" | awk -v b="$OLD_BR" '$3==b{print $5; exit}') || true
  if [[ -z "${mac:-}" ]]; then
    echo "  -> У $vm нет интерфейса на $OLD_BR, пропускаю"
    continue
  fi

  echo "  -> Нашёл MAC на $OLD_BR: $mac"
  echo "  -> Detach интерфейса с $OLD_BR (live + config)"
  virsh detach-interface "$vm" bridge --mac "$mac" --live --config

  echo "  -> Attach интерфейса к $NEW_BR с тем же MAC (live + config)"
  virsh attach-interface "$vm" bridge "$NEW_BR" --model virtio --mac "$mac" --live --config

  echo "  -> Проверка текущего состояния:"
  virsh domiflist "$vm" | sed '1!b;h;:a;N;$!ba;g' # показать всю таблицу
  echo

done
```

Как использовать:

```bash
# 1) Сухой прогон (покажет план работ)
./switch-bridge.sh --dry-run

# 2) Выполнить переключение
./switch-bridge.sh
```

Ожидаемое поведение: у каждой ВМ с интерфейсом на `br26` произойдёт detach/attach на `br1` с **тем же MAC**.

---

## 4) Вариант B: правка XML + рестарт ВМ

Простой способ заменить `br26` → `br1` в определении ВМ с дальнейшим перезапуском:

```bash
for vm in att-vmal1 att-vmal2 att-vmal3 att-vmal4 att-vmal5; do
  xml="/root/vm-xml-backup/${vm}-edited.xml"
  virsh dumpxml "$vm" > "$xml"

  # ⚠️ Заменяет все вхождения source bridge='br26' на br1
  # Если у ВМ несколько интерфейсов и только часть должна уйти на br1,
  # используйте xmlstarlet (см. ниже) для точного таргетинга.
  sed -i "s/source bridge='br26'/source bridge='br1'/g" "$xml"

  virsh define "$xml"
  virsh shutdown "$vm"; while [[ "$(virsh domstate "$vm")" != "shut off" ]]; do sleep 1; done
  virsh start "$vm"
  virsh domiflist "$vm"
  echo
done
```

### Точечная замена c `xmlstarlet` (если требуется тонкая настройка)

```bash
# Пример: заменить только тот интерфейс, у которого source/@bridge='br26'
for vm in att-vmal1 att-vmal2 att-vmal3 att-vmal4 att-vmal5; do
  xml="/root/vm-xml-backup/${vm}-edited.xml"
  virsh dumpxml "$vm" > "$xml"
  xmlstarlet ed -P -L \
    -u "/domain/devices/interface[@type='bridge']/source[@bridge='br26']/@bridge" -v "br1" \
    "$xml"
  virsh define "$xml"
  virsh shutdown "$vm"; while [[ "$(virsh domstate "$vm")" != "shut off" ]]; do sleep 1; done
  virsh start "$vm"
  virsh domiflist "$vm"
  echo
done
```

---

## 5) Проверка после перевода

1. **На хосте**: убеждаемся, что `Source` у нужных интерфейсов — `br1`.
    
    ```bash
    for vm in att-vmal1 att-vmal2 att-vmal3 att-vmal4 att-vmal5; do
      echo "== $vm =="
      virsh domiflist "$vm" | awk 'NR==1 || $0 ~ /Name|br1/'
    done
    ```
    
2. **Адреса ВМ** (если установлен guest-agent):
    
    ```bash
    for vm in att-vmal1 att-vmal2 att-vmal3 att-vmal4 att-vmal5; do
      virsh domifaddr "$vm" || true
    done
    ```
    
3. **Сетевая доступность**: пинги/SSH/HTTP в новый сегмент, проверки DHCP/маршрутизации.
    

---

## 6) Откат

- **После варианта A**: выполнить те же команды в обратную сторону (`br1` → `br26`).
    
- **После варианта B**: восстановить из бэкапа XML и перезапустить ВМ:
    
    ```bash
    virsh define /root/vm-xml-backup/att-vmalX-YYYY-MM-DD-HHMMSS.xml
    virsh shutdown att-vmalX; while [[ "$(virsh domstate att-vmalX)" != "shut off" ]]; do sleep 1; done
    virsh start att-vmalX
    ```
    

---

## 7) Частые вопросы и ошибки

- **ВМ не имеет интерфейса на `br26`** — скрипт пропустит такую ВМ.
    
- **Гостевая ОС потеряла сеть после перевода** — проверьте:
    
    - VLAN/untagged несоответствие (сетевой сегмент другой).
        
    - Статические IP и шлюзы в госте.
        
    - DHCP в новом сегменте.
        
- **libvirt/qemu отказывается hot-unplug/hot-plug** — выполните Вариант B (через XML и перезапуск).
    
- **Изменился `vnetX` на хосте** — это нормально: `vnetX` — временные TAP-интерфейсы.
    

---

## 8) Одной строкой для одиночной ВМ (горячо)

```bash
VM=att-vmal1; MAC=$(virsh domiflist "$VM" | awk '$3=="br26"{print $5; exit}'); \
virsh detach-interface "$VM" bridge --mac "$MAC" --live --config && \
virsh attach-interface "$VM" bridge br1 --model virtio --mac "$MAC" --live --config && \
virsh domiflist "$VM"
```

---

## 9) Чек-лист оператора

-  Сделан бэкап XML всех ВМ.
    
-  Подтверждено, что `br1` рабочий (link UP, физика, STP/MTU).
    
-  Выполнен `--dry-run`, список ВМ и MAC проверен.
    
-  Перевод выполнен (A или B), ошибок нет.
    
-  Проверена доступность сервисов ВМ в новом сегменте.
    
-  Зафиксированы изменения в документации/CMDB.
    

---

## 10) Примечания по безопасности и эксплуатационные мелочи

- Сохраняем **тот же MAC** — это сохраняет привязки (DHCP lease, ARP таблицы, ACL).
    
- Если в сегменте `br1` включены фильтры по MAC/IP, запросите у сетевиков обновление списков.
    
- Проверьте MTU, offload’ы и ethtool-настройки на `br1`/`eno1`, если в гостях чувствительные приложения (БД, VoIP, IPSec).
    

---
