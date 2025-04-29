#astra #repo #iso

## Подготовка

Создать каталог для размещения репозитория:

```
sudo mkdir -p /srv/repo/alse/main
```
Примонтировать образ установочного диска (если на компьютере нет каталога /media/cdrom - то создать каталог /media/cdrom):

```
[ -d /media/cdrom ] || sudo mkdir /media/cdrom  
sudo mount /путь_к_ISO-образу /media/cdrom
```

Скопировать файлы из образа в каталог репозитория:

```
sudo cp -a /media/cdrom/* /srv/repo/alse/main
```

Отмонтировать ISO-образ диска:

```
sudo umount /media/cdrom
```
## Локальные источники пакетов

Для Astra Linux Special Edition x.7:

`# репозиторий основного диска   deb file:/srv/repo/alse/``main` `stable main contrib non-``free`  
`# репозиторий диска со средствами разработки`  
`deb` `file:/srv/repo/alse/base` `stable` `main contrib non-``free`  
`` `# репозиторий диска с обновлением основного диска`   deb `` `file:/srv/repo/alse/update-main` `stable` `main contrib non-``free`  
`` `# репозиторий диска с обновлением диска` со средствами разработки   deb `` `file:/srv/repo/alse/update-base` `stable` `main contrib non-``free`