---
tags: chrome
---
Для Windows – открываем PowerShell от имени администратора и вписываем команду:

$path = "registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Google\Chrome"; New-Item $path -Force; Set-ItemProperty $path -Name ExtensionManifestV2Availability -Value 2

🟠Для MacOS – открываем приложение Терминал и запускаем команду:

defaults write com.google.Chrome.plist

ExtensionManifestV2Availability -int 2

🟠Заходим в chrome://policy/ и жмём «Повторно загрузить правила».