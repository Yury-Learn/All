---
tags:
  - powershell
  - "#windows"
---
# Атрибуты

Установка папки в качестве переменной 
	`$Folder = Get-Item 'S:\Students\Task\'` 
Установка атрибута папке
	`$folder.Attributes = $folder.Attributes -bor [System.IO.FileAttributes]::ReadOnly`
Снятия атрибута
	`$folder.Attributes = $folder.Attributes -band -bnot [System.IO.FileAttributes]::ReadOnly`
Проверка атрибута
	`$Folder.Attributes`
# Права доступа

установка модуля галереи PowerShell – **NTFSSecurity**
	`Install-Module -Name NTFSSecurity`
Импорт модуля
	`Import-Module NTFSSecurity`
Список команд, доступных в модуле
	`Get-Command -Module NTFSSecurity`
Текущие NTFS разрешения на каталог
	` Get-Item 's:\soft\ssi' | Get-NTFSAccess`
Чтобы предоставить конкретному пользователю и группе группе полные права на папку, выполните команду:
	`Add-NTFSAccess -Path s:\soft\ssi -Account 'KSB\litti.yb' -AccessRights 'Fullcontrol' -PassThru`
Удалить назначенные NTFS разрешения
	`Remove-NTFSAccess -Path C:\distr -Account 'WORKSTAT1\confroom' -AccessRights FullControl -PassThru`
Проверить эффективные права на все вложенные папки в каталоге для пользователя confroom
	`Get-ChildItem -Path c:\distr -Recurse -Directory | Get-NTFSEffectiveAccess -Account 'WORKSTAT1\confroom' | select Account, AccessControlType, AccessRights, FullName`
Проверить эффективные разрешения на конкретный файл
	`Get-Item -Path 'C:\distr\mstsc.exe.manifest' | Get-NTFSEffectiveAccess -Account 'WORKSTAT1\confroom' | Format-List`