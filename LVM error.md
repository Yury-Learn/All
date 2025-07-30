В этой статье содержится руководство по восстановлению отсутствующего тома и данных на нем при использовании LVM (Logical Volume Manager).

## Сценарий

Метаданные LVM системы Linux повреждены, и диски или разделы не отображаются при выполнении `PVdisplay`, `LVdisplay`или `VGdisplay`.

## Восстановление недостающего объема

1. LVM всегда будет делать резервную копию своих метаданных в `/etc/lvm/backup/<vg_name>`(VG ~ Volume Group) после модификации. Убедитесь, что этот файл присутствует и содержит все тома и их размеры:

```
logical_volumes {
	root {
		id = "j5rlvk-cGYE-fxbN-F8bO-p90r-x0FL-suSAUN"
		status = ["READ", "WRITE", "VISIBLE"]
		flags = []
		creation_host = "unassigned-hostname"
		creation_time = 1475126039 # 2020-05-03 10:42:51 +0530
		segment_count = 2
		segment1 {
			start_extent = 0
			extent_count = 6425 # 25.0977 Gigabytes
			type = "striped"
			stripe_count = 1 # linear
			stripes = [
				"pv0", 0
			]
		}
		segment2 {
			start_extent = 6425
			extent_count = 15360 # 60 Gigabytes
			type = "striped"
			stripe_count = 1 # linear
			stripes = [
				"pv1", 0
			]
		}
	}
}
```

- После краткой проверки всех настроек сохраните резервную копию этого файла:

```
cat /etc/lvm/backup/<vg_name> > /path/to/lvm_backup_file
```

1. Теперь перезагрузите сервер в Rescue System.
2. После входа в Rescue System, пожалуйста, выберите `mount`раздел, содержащий `lvm_backup_file`, скопируйте его в файловую систему Rescue System, а затем `umount`в раздел:

```
mount /dev/<partition> /mnt
cp /mnt/path/to/lvm_backup_file lvm_backup_file
umount /mnt
```

1. Убедитесь, что ни один из разделов больше не смонтирован:`lsblk`
2. Выведите содержимое `lvm_backup_file`использования `cat`и скопируйте UUID (универсальный уникальный идентификатор) относительно

- После этого используйте команду ниже, чтобы создать физический том (PV):

```
pvcreate –restorefile lvm_backup_file –uuid <uuid> <partition>
```

```
pvcreate –restorefile lvm_backup_file –uuid ek9MZu-UeBK-4boe-IkJU-Q4n7-yfpX-yLK1WY /dev/sda1
```

1. Проверьте, создан ли физический том:`pvs`
2. Затем восстановите группу томов (VG), используя следующую команду:

```
vgcfgrestore –force <vg_name>
```

- _Пример:_

```
vgcfgrestore –force vg0
```

1. Синхронизируйте данные группы томов:`vgscan`
2. Теперь проверьте, правильно ли была восстановлена ​​группа томов:`vgs`
3. Далее восстанавливаем LVM:`vgchange -ay <vg_name>` _Пример:_

```
vgchange -ay vg0
```

- Наконец, перезапустите сервер и позвольте ему загрузиться в установленную систему. Пожалуйста, убедитесь, что данные не повреждены. Если проблемы по-прежнему возникают, выполнить проверку файловой системы.