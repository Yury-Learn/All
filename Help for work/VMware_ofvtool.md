### ЭКСПОРТ. (Используем Windows PowerShell as Admin)

Используем утилиту VMware ovftool
Скачать можно: \\ksb-storage\Distrib\install\VMWare

Примечание: Виртуальная машина должна быть выключена.

Команда для выполнения копирования на свой компьютер:
& 'C:\Program Files\VMware\VMware OVF Tool\ovftool.exe' vi://172.18.1.4/AlfaDoc-release-demostand-student(172.17.0.30 university.alfa-doc.ru) "E:\VM\"

Команда для выполнения копирования на свой компьютер, если есть пробелы в названии:
& 'C:\Program Files\VMware\VMware OVF Tool\ovftool.exe' 'vi://172.18.1.6/VeeamBackup17(172.18.1.7)' "E:\VM\"
'"'
Вместо "E:\VM\" ставим свою директорию. 



Примечание: Если будем импортировать через OVF Tools, то желательно удалить сетевой интерфейс до экспорта!

### ИМПОРТ.
 

Метод №1 Что бы начать перенос VM, нужно открыть WEB "морду" ESXi хоста и через меню Create / Register VM следовать указаниям.

Примечание: 
1. Зайти на сервер через программу VM Ware Workstation.
2. Удалить из свойств ВМ CD-Rom. 
Если этого не сделать, придется удалять устройство из конфигурации, т.к. иногда ESXi хост ругается на несовместимость. 

# Ошибки при импорте: 
"A required disk image was missing."
Решение, открыть файл конфига *.ovf
Удалить строчку <File ovf:href="NameVM.nvram" ovf:id="file2" ovf:size="0"/>
-
Ошибка при запуске №1: 
Обязательно нужно указать ВАШУ ОС (если нет Windows 2019, то ставим Windows 2016), главное указать принадлежность к семейству ОС (Debian, Red Hat, Windows и т.д.)

# Метод  №2

Через утилиту OVF Tools (CLI)
Example: 
```
& 'C:\Program Files\VMware\VMware OVF Tool\ovftool.exe' --noSSLVerify -ds="Data2" -dm="thin" -n="Prometeus" "D:\VM\Prometeus\Prometeus.ovf" vi://172.18.1.10
Система попросит указать Username/Password
```

--noSSLVerify - не требовать проверки SSL.
-ds= указываем название хранилища сервера.
-dm= указывает метод разворачивания thin или thick 
-n= указываем название, которое будет на ESXi



При появлении ошибки связанной с сетью, добавляем сетевой интерфейс "VMkernel" с таким же названием на ESXi. (Позже можно будет удалить)