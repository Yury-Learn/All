#redvirt

10.38.26.11     glfs-rv1.ksb.local
10.38.22.51     glfs-rv1.ksb.local
10.38.26.51     glfs-rv2.ksb.local
10.38.22.166    glfs-rv2.ksb.local
10.38.26.53     glfs-rv3.ksb.local
10.38.22.145    glfs-rv3.ksb.local
10.38.26.52    glfs-eng.ksb.local

# Установка хоста

- Произведите на новом хосте очистку `ovirt-hosted-engine-cleanup`
- Последовательно на хосте выполните команды:

```
dnf install kernel-lt-5.15.167-2.el7virt
dracut --force --kver 5.15.167-2.el7virt.x86_64
sh ./kernel.sh
```

kernel.sh прикреплен к задаче, система спросит какое ядро выбирать для загрузки системы, выберите `5.15.167-2.el7virt` (необходимо будет ввести номер и нажать enter)

- Перезагрузите хост
- Примонтируйте установочный образ РЕД Виртуализации в систему, как вы это делали при установке
- Выполните на хосте:

```
dnf downgrade libvirt*7.6.0-10.el7.x86_64 --enablerepo=* --allowerasing
dnf downgrade qemu*7.2.14-2.el7.x86_64 --enablerepo=* --allowerasing
dnf downgrade NetworkManager*1.44.2-3.el7.x86_64 --enablerepo=* --allowerasing