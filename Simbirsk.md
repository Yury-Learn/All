#redvirt #cyber

# Шлюз
172.16.100.254
ksb / @#G67Nse&99ZZ
# Сервера

| IP             | NAME         | login                        | password                     | OS              |
| -------------- | ------------ | ---------------------------- | ---------------------------- | --------------- |
| 172.16.100.251 | cyberbackup  | miacadmin<br>root            | Bes!Opasno2025<br>cyber_root | AL SE 1.8.2     |
| 172.16.100.254 | шлюз ВМ      | ksb                          | @#G67Nse&99ZZ                | Windows 10      |
| 172.16.100.9   | fu-9.local   | root                         | s8Cxh9rU&SZV                 | RED OS 7.3 virt |
| 172.16.100.11  | fu-10.local  | root                         | s8Cxh9rU&SZV                 | RED OS 7.3 virt |
| 172.16.100.12  | fu-11.local  | root                         | s8Cxh9rU&SZV                 | RED OS 7.3 virt |
| 172.16.100.100 | rv-eng.local | root (ssh)<br>admin (portal) | s8Cxh9rU&SZV                 | RED OS 7.3      |
# Машруты

```sh
sudo ip route add 185.61.25.133 via 172.16.100.5 dev eno1 && \
sudo ip route add 213.180.204.183 via 172.16.100.5 dev eno1 && \
sudo ip route add 82.148.20.159 via 172.16.100.5 dev eno1
```

```sh
echo '' > /etc/cockpit/disallowed-users
```


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
```

- Перезагрузите хост и произведите деплой системы заново


# Cyber backup

- Postgre
 cyberbackup / Cyber_Postgre08 
 
 - SMB
acronisbackup / 8gO&GQB@da2f
`\\172.16.100.252\acronis_dir`

test-cb.local
172.16.100.250



```sh
grep 'ENGINE_DB_PASSWORD' /etc/ovirt-engine/engine.conf.d/*.conf
```


```sh
grep 'ENGINE_DB_USER' /etc/ovirt-engine/engine.conf.d/*.conf
```