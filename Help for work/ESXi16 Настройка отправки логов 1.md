## Настройка системного журнала Vmware
### GUI
Чтобы настроить на источнике журналирование и отправку событий на внешний syslog-сервер:
1. В адресной строке браузера введите IP-адрес или доменное имя источника.
2. Откроется страница VMware vSphere Web Client.
3. Авторизуйтесь на источнике под именем учетной записи администратора.
4. В панели Navigator выберите Host → Manage.
5. В открывшейся странице выберите вкладку System.
6. Выберите раздел параметров Advanced Settings.
![[Pasted image 20240404132717.png]]
7. В таблице для параметра с ключом Config.HostAgent.log.level в колонке Value выберите в раскрывающемся списке info.
8. в параметре Syslog.global.logHost необходимо указать данное значение tcp://ip:port (это адрес коллектора SIEM)
### Через командную строку 
1. Включаем ssh в services (==не забыть потом выключить==)
3. Вводим
```excli
esxcli system syslog config get  
esxcli system syslog config set --loghost="tcp://syslogserver:514"  
esxcli system syslog reload
```
	-проверка конфигурации
	установка пути до приёмника
	перезагрузка сервиса
3. если ошибка, то смотрим **Syslog.global.logDir** папку куда пишутся логи
	1. проверяем
		`ls /path/log`
	2. если пусто в esxcli создаём новую папку для логов
		`mkdir /path/logs`
4. прописываем в **Syslog.global.logDir** новый путь
	проверяем логи
	`ls /path/logs`
## Настройка межсетевого экрана источника
### GUI
Чтобы настроить межсетевой экран источника:
1. В панели Navigator выберите Networking.
2. В открывшейся странице выберите вкладку Firewall rules.
![[Pasted image 20240404150444.png]]
3. В таблице выберите правило с именем syslog.
4. В панели инструментов нажмите кнопку Actions и в открывшемся меню выберите Enable.
5. Межсетевой экран настроен.
### ESXCLI
Используйте следующую команду, чтобы настроить брандмауэр Vmware для разрешения подключения Syslog.
1. Создаём правило
`esxcli network firewall ruleset set --ruleset-id=syslog --enabled=true`
2. Обновляем
`esxcli network firewall refresh`

## Проверка доступности узла

`nc -z ipaddress port`

