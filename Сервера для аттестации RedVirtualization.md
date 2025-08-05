#redvirt #ksb 

# 1. 

| hostname           | ip           | login     | root           | ip-IPMI     | login IPMI |
| ------------------ | ------------ | --------- | -------------- | ----------- | ---------- |
| att-rv1.ksb.local  | 10.38.22.156 | ksb / 123 | 7BskAdmin2025! | 10.38.27.16 | ADMIN /123 |
| att-eng1.ksb.local | 10.38.22.157 | admin     | 7BskAdmin2025  |             |            |
| att-rv2.ksb.local  | 10.38.22.164 | ksb /123  | 7BskAdmin2025! | 10.38.27.32 |            |
| att-eng2.ksb.local | 10.38.22.165 | admin     | 7BskAdmin2025  |             |            |
|                    |              |           |                |             |            |
# 2. Установка

- Примонтируйте установочный образ РЕД Виртуализации в систему
```
  mount /tmp/rv.iso /mnt/rv-iso
```

- Запустите установку
```
/mnt/rv-iso/install.sh
```

- ==Перезагрузите хост==

- Последовательно на хосте выполните команды:

```
dnf install kernel-lt-5.15.167-2.el7virt
dracut --force --kver 5.15.167-2.el7virt.x86_64
sh ./kernel.sh
```



kernel.sh прикреплен к задаче, система спросит какое ядро выбирать для загрузки системы, выберите `5.15.167-2.el7virt` (необходимо будет ввести номер и нажать enter). Иногда нужно установить `dnf install grubby`

-  ==Перезагрузите хост== 

- ==Примонтируйте== установочный образ РЕД Виртуализации в систему, как вы это делали при установке

- Выполните на хосте:
```
dnf downgrade libvirt*7.6.0-10.el7.x86_64 --enablerepo=* --allowerasing
dnf downgrade qemu*7.2.14-2.el7.x86_64 --enablerepo=* --allowerasing
dnf downgrade NetworkManager*1.44.2-3.el7.x86_64 --enablerepo=* --allowerasing
```

- ==Перезагрузите хост== и произведите деплой системы заново

## NFS
[[Руководство - Настройка и подключение NFS-домена в РЕД Виртуализации]]

## Firewall-cmd

[[Настройка firewalld (методичка)]]

## Others

### Cockpit

- Включаем
```
systemctl enable --now cockpit
```

- Доступ **root**
```
echo '' > /etc/cockpit/disallowed-users
```