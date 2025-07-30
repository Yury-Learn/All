#backup #redvirt

### ==команды на ХОСТе с движком==

1. включить режим глобального  обслуживания:  
	```sh
	hosted-engine --set-maintenance --mode=global
	```
 
 2. выключить режим глобального  обслуживания:  
	```sh
	hosted-engine --set-maintenance --mode=none
	```

3. Статус Engine
	```sh
	hosted-engine --vm-status
	```

### ==команды на машине ENGINE==

4. остановить службу ovirt-engine:  
```sh
	systemctl stop ovirt-engine  
	systemctl disable ovirt-engine
```

5. Запустите команду engine-backup, указав имя создаваемого файла резервной копии и имя файла журнала:  
	```sh
	engine-backup --mode=backup --file=<file_name> --log=<log_file_name>
	```

6. Запустить службу ovirt-engine: 
```sh
systemctl enable --now ovirt-engine
```

7. Сохранить файлы резерва и лога

---
### ==Алгоритм==

 **1-4-5-6-2-3-7**
 
```sh
hosted-engine --vm-status # Узнаём где Engine
hosted-engine --set-maintenance --mode=global # переводим в глобальное обслуживание, на хосте где вращается Engine
========================================================================
	# ** на хосте EngineHost**
	systemctl stop ovirt-engine  
	systemctl disable ovirt-engine
	engine-backup --mode=backup --file=<file_name> --log=<log_file_name>
	systemctl enable --now ovirt-engine
========================================================================
hosted-engine --set-maintenance --mode=none
# **Мониторим включение**
hosted-engine --vm-status
```