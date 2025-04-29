---
tags: grub, linux
---
```sh
 dnf install grubby
```

Работа с утилитой **grubby** предоставляет множество преимуществ, включая простоту и согласованность во многих дистрибутивах. Для использования **grubby** не требуется обладать глубокими знаниями о файлах конфигурации утилиты.

Для генерации файла конфигурации GRUB 2 используется команда:

```sh
 grub2-mkconfig -o /boot/grub2/grub.cfg
```

После внесения изменений в файл конфигурации необходимо перезагрузить систему, чтобы изменения вступили в силу.

Для получения информации о работающем ядре системы выполните команду:

```sh
 grubby --default-kernel
```
 /boot/vmlinuz-5.15.35-5.el7.3.x86_64

Более подробную информацию о текущем ядре можно получить, выполнив команду:

```sh
grubby --info /boot/vmlinuz-$(uname -r)
```

	 index=1
	 kernel=/boot/vmlinuz-5.15.10-1.el7.x86_64
	 args="ro resume=/dev/mapper/ro_redos-swap rd.lvm.lv=ro_redos/root rd.lvm.lv=ro_redos/swap rhgb quiet rd.driver.blacklist=nouveau modprobe.blacklist=nouveau nvidia-drm.modeset=1"
	 root=/dev/mapper/ro_redos-root
	 initrd=/boot/initramfs-5.15.10-1.el7.x86_64.img
	 title=RED OS (5.15.10-1) MUROM (7.3.1)

Для просмотра информации обо всех имеющихся версиях ядра используйте команду:

```sh
grubby --info ALL
```

С другими доступными опциями можно ознакомиться, выполнив:

```sh
grubby --help
```

Также можно отфильтровать вывод всех имеющихся версий ядра командой:

```sh
grubby --info=ALL | grep ^kernel 
```

	 kernel=/boot/vmlinuz-5.15.35-5.el7.3.x86_64
	 kernel=/boot/vmlinuz-5.15.10-1.el7.x86_64
	 kernel=/boot/vmlinuz-0-rescue-5bcf621e66ba4fe4a75d2f4079182c86
	 kernel=/boot/vmlinuz-5.15.35-5.el7.3.x86_64
	 kernel=/boot/vmlinuz-5.15.10-1.el7.x86_64
	 kernel=/boot/vmlinuz-0-rescue-5bcf621e66ba4fe4a75d2f4079182c86

Для добавления новой записи в загрузчик выполните:

```sh
grubby --grub2 \
--add-kernel=/boot/vmlinuz-4.18.0-348.2.1.el8_5.x86_64 \
--title="Linux_TEST_Kernel" \
--initrd=/boot/initramfs-4.18.0-348.2.1.el8_5.x86_64.img \
--copy-default
```

Проверьте, добавлена ли новая запись:

```sh
grubby --info=ALL | grep -E "^kernel|^index" 
```

	 index=0
	 kernel=/boot/vmlinuz-4.18.0-348.2.1.el8_5.x86_64
	 index=1
	 kernel=/boot/vmlinuz-5.15.35-5.el7.3.x86_64
	 index=2
	 kernel=/boot/vmlinuz-5.15.10-1.el7.x86_64
	 index=3
	 kernel=/boot/vmlinuz-0-rescue-5bcf621e66ba4fe4a75d2f4079182c86
	 index=4
	 index=5
	 kernel=/boot/vmlinuz-5.15.35-5.el7.3.x86_64
	 index=6
	 index=7
	 index=8
	 index=9
	 kernel=/boot/vmlinuz-5.15.10-1.el7.x86_64
	 index=10
	 index=11
	 kernel=/boot/vmlinuz-0-rescue-5bcf621e66ba4fe4a75d2f4079182c86
	 index=12