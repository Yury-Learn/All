#nfs 

Чтобы установить NFS сервер с помощью графического интерфейса, откройте [консоль Server Manager](https://winitpro.ru/index.php/2012/10/25/konsol-server-manager-v-windows-server-2012/) и внутри роли файлового сервера (File and Storage Services) отметьте компонент **Server for NFS**.

```powershell
Add-WindowsFeature "FS-NFS-Service"
```

==reboot==

## Настройка общей папки NFS в Windows Server 2012

Далее мы покажем, как с помощью установленной нами роли создать NFS шару (общую папку) на сервере Windows. Создать NFS шару можно опять несколькими способами: с помощью графического интерфейса или Powershell.

### Создание общего каталога NFS с помощью консоли Server Manager

Откройте консоль **Server Manager**, перейдите в раздел **Share management** (находится внутри роли **File and Storage Services**).  
В контекстном меню запустите мастер создания нового общего каталога- **New Share…**

[![Создать новую шару windows 2012](https://winitpro.ru/wp-content/uploads/2013/04/3_win2012_create_share.jpg "Создать новую шару windows 2012")](https://winitpro.ru/wp-content/uploads/2013/04/3_win2012_create_share.jpg)

Выберите тип шары **NFS** **Share —** **Quick**

[![](https://winitpro.ru/wp-content/uploads/2013/04/4_win2012_quick_create_nfs_share.jpg "Тип шары NFS Share - Quick - windows 2012")](https://winitpro.ru/wp-content/uploads/2013/04/4_win2012_quick_create_nfs_share.jpg)

Далее нужно указать местоположение каталога на диске и путь, по которому должны подключатся удаленные NFS клиенты.

[![Выбор каталога NFS](https://winitpro.ru/wp-content/uploads/2013/04/5_win2012_path_to_nfs_folder.jpg "Выбор каталога NFS")](https://winitpro.ru/wp-content/uploads/2013/04/5_win2012_path_to_nfs_folder.jpg)

Затем необходимо задать тип аутентификации NFS клиентов: возможно, задействовать как Kerberos- аутентификацию, так и анонимную.

Предположим, в качестве потребителя создаваемого NFS ресурса будет выступать сервер виртуализации ESXi, в котором возможность аутентифицировать NFS соединения отсутствует (ESXi не поддерживает NFSv4). Поэтому тип аутентификации будет **No Server Authentication**, отметим также опции **Enable unmapped user access** и **Allow unmapped user access by UID/GID**.

[![Тип nfs аутентификации в windows server 2012](https://winitpro.ru/wp-content/uploads/2013/04/6_win2012_nfs_authentification_option.jpg "Тип nfs аутентификации в windows server 2012")](https://winitpro.ru/wp-content/uploads/2013/04/6_win2012_nfs_authentification_option.jpg)

Чтобы немного обезопасить создаваемую NFS шару от доступа сторонних лиц, ограничим доступ к NFS ресурсу по IP адресу клиента.

**Host:** 192.168.1.100  
**Language Encoding** : BIG5  
**Share Permissions** : Read/Write  
**Allow root access** : Yes

[![windows server 2012: ограничение доступа к nfs шаре по ip адресу](https://winitpro.ru/wp-content/uploads/2013/04/7_win2012_nfs_filter_by_ip_adress.jpg "windows server 2012: ограничение доступа к nfs шаре по ip адресу")](https://winitpro.ru/wp-content/uploads/2013/04/7_win2012_nfs_filter_by_ip_adress.jpg)

Далее осталось проверить, что на уровне NTFS пользователь, в которого мапится подключающийся юзер, имеет доступ на чтение/запись (если решено задействовать анонимный доступ, придется для пользователя Everyone дать полные r/w права на уровне NTFS).

### Как создать NFS шару с помощью Powershell

Создадим новую NFS шару:

New-NfsShare -Name "NFS " -Path "d:\shares\nfr" -AllowRootAccess $true -Permission Readwrite -Authentication sys

Разрешим доступ к шаре для IP адреса 192.168.1.100 и зададим кодировку BIG5 (возможность просмотра содержимого NFS шары для клиента ESXi).

Grant-NfsSharePermission -Name “NFS” -ClientName 192.168.1.100  -ClientType host  -LanguageEncoding BIG5

Созданную NFS шару можно использовать, например, как NFS-datastore в среде виртуализации [VMWare vSphere](https://winitpro.ru/index.php/category/vmware/), или для доступа к данным с других Unix-like клиентов. Как смонтировать NFS шару в Windows — клиентах описано в [этой](https://winitpro.ru/index.php/2014/08/19/podklyuchaem-nfs-sharu-v-windows-server-2012-r2/) статье.

# Подключаем NFS шару в Windows Server 2012 R2

![date](https://winitpro.ru/wp-content/themes/lite/img/sloi_13.png)19.08.2014

![user](https://winitpro.ru/wp-content/themes/lite/img/sloi_64.png) [itpro](https://winitpro.ru/index.php/author/itpro/ "Записи itpro")

![directory](https://winitpro.ru/wp-content/themes/lite/img/sloi_11.png) [Windows Server 2012 R2](https://winitpro.ru/index.php/category/windows-server-2012-r2/)

![comments](https://winitpro.ru/wp-content/themes/lite/img/sloi_14.png) [Комментариев пока нет](https://winitpro.ru/index.php/2014/08/19/podklyuchaem-nfs-sharu-v-windows-server-2012-r2/#respond)

Сегодня мы разберемся, как установить и настроить клиент NFS (Network File System) в Windows Server 2012 R2 / Windows 8. Итак, чтобы подключить каталог (шару) [с NFS сервера](https://winitpro.ru/index.php/2013/04/22/nfs-server-na-windows-server-2012/) в Windows Server 2012 R2 / Win 8, нужно, как и в предыдущих версиях Windows, установить отдельный компонент — клиент NFS (**Client for NFS**). Дополнительно, для возможности управления настройками NFS подключения, можно установить компонент служб NFS (**Services for Network File System**).

Клиент NFS входит в состав ОС Microsoft, начиная с Windows 7. В Windows 2012 / 8 клиент NFS получил небольшие изменения. Теперь NFS клиент поддерживает аутентификацию по протоколу Krb5p — Kerberos версии 5 (в дополнение к Krb5 и Krb5i, поддержка которых появилась еще в Windows 7), поддерживаются большие NFS пакеты – до 1024KB (в Win 7 максимальный размер пакета 32KB)

Клиент NFS можно установить через GUI или с помощью Powershell. Для установки в графическом режиме, откройте [консоль Server Manager](https://winitpro.ru/index.php/2012/10/25/konsol-server-manager-v-windows-server-2012/) и выберите компонент (Features) под названием **Client for NFS**.[![nfs клиент в windows server 2012 r2](https://winitpro.ru/wp-content/uploads/2014/08/client-for-nfs-windows2012r2.jpg "nfs клиент в windows server 2012 r2")](https://winitpro.ru/wp-content/uploads/2014/08/client-for-nfs-windows2012r2.jpg)

По умолчанию вместе с этим компонентом не устанавливается графическая консоль управления NFS, чтобы исправить это, установим опцию **Services for Network File System Management Tools** в разделе Remote Server Administration Tools -> Role Administration Tools -> File Services Tools.[![Services for Network File System Management Tools в windows server 2012 r2](https://winitpro.ru/wp-content/uploads/2014/08/services-for-nfs-windows2012.jpg "Services for Network File System Management Tools в windows server 2012 r2")](https://winitpro.ru/wp-content/uploads/2014/08/services-for-nfs-windows2012.jpg)

Для установки NFS-клиента в Windows 8 нужно активировать компонент **Services for NFS ->Client for NFS**, через установку/удаление компонентов (Turn Windows features on or off) в Панели управления (Control Panel -> Programs -> Programs and Features).

**Примечание**. В отличии от Windows 7, в которой NFS клиент присутствовал в редакциях Enterprise и Ultimate, в Windows 8 клиент Network File System поддерживается только в старшой версии — Windows 8 Enterprise.

Все перечисленные выше компоненты системы можно установить всего одной командой Powershell:

Install-WindowsFeature NFS-Client, RSAT-NFS-Admin

[![Установка клиента nfs в Windows с помощью powershell](https://winitpro.ru/wp-content/uploads/2014/08/install-nfs-client-powershell.jpg "Установка клиента nfs в Windows с помощью powershell")](https://winitpro.ru/wp-content/uploads/2014/08/install-nfs-client-powershell.jpg)

После окончания установки, запустите консоль **Services for Network File System Managemen** и откройте окно свойств NFS клиента (**Client for NFS**).

[![параметры NFS клиента (Client for NFS).](https://winitpro.ru/wp-content/uploads/2014/08/client-for-nfs.png "параметры NFS клиента (Client for NFS).")](https://winitpro.ru/wp-content/uploads/2014/08/client-for-nfs.png)

В настройках NFS клиента можно задать:

- Используемый транспортный протокол (Transport protocols) – по умолчанию TCP+UDP
- Тип монтирования NFS шар: hard или soft
- На вкладке File Permissions указываются дефолтные права для создаваемых папок и файлов на NFS шарах
- На вкладке Security указываются протоколы аутентификации, с помощью которых можно аутентифицироваться на NFS сервере

[![Настройки NFS клиента в Windows](https://winitpro.ru/wp-content/uploads/2014/08/nfs-clien-settings.jpg "Настройки NFS клиента в Windows")](https://winitpro.ru/wp-content/uploads/2014/08/nfs-clien-settings.jpg)

После настройки установки, администраторы смогут смонтировать NFS каталог с помощью команды mount:

Mount \\lx01.abc.lab\nfs z:

[![mount - команда монтирования сетевого каталога nfs](https://winitpro.ru/wp-content/uploads/2014/08/mount-nfs-share.png "mount - команда монтирования сетевого каталога nfs")](https://winitpro.ru/wp-content/uploads/2014/08/mount-nfs-share.png)

В этом примере мы смонтировали под буквой Z: каталог NFS, расположенный на сервере lx01.abc.lab.

После монтирования, подключенный таким образом каталог на NFS сервере доступен в системе как отдельный диск с буквой Z:\ .

Смонтировать NFS шару можно и с помощью Powershell:

New-PSdrive -PSProvider FileSystem -Name Z -Root \\lx01.abc.lab\nfs

**Примечание**. Подключенный таким образом nfs каталог будет доступен только внутри сессии Powershell, в которой была выполнена команда монтирования. Чтобы смонтировать NFS каталог в системе на постоянной основе, в конце Powershell команды нужно добавить ключ **–Persist**.

Отключить смонтированный каталог можно так:

Remove-PSdrive -Name Y