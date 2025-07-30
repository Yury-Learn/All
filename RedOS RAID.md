#raid #linux 
# Установка РЕД ОС на программный массив RAID1 и RAID10

---

Особенности программного RAID-массива:

- _Гибкость_: управление RAID происходит с помощью операционной системы, поэтому такой массив можно настроить из работающей системы без перенастройки оборудования.
- _Открытый исходный код_: реализация программного RAID-массива основана открытом программном коде.
- _Никаких дополнительных расходов_: программный RAID не требует специального аппаратного обеспечения и не привязан к конкретному оборудованию.
- _Ресурсные затраты_: в течение всего срока существования программный RAID критикуют за повышенное использование аппаратных ресурсов. Такие программные реализации как mdadm практически полностью устраняют эту проблему на современном оборудовании.

## Установка РЕД ОС на программный массив уровня RAID 1 для систем с UEFI

**RAID 1** состоит из так называемого «зеркалирования» данных без их контроля четности и чередования. В такой реализации данные записываются идентично на два или более дисков, тем самым создавая «зеркальный набор» дисков. Таким образом, все диски в массиве являются полными копиями друг друга, что обеспечивает высокую надежность, но в то же время появляется избыточность данных.

Для установки РЕД ОС на **RAID 1** выполните следующие действия:

1. Выберите первый пункт «**Установить RED OS**».

