# 0. Краткое резюме

Цель: выполнить разовый «холодный» архив (ВМ выключены) выбранных KVM‑ВМ из Proxmox VE 8.4 на внешний файловый ресурс (SMB‑шара на QNAP QTS 5.2.4) c проверкой целостности и тестовым восстановлением.

Результаты:
- Получены архивы `.vma.zst` для ВМ: `150, 151, 172, 113` (узел ex25), `105` (ex24), `112` (ex2).
- Каждый архив: проверен `vma verify`, сгенерирован `SHA256`.
- Сформирован CSV‑манифест, README по восстановлению, отчёт по сжатию.
- Выполнен restore dry‑run для VM 112 на сторадж `HDD1_Qnap_20` (узел ex2).

Итого объём архивов (по факту): ~734 GiB (ex25 ≈ 560 GiB, ex24 ≈ 167 GiB, ex2 ≈ 7.1 GiB).

---

# 1. Исходные данные и цели

1.1. Режим: разовый архив, ВМ заранее остановлены (даунтайм допустим).  
1.2. PVE: 8.4.x (ядро 6.8.12‑11, qemu‑server 8.3.12, pve‑qemu‑kvm 9.2.0‑5).  
1.3. Хранилища PVE: thick LVM на iSCSI LUN‑ах QNAP (например, `HDD1_Qnap_20`, `SSD1_Qnap_13`), есть NFS, PBS (не используется).  
1.4. Место назначения: SMB‑шара `PVE_ARCHIVE` на QNAP (QTS 5.2.4), монтируется на ноды PVE.
1.5. Проверка целостности: `vma verify` + `sha256sum`; манифест CSV.  
1.6. Тест восстановления: `qmrestore` с `--unique 1`, безопасный старт без сети, удаление тестовой ВМ после проверки.

---

# 2. Лучшие практики и принципы

2.1. **vzdump + zstd**: стандартный формат `.vma.zst` экономит место, совместим со всеми версиями PVE.  
2.2. **Единичный поток**: запуск по одной ВМ за раз (в цикле), чтобы не душить стораджи и сеть.  
2.3. **Ограничение пропускной**: `--bwlimit` (КиБ/с), напр. `50000` (~50 MiB/s).  
2.4. **Низкий приоритет I/O и CPU**: `ionice`, `nice` для меньшего влияния на систему.  
2.5. **Проверка каждой сборки**: сразу `vma verify` и `sha256sum`.  
2.6. **Логи и артефакты**: храним `.log`, `.sha256`, CSV‑манифест, README, отчёты рядом с архивами.  
2.7. **SMB безопасность**: отдельная сервисная учётка, минимальные RW‑права, по завершении — смена пароля, опционально RO.

---

# 3. Инвентаризация и оценка объёма

3.1. Проверка статуса (должно быть `stopped`):
```bash
qm status <VMID>
```

3.2. Где и в чём лежат диски, «виртуальные» размеры:
- Быстро: `qm config <VMID>` и читаем `size=<X>G` для каждого диска.
- Универсально: скрипт `vm-inventory.sh` (см. Приложение A) — показывает backend стораджа (`dir/qcow2`, `lvm`, `zfspool`, `rbd`) и размеры.

3.3. Оценка места под архивы:
- Для thick LVM без очистки свободного места реальный архив обычно 40–80% от суммарного виртуального размера.
- Закладывайте запас ~20%.

---

# 4. QNAP QTS 5.2.4 — подготовка SMB‑шары

4.1. Включить SMB: *Control Panel → Network & File Services → Microsoft Networking* → Enable; Highest SMB: **3.1.1**, Lowest SMB: **≥ 2.1** (SMB1 — off).  
4.2. Создать сервисного пользователя (например, `svc-pve-archive`) со сложным паролем.  
4.3. Создать Shared Folder `PVE_ARCHIVE` на объёмном томе; выдать RW только `svc-pve-archive`.  
4.4. Рекомендации для шары:
- **Network Recycle Bin**: выключить (архивы большие, корзина съедает место).  
- **Oplocks**: оставить включёнными (обычно помогает производительности).  
- **Instant sync** (форс‑сброс на диск): выключить ради скорости, включать только при строгих требованиях к немедленной фиксации данных.  
- IP‑ограничения: при необходимости — разрешить IP нод PVE.

---

# 5. Подключение SMB на нодах PVE

5.1. Установка и креды:
```bash
apt-get update && apt-get install -y cifs-utils
cat >/root/.pve-archive.cred <<'EOF'
username=svc-pve-archive
password=<PASSWORD>
domain=WORKGROUP
EOF
chmod 600 /root/.pve-archive.cred
```

5.2. Монтирование (пример, NAS 10.38.16.4):
```bash
mkdir -p /mnt/pve-archive
mount -t cifs //10.38.16.4/PVE_ARCHIVE /mnt/pve-archive \
  -o credentials=/root/.pve-archive.cred,vers=3.1.1,sec=ntlmssp,uid=0,gid=0,file_mode=0640,dir_mode=0750,noperm
```
Пояснения ключей:  
- `vers=3.1.1` — SMB протокол (современно/безопасно).  
- `sec=ntlmssp` — NTLMv2 (защищённая аутентификация).  
- `credentials=...` — путь к файлу учётки.  
- `uid=0,gid=0` — владельцем файлов на стороне клиента будет root.  
- `file_mode/dir_mode` — права на клиенте (на NAS применяются свои ACL, на клиенте лишь маска).  
- `noperm` — отключает клиентские проверки прав, доверяем NAS.

5.3. Структура каталогов:
```bash
mkdir -p /mnt/pve-archive/{ex25,ex24,ex2}
```

5.4. Автомонтирование (опционально, /etc/fstab):
```fstab
//10.38.16.4/PVE_ARCHIVE  /mnt/pve-archive  cifs  credentials=/root/.pve-archive.cred,vers=3.1.1,sec=ntlmssp,uid=0,gid=0,file_mode=0640,dir_mode=0750,noperm,_netdev,x-systemd.automount  0  0
```

---

# 6. Резервное копирование (скрипты по нодам)

## 6.1 Общие замечания по `vzdump`
- `--mode stop` — аккуратно останавливает ВМ, делает консистентный снапшот. В нашем кейсе ВМ уже выключены — операция быстрая.  
- `--dumpdir <DIR>` — писать в каталог (мы используем SMB‑путь). Альтернатива — `--storage <ID>` при регистрации dir‑storage в Datacenter.  
- `--compress zstd` — быстрая и эффективная компрессия.  
- `--bwlimit <KB/s>` — ограничение скорости записи/чтения (контроль нагрузки).  
- `--ionice 5` — снижает «нажим» на дисковые очереди.  
- (Не используем) `--notes-template` вместе с `--dumpdir` — на некоторых версиях требует `--storage`, поэтому убрано.

## 6.2 Узел ex25 (VMID: 150, 151, 172, 113)
```bash
apt-get update && apt-get install -y zstd
cat >/root/archive_ex25.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
D="/mnt/pve-archive/ex25"; LOGDIR="$D/logs"; BW=50000; VMIDS=(150 151 172 113)
mkdir -p "$D" "$LOGDIR"
for id in "${VMIDS[@]}"; do
  ts="$(date +%F_%H-%M-%S)"; LOG="$LOGDIR/$id-$ts.log"; echo "=== $(date) BEGIN VM $id ===" | tee -a "$LOG"
  nice -n 10 ionice -c2 -n7 vzdump "$id" \
    --dumpdir "$D" --mode stop --compress zstd \
    --bwlimit "$BW" --ionice 5 --lockwait 120 \
    --mailto litti.yb@ksb-soft.ru 2>&1 | tee -a "$LOG"
  ARCH="$(ls -1t "$D"/vzdump-qemu-"$id"-*.vma.zst | head -n1)"; [ -n "${ARCH:-}" ] || { echo "no archive" | tee -a "$LOG"; exit 1; }
  echo "[verify] $ARCH" | tee -a "$LOG"; zstdcat "$ARCH" | vma verify -v - 2>&1 | tee -a "$LOG"
  echo "[sha256] $ARCH" | tee -a "$LOG"; sha256sum "$ARCH" | tee "$ARCH.sha256" | tee -a "$LOG"
  echo "=== $(date) DONE VM $id ===" | tee -a "$LOG"
done
 echo "All done. Archives in: $D"
EOF
chmod +x /root/archive_ex25.sh
/root/archive_ex25.sh
```

## 6.3 Узел ex24 (VMID: 105)
```bash
apt-get update && apt-get install -y zstd
cat >/root/archive_ex24.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
D="/mnt/pve-archive/ex24"; LOGDIR="$D/logs"; BW=50000; VMIDS=(105)
mkdir -p "$D" "$LOGDIR"
for id in "${VMIDS[@]}"; do
  ts="$(date +%F_%H-%M-%S)"; LOG="$LOGDIR/$id-$ts.log"; echo "=== $(date) BEGIN VM $id ===" | tee -a "$LOG"
  nice -n 10 ionice -c2 -n7 vzdump "$id" \
    --dumpdir "$D" --mode stop --compress zstd \
    --bwlimit "$BW" --ionice 5 --lockwait 120 \
    --mailto litti.yb@ksb-soft.ru 2>&1 | tee -a "$LOG"
  ARCH="$(ls -1t "$D"/vzdump-qemu-"$id"-*.vma.zst | head -n1)"; [ -n "${ARCH:-}" ] || { echo "no archive" | tee -a "$LOG"; exit 1; }
  echo "[verify] $ARCH" | tee -a "$LOG"; zstdcat "$ARCH" | vma verify -v - 2>&1 | tee -a "$LOG"
  echo "[sha256] $ARCH" | tee -a "$LOG"; sha256sum "$ARCH" | tee "$ARCH.sha256" | tee -a "$LOG"
  echo "=== $(date) DONE VM $id ===" | tee -a "$LOG"
done
 echo "All done. Archives in: $D"
EOF
chmod +x /root/archive_ex24.sh
/root/archive_ex24.sh
```

## 6.4 Узел ex2 (VMID: 112)
```bash
apt-get update && apt-get install -y zstd
cat >/root/archive_ex2.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
D="/mnt/pve-archive/ex2"; LOGDIR="$D/logs"; BW=50000; VMIDS=(112)
mkdir -p "$D" "$LOGDIR"
for id in "${VMIDS[@]}"; do
  ts="$(date +%F_%H-%M-%S)"; LOG="$LOGDIR/$id-$ts.log"; echo "=== $(date) BEGIN VM $id ===" | tee -a "$LOG"
  nice -n 10 ionice -c2 -n7 vzdump "$id" \
    --dumpdir "$D" --mode stop --compress zstd \
    --bwlimit "$BW" --ionice 5 --lockwait 120 \
    --mailto litti.yb@ksb-soft.ru 2>&1 | tee -a "$LOG"
  ARCH="$(ls -1t "$D"/vzdump-qemu-"$id"-*.vma.zst | head -n1)"; [ -n "${ARCH:-}" ] || { echo "no archive" | tee -a "$LOG"; exit 1; }
  echo "[verify] $ARCH" | tee -a "$LOG"; zstdcat "$ARCH" | vma verify -v - 2>&1 | tee -a "$LOG"
  echo "[sha256] $ARCH" | tee -a "$LOG"; sha256sum "$ARCH" | tee "$ARCH.sha256" | tee -a "$LOG"
  echo "=== $(date) DONE VM $id ===" | tee -a "$LOG"
done
 echo "All done. Archives in: $D"
EOF
chmod +x /root/archive_ex2.sh
/root/archive_ex2.sh
```

---

# 7. Проверка целостности и отчёты

7.1. Сплошная проверка хэшей и VMA:
```bash
for f in /mnt/pve-archive/*/vzdump-qemu-*.vma.zst; do
  echo "[sha256sum -c] $f"; sha256sum -c "$f.sha256" || exit 1; done
for f in /mnt/pve-archive/*/vzdump-qemu-*.vma.zst; do
  echo "[vma verify] $f"; zstdcat "$f" | vma verify -v - || exit 1; done
```

7.2. CSV‑манифест (node, vmid, name, archive, bytes, sha256):
```bash
cat >/root/archive-manifest.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
OUT="/mnt/pve-archive/ARCHIVE_MANIFEST_$(date +%F_%H-%M-%S).csv"
echo "node,vmid,name,archive,bytes,sha256" > "$OUT"
for node in ex25 ex24 ex2; do
  for f in /mnt/pve-archive/$node/vzdump-qemu-*.vma.zst; do
    [ -e "$f" ] || continue
    base=$(basename "$f")
    vmid=$(echo "$base" | sed -nE 's/.*-qemu-([0-9]+)-.*/\1/p')
    name=$(zstdcat "$f" | vma content -v - | awk -F': ' '/^vmname:/{print $2; exit}')
    size=$(stat -c%s "$f")
    sha=$(awk '{print $1}' "$f.sha256" 2>/dev/null || sha256sum "$f" | awk '{print $1}')
    echo "$node,$vmid,$name,$base,$size,$sha" >> "$OUT"
  done
 done
 echo "Manifest: $OUT"
EOF
chmod +x /root/archive-manifest.sh
/root/archive-manifest.sh
```

7.3. Отчёт по сжатию (виртуальный объём дисков VS размер архива):
```bash
cat >/root/archive-compress-report.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
printf "%-6s %-8s %-12s %-12s %-8s %s\n" "NODE" "VMID" "VIRT_GB" "ARCHIVE_GB" "RATIO" "FILE"
for f in /mnt/pve-archive/*/vzdump-qemu-*.vma.zst; do
  node=$(echo "$f" | awk -F'/' '{print $(NF-1)}')
  vmid=$(basename "$f" | sed -nE 's/.*-qemu-([0-9]+)-.*/\1/p')
  virt_b=$(zstdcat "$f" | vma content -v - | awk -F': ' '/^size:/{s+=$2} END{print s+0}')
  arch_b=$(stat -c%s "$f")
  virt_gb=$(awk -v b="$virt_b" 'BEGIN{printf "%.1f", b/1024/1024/1024}')
  arch_gb=$(awk -v b="$arch_b" 'BEGIN{printf "%.1f", b/1024/1024/1024}')
  ratio=$(awk -v a="$arch_b" -v v="$virt_b" 'BEGIN{if(v>0) printf "%.1f%%", (a/v)*100; else print "n/a"}')
  printf "%-6s %-8s %-12s %-12s %-8s %s\n" "$node" "$vmid" "$virt_gb" "$arch_gb" "$ratio" "$(basename "$f")"
 done
EOF
chmod +x /root/archive-compress-report.sh
/root/archive-compress-report.sh
```

7.4. README рядом с архивациями:
```bash
cat >/mnt/pve-archive/README_RESTORE.txt <<'EOF'
Восстановление архива Proxmox (.vma.zst)
1) Проверить место: pvesm status
2) Новый ID: pvesh get /cluster/nextid
3) Восстановить: qmrestore /path/to/vzdump-qemu-<VMID>-<DATE>.vma.zst <NEWID> --storage <TARGET_STORAGE> --unique 1
4) Правки: qm config <NEWID>; qm set <NEWID> --onboot 0; (опц.) qm set <NEWID> --net0 virtio,bridge=vmbrX,link_down=1
5) Старт/проверка: qm start <NEWID>
EOF
```

---

# 8. Тестовое восстановление (restore dry‑run)

8.1. Выбрать storage и новый ID:
```bash
pvesm status
pvesh get /cluster/nextid   # пример: 199
```

8.2. Просмотр содержимого архива:
```bash
zstdcat /mnt/pve-archive/ex2/vzdump-qemu-112-*.vma.zst | vma content -v -
```

8.3. Восстановление:
```bash
qmrestore /mnt/pve-archive/ex2/vzdump-qemu-112-*.vma.zst 199 --storage HDD1_Qnap_20 --unique 1
qm config 199
```

8.4. Безопасный старт без сети:
```bash
qm set 199 --onboot 0
qm set 199 --net0 virtio,bridge=vmbr0,link_down=1
qm start 199
qm status 199
qm stop 199
qm destroy 199   # удалить тестовую ВМ и её диски
```

Пояснения:  
- `--unique 1` — генерирует новые идентификаторы (MAC, SMBIOS), чтобы не конфликтовать с оригиналом.  
- `link_down=1` — интерфейс поднят, но линк «вниз»: ВМ не выходит в сеть при первом запуске (безопасно).

---

# 9. Финализация и безопасность

9.1. Проверка и копирование: убедиться, что манифест/логи/README лежат рядом с архивами; при копировании на Windows — сверить SHA256 (например, `CertUtil`).  
9.2. Отмонтировать SMB (на каждой ноде):
```bash
sync
fuser -vm /mnt/pve-archive || true
lsof +D /mnt/pve-archive 2>/dev/null || true
umount /mnt/pve-archive || umount -l /mnt/pve-archive
```
9.3. На QNAP: выключить/очистить **Network Recycle Bin** этой шары; по завершении работ сменить пароль `svc-pve-archive`, при регулярном хранении — переключить шару в RO.  
9.4. На нодах: при необходимости удалить файл кредов `shred -u /root/.pve-archive.cred`.

---

# 10. Траблшутинг SMB (коротко)

10.1. `mount error(13): Permission denied` / `STATUS_LOGON_FAILURE`:  
- Проверить логин домена/рабочей группы: `-W WORKGROUP` в `smbclient`, `domain=WORKGROUP` в кредах.  
- Проверить права на шару `PVE_ARCHIVE` (RW для сервисной учётки).  
- Проверить политику SMB версии: `vers=3.1.1` → при необходимости `3.0` → `2.1`.  
- Проверить аутентификацию: `sec=ntlmssp`.  

10.2. Сеть/порт:
```bash
nc -zv <NAS_IP> 445   # порт SMB должен быть open
```

10.3. Диагностика:
```bash
smbclient -m SMB3 -L //<NAS_IP> -U <user>
smbclient -m SMB3 //<NAS_IP>/PVE_ARCHIVE -U <user> -c 'ls'
dmesg | tail -n 50   # сообщения CIFS/SMB в ядре
```

---

# 11. Приложение A — Полные листинги скриптов с комментариями

## A.1 `vm-inventory.sh` — инвентаризация дисков (backend, размеры)
```bash
#!/usr/bin/env bash
# Использование: /root/vm-inventory.sh <VMID1> <VMID2> ...
# Вывод: VMID;NAME;DISK;STORAGE;PATH/ID;BACKEND;VIRT_SIZE_GB;ACTUAL_GB
# BACKEND: dir/qcow2, lvm(lvmthin), zfspool (zvol), rbd (Ceph) и т. п.
set -euo pipefail
VMIDS=("$@")
echo "node: $(hostname)"
echo "VMID;NAME;DISK;STORAGE;PATH/ID;BACKEND;VIRT_SIZE_GB;ACTUAL_GB"
for VMID in "${VMIDS[@]}"; do
  NAME=$(qm config "$VMID" | awk -F': ' '/^name:/{print $2}')
  qm config "$VMID" | awk -F'[:, ]+' '/^(virtio|scsi|sata|ide)[0-9]+:/{print $1 ":" $2}' | while IFS=: read -r BUS VOL; do
    STORAGE="${VOL%%/*}"; VOLID="${VOL#*/}"
    STTYPE=$(pvesm status --storage "$STORAGE" 2>/dev/null | awk 'NR==2{print $2}')
    PTH=$(pvesm path "$STORAGE:$VOLID" 2>/dev/null || true)
    BACKEND="$STTYPE"; VSIZE_GB=""; ASIZE_GB=""
    case "$STTYPE" in
      dir|nfs|cifs)
        if [ -n "$PTH" ] && [ -f "$PTH" ]; then
          INFO=$(qemu-img info --output=json "$PTH" 2>/dev/null || true)
          VSIZE_GB=$(echo "$INFO" | jq -r '."virtual-size"' 2>/dev/null || echo "")
          ASIZE_B=$(stat -c%s "$PTH" 2>/dev/null || echo 0)
          [ -n "$VSIZE_GB" ] && VSIZE_GB=$(( VSIZE_GB/1024/1024/1024 ))
          ASIZE_GB=$(( ASIZE_B/1024/1024/1024 ))
          FMT=$(echo "$INFO" | jq -r '.format' 2>/dev/null || echo "")
          BACKEND="$STTYPE/$FMT"
        fi;;
      lvm|lvmthin)
        if [ -n "$PTH" ]; then
          VSIZE_GB=$(lvs --noheadings -o LV_SIZE "$PTH" 2>/dev/null | tr -dc '0-9.')
        fi;;
      zfspool)
        if [ -n "$PTH" ]; then
          VSIZE_GB=$(blockdev --getsize64 "$PTH" 2>/dev/null || echo 0)
          VSIZE_GB=$(( VSIZE_GB/1024/1024/1024 ))
        fi;;
      rbd)
        POOL=$(pvesm status --storage "$STORAGE" | awk 'NR==2{print $3}')
        if [ -n "$POOL" ]; then
          VSIZE_B=$(rbd info "$POOL/$VOLID" --format json 2>/dev/null | jq -r '.size' || echo 0)
          VSIZE_GB=$(( VSIZE_B/1024/1024/1024 ))
          ASIZE_B=$(rbd du "$POOL/$VOLID" --format json 2>/dev/null | jq -r '.[0].used_size // empty' || echo "")
          [ -n "$ASIZE_B" ] && ASIZE_GB=$(( ASIZE_B/1024/1024/1024 ))
          BACKEND="rbd"; PTH="$POOL/$VOLID"
        fi;;
    esac
    echo "$VMID;$NAME;$BUS;$STORAGE;${PTH:-$VOLID};$BACKEND;${VSIZE_GB:-};${ASIZE_GB:-}"
  done
done
```

## A.2 `archive_ex25.sh` / A.3 `archive_ex24.sh` / A.4 `archive_ex2.sh`
(см. §6; в каждом — объяснение параметров рядом).

## A.5 `archive-manifest.sh`
(см. §7.2).

## A.6 `archive-compress-report.sh`
(см. §7.3).

## A.7 Локальный отчёт по конкретной ноде (пример ex24)
```bash
#!/usr/bin/env bash
set -euo pipefail
printf "%-6s %-8s %-12s %-12s %-8s %s\n" "NODE" "VMID" "VIRT_GB" "ARCHIVE_GB" "RATIO" "FILE"
for f in /mnt/pve-archive/ex24/vzdump-qemu-*.vma.zst; do
  vmid=$(basename "$f" | sed -nE 's/.*-qemu-([0-9]+)-.*/\1/p')
  virt_b=$(zstdcat "$f" | vma content -v - | awk -F': ' '/^size:/{s+=$2} END{print s+0}')
  arch_b=$(stat -c%s "$f")
  virt_gb=$(awk -v b="$virt_b" 'BEGIN{printf "%.1f", b/1024/1024/1024}')
  arch_gb=$(awk -v b="$arch_b" 'BEGIN{printf "%.1f", b/1024/1024/1024}')
  ratio=$(awk -v a="$arch_b" -v v="$virt_b" 'BEGIN{if(v>0) printf "%.1f%%", (a/v)*100; else print "n/a"}')
  printf "%-6s %-8s %-12s %-12s %-8s %s\n" "ex24" "$vmid" "$virt_gb" "$arch_gb" "$ratio" "$(basename "$f")"
 done
```

---

# 12. Чек‑лист быстрого выполнения (summary)

1) Подготовить SMB‑шару на QNAP (`PVE_ARCHIVE`), создать `svc-pve-archive` (RW).  
2) На нодах PVE: смонтировать шару `//<NAS_IP>/PVE_ARCHIVE` в `/mnt/pve-archive`.  
3) Создать подпапки `/mnt/pve-archive/{ex25,ex24,ex2}`.  
4) Запустить скрипты архивации по нодам (см. §6).  
5) Проверить целостность: `sha256sum -c` + `vma verify`.  
6) Сформировать манифест CSV и README.  
7) Restore dry‑run выбранной ВМ: `qmrestore ... --unique 1`, «старт без сети», удалить.  
8) Скопировать архивы в целевое место; по завершении — отмонтировать SMB, сменить пароль сервисной учётки, при необходимости удалить файл кредов.

---

Примечания:
- Везде используем placeholders (`<PASSWORD>`, `<NAS_IP>`, `<TARGET_STORAGE>`).
- По завершении обязательно смените пароль `svc-pve-archive`.
- Для повторной процедуры этот документ можно использовать как runbook «под ключ». 

