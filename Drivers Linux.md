---
tags: linux, drivers
---
## 1. dmesg
- Получаем NIC driver name
```sh
dmesg | grep -i ethernet
```

- Смотрим информацию
```sh
modinfo i40e
```
## 2. ethtool
- Получаем NIC driver name
```sh
ethtool -i _имяинтерфйеса_
```
## 3. lshw
```sh
lshw -class network
```