[![](https://redos.red-soft.ru/upload/iblock/001/install-ro-on-raid1-new-1.png)](https://redos.red-soft.ru/upload/iblock/001/install-ro-on-raid1-new-1.png)  

2. Перейдите в раздел для разметки дисков, выбрав пункт «**Место установки**».

[![](https://redos.red-soft.ru/upload/iblock/001/install-ro-on-raid1-new-2.png)](https://redos.red-soft.ru/upload/iblock/001/install-ro-on-raid1-new-2.png)  

3. В окне «**Место установки**» выберите необходимые для разметки диски (в примере отмечены два диска по 20 ГБ), активируйте чекбокс для варианта «**По-своему**», а затем нажмите «**Готово**».

[![](https://redos.red-soft.ru/upload/iblock/001/install-ro-on-raid1-new-3.png)](https://redos.red-soft.ru/upload/iblock/001/install-ro-on-raid1-new-3.png)  

4. Создайте необходимые разделы, нажав «**Создать их автоматически**».

[![](https://redos.red-soft.ru/upload/iblock/001/install-ro-on-raid1-new-4.png)](https://redos.red-soft.ru/upload/iblock/001/install-ro-on-raid1-new-4.png)  

5. После разметки в правой части окна выполните следующие действия:

5.1 Выбрать «**Тип устройства**» — **RAID**.

5.2 В группе «**Уровень RAID**» — указать необходимый тип RAID-массива (в примере выбран **RAID1**).

5.3 Нажмите кнопку «**Применить**».

[![](https://redos.red-soft.ru/upload/iblock/001/install-ro-on-raid1-new-5.png)](https://redos.red-soft.ru/upload/iblock/001/install-ro-on-raid1-new-5.png)  

[![](https://redos.red-soft.ru/upload/iblock/001/install-ro-on-raid1-new-6.png)](https://redos.red-soft.ru/upload/iblock/001/install-ro-on-raid1-new-6.png)  

6. Повторите операцию выбора типа устройства (**RAID**) и уровня **RAID** для всех остальных разделов: **/boot/efi**, **/boot**, **swap**.

[![](https://redos.red-soft.ru/upload/iblock/001/install-ro-on-raid1-new-7.png)](https://redos.red-soft.ru/upload/iblock/001/install-ro-on-raid1-new-7.png)  

7. По нажатии кнопки «**Готово**» будет открыто окно с итоговой таблицей разметки – при необходимости проверьте установленные параметры и, если все настроено верно, нажмите «**Принять изменения**».

8. Далее установите ОС в штатном режиме.

### Решение проблемы недоступности одного из дисков

Для подготовки разделов диска на случай, если один из дисков будет недоступен, необходимо:

1. Вывести и запомнить идентификаторы (**UUID**) дисков командой:

lsblk -fs

2. Изменить **UUID** для **sdb1** и **sdb2** из вывода команды `lsblk -fs`:

mkdosfs -i <UUID_sda1> /dev/sdb1
e2fsck -f /dev/sdb2
tune2fs /dev/sdb2 -U <UUID_sda2>

[![](https://redos.red-soft.ru/upload/iblock/001/in-redos-uefi-on-raid1-18.png)](https://redos.red-soft.ru/upload/iblock/001/in-redos-uefi-on-raid1-18.png)  

3. Скопировать данные на **/dev/sdb1** для EFI-раздела:

mount /dev/sdb1 /mnt
cp -R /boot/efi/EFI/ /mnt

После чего отмонтировать раздел:

umount /dev/sdb1

4. Скопировать на **/dev/sdb2** данные из **/dev/sda2** для **boot**-раздела:

mount /dev/sda2 /media
mount /dev/sdb2 /mnt

cp -R /media/* /mnt/
umount /media /mnt

После этого система с **UEFI** сможет найти загрузчик на любом из дисков, который будет доступен.

В случае если система с **UEFI** не смогла самостоятельно обнаружить загрузочную запись, можно прописать ее самостоятельно. Для этого:

1. Загрузитесь в rescue с USB/DVD-диска:

chroot /mnt/sysroot

2. Переведите SELinux в режим permissive:

sed -i "s/SELINUX=enforcing/SELINUX=permissive/" /etc/selinux/config

3. Выведите информацию о загрузочных записях:

efibootmgr -v

4. Пропишите загрузчик командой:

efibootmgr -c -d /dev/sdb -p 1 -L "RED OS 2" -l "\EFI\redos\shimx64.efi"
grub2-mkconfig -o /boot/efi/EFI/redos/grub.cfg

[![](https://redos.red-soft.ru/upload/iblock/001/in-redos-uefi-on-raid1-19.png)](https://redos.red-soft.ru/upload/iblock/001/in-redos-uefi-on-raid1-19.png)  

Если потребуется удалить запись, выполните команду:

efibootmgr -b 6 -B

где:

- **-b** (**--bootnum**) – указывает на номер записи;
    
- **-B** (**--delete-bootnum**) – указывает удалить запись.
    

## Установка РЕД ОС на программный массив уровня RAID 10

**RAID 10** представляет собой объединение массивов **RAID 1** и **RAID 0**. Для создания **RAID 10** требуется **минимум четыре диска**, в которых данные чередуются на зеркальных парах. Пока один диск в каждой зеркальной паре функционирует, данные могут быть извлечены. В случае сбоя двух дисков в одной зеркальной паре все данные будут потеряны из-за отсутствия четности в чередующихся наборах.

Для установки РЕД ОС на **RAID 10** выполните следующие действия:

1. Выберите первый пункт «**Установить RED OS**».

[![](https://redos.red-soft.ru/upload/iblock/001/in-redos-on-radi1-01.png)](https://redos.red-soft.ru/upload/iblock/001/in-redos-on-radi1-01.png)  

2. Перейдите в раздел для разметки дисков (пункт «**Место установки**»).

[![](https://redos.red-soft.ru/upload/iblock/001/in-redos-on-radi10-2.png)](https://redos.red-soft.ru/upload/iblock/001/in-redos-on-radi10-2.png)  

3. В данном окне отметьте все локальные диски, нажмите кнопку «**По-своему**», а затем «**Готово**».

[![](https://redos.red-soft.ru/upload/iblock/001/in-redos-on-radi10-3.png)](https://redos.red-soft.ru/upload/iblock/001/in-redos-on-radi10-3.png)  

4. Нажмите на пункт «**Создать их автоматически**».

[![](https://redos.red-soft.ru/upload/iblock/001/in-redos-on-radi10-4.png)](https://redos.red-soft.ru/upload/iblock/001/in-redos-on-radi10-4.png)  

5. В конфигураторе разметки дисков определите нужный размер для корневого и домашнего раздела через параметр «**Требуемый объем**». После этого выберите корневой раздел и в группе томов нажмите на кнопку «**Изменить**».

[![](https://redos.red-soft.ru/upload/iblock/001/in-redos-on-radi10-5.png)](https://redos.red-soft.ru/upload/iblock/001/in-redos-on-radi10-5.png)  

6. В окне настройки группы томов из списка **RAID** выберите «**RAID 10**».

[![](https://redos.red-soft.ru/upload/iblock/001/in-redos-on-radi10-6.png)](https://redos.red-soft.ru/upload/iblock/001/in-redos-on-radi10-6.png)  

7. Итоговая таблица разметки:

[![](https://redos.red-soft.ru/upload/iblock/001/in-redos-on-radi10-7.png)](https://redos.red-soft.ru/upload/iblock/001/in-redos-on-radi10-7.png)  

8. После установки можно просмотреть информацию о разделах на **RAID 10**:

[![](https://redos.red-soft.ru/upload/iblock/001/in-redos-on-radi10-8.png)](https://redos.red-soft.ru/upload/iblock/001/in-redos-on-radi10-8.png)  

Команда `lsblk` показывает, что **md127** – это **RAID 10**. Также видно, что на каждом из дисков **sda**, **sdb**, **sdc**, **sdd** созданы разделы с точками монтирования **swap**, **home** и **корень** (**/**), которые являются точными копиями друг друга. В RAID-массиве десятого уровня данные делятся на блоки и дублируются на паре дисков.

Команда `mdadm -D /dev/md127` выведет на экран детальную информацию о RAID-массиве.

[![](https://redos.red-soft.ru/upload/iblock/001/in-redos-on-radi10-9.png)](https://redos.red-soft.ru/upload/iblock/001/in-redos-on-radi10-9.png)