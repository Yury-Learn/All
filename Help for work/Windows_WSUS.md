# Итак, чтобы удалить старые обновления из базы данных WSUS, следуйте этой процедуре:

- Войдите с учетной записью, обладающей правами локального администратора, на сервер обновлений WSUS.
- Остановите веб сайт WSUS, остановив службу Internet Internet Information Services (IIS). Чтобы сделать это, откройте IIS из административных инструментов, перейдите на сайт «WSUS Administration Web site», щелкните правой кнопкой мыши по веб-узлу и нажмите кнопку Stop.
- Откройте окно командной строки и перейдите в папку %drive%\Program Files\Update Services\Tools

# Введите следующее:

wsusutil.exe deleteunneededrevisions






## Установите модуль на свой компьютер из галереи скриптов PSGallery:

	Install-Module -Name PSWindowsUpdate

## Разрешите запуск PowerShell скриптов:

	Set-ExecutionPolicy –ExecutionPolicy RemoteSigned -force

## Выполните команду:

	Reset-WUComponents –verbose