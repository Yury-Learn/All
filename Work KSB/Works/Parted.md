#parted #lvm #hdd 
### Шаг 1: Очистка существующей конфигурации LVM на `sdb`

1. **Отмонтируйте том `vg_data-lv_storage`, если он смонтирован**:
   ```bash
   umount /srv/data_lvm
   ```

2. **Удалите логический том `lv_storage`**:
   ```bash
   lvremove /dev/vg_data/lv_storage
   ```

3. **Удалите группу томов `vg_data`**:
   ```bash
   vgremove vg_data
   ```

4. **Удалите физические тома на разделах `sdb2` и `sdb3`**:
   ```bash
   pvremove /dev/sdb2
   pvremove /dev/sdb3
   ```

### Шаг 2: Удаление существующих разделов `sdb1`, `sdb2`, `sdb3`

Запустите `parted` или `fdisk` для удаления всех разделов на `sdb`:

1. Запустите `parted`:
   ```bash
   parted /dev/sdb
   ```

2. Удалите каждый раздел (`sdb1`, `sdb2`, и `sdb3`):
   ```bash
   (parted) rm 1
   (parted) rm 2
   (parted) rm 3
   ```

3. Завершите работу `parted`:
   ```bash
   (parted) quit
   ```

### Шаг 3: Создание нового раздела на `sdb` для ISO (500 ГБ)

Теперь создадим первый раздел для хранения ISO размером 500 ГБ.

1. Запустите `parted`:
   ```bash
   parted /dev/sdb
   ```

2. Создайте новый раздел, начиная с 1 MiB для правильного выравнивания:
   ```bash
   (parted) mkpart primary ext4 1MiB 500GiB
   ```

3. Завершите работу `parted`:
   ```bash
   (parted) quit
   ```

4. Преобразуйте раздел в физический том LVM:
   ```bash
   pvcreate /dev/sdb1
   ```

5. Создайте новую группу томов для ISO и добавьте раздел:
   ```bash
   vgcreate vg_iso /dev/sdb1
   ```

6. Создайте логический том в `vg_iso` для хранения ISO-образов:
   ```bash
   lvcreate -l 100%VG -n lv_iso vg_iso
   ```

7. Отформатируйте логический том:
   ```bash
   mkfs.ext4 /dev/vg_iso/lv_iso
   ```

### Шаг 4: Создание двух равных разделов на оставшемся пространстве и настройка LVM

Теперь используем оставшееся пространство на `sdb`, чтобы создать два раздела и объединить их в одно LVM-хранилище `vm_data`.

1. Запустите `parted` для создания двух новых разделов:
   ```bash
   parted /dev/sdb
   ```

2. Создайте первый раздел, начиная с 500 ГБ, и сделайте его половиной оставшегося пространства:
   ```bash
   (parted) mkpart primary ext4 500GiB 5250GiB
   ```

3. Создайте второй раздел на оставшейся части диска:
   ```bash
   (parted) mkpart primary ext4 5250GiB 100%
   ```

4. Завершите работу `parted`:
   ```bash
   (parted) quit
   ```

5. Создайте физические тома на новых разделах:
   ```bash
   pvcreate /dev/sdb2
   pvcreate /dev/sdb3
   ```

6. Создайте группу томов `vg_vm_data` и добавьте к ней разделы:
   ```bash
   vgcreate vg_vm_data /dev/sdb2 /dev/sdb3
   ```

7. Создайте логический том `lv_vm_data` на всю группу томов:
   ```bash
   lvcreate -l 100%VG -n lv_vm_data vg_vm_data
   ```

8. Отформатируйте логический том:
   ```bash
   mkfs.ext4 /dev/vg_vm_data/lv_vm_data
   ```

### Шаг 5: Монтирование разделов и добавление записей в `/etc/fstab`

1. Создайте точки монтирования:
   ```bash
   mkdir -p /srv/iso
   mkdir -p /srv/vm_data
   ```

2. Добавьте записи в `/etc/fstab` для автоматического монтирования:

   Откройте файл `/etc/fstab` и добавьте следующие строки:
   ```plaintext
   /dev/vg_iso/lv_iso /srv/iso ext4 defaults,nofail 0 0
   /dev/vg_vm_data/lv_vm_data /srv/vm_data ext4 defaults,nofail 0 0
   ```

3. Смонтируйте новые точки монтирования, чтобы проверить их работу:
   ```bash
   mount -a
   ```

4. Убедитесь, что все разделы смонтированы корректно:
   ```bash
   df -h
   ```
