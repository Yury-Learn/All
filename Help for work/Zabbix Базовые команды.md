#zabbix #bash #powershell

1. Zabbix сервер работает как демон. Для запуска сервера выполните:
`service zabbix-server start`
Эта команда будет работать на большинстве GNU/Linux системах. На других системах вам, возможно, потребуется выполнить:
` /etc/init.d/zabbix-server start
2. Аналогично, для остановки/перезапуска/просмотра состояния, используйте следующие команды:
` service zabbix-server stop
` service zabbix-server restart
` service zabbix-server status
3. Для добавления zabbix-server в автозапуск:
` systemctl enable zabbix-server`
4. Версия Zabbix Сервер
```sh
zabbix_server --version
```


#### Команды для управления процессами Zabbix / MySQL / Apache service
- Zabbix Server
`sudo systemctl <status/restart/start/stop> zabbix-server`
- MySQL Server
`sudo systemctl <status/restart/start/stop> mysql`
- Apache Server
`sudo systemctl <status/restart/start/stop> apache2`
- Zabbix Agent
`sudo systemctl <status/restart/start/stop> zabbix-agent`
`zabbix_get -s 10.38.22.71 -k agent.version`
`zabbix_get -s <host-name-or-IP> -p 10050 -k agent.ping`
`zabbix_get -s <host-name-or-IP> -p 10050 -k agent.version`
`zabbix_get -s <host-name-or-IP> -p 10050 -k agent.hostname`
`zabbix_get -s <host-name-or-IP> -p 10050 -k system.cpu.load[all,avg1]`


##UserParametrs
если добавить в *zabbix-agent.conf*
>UserParameter=<u>DaysSinceLastUpdate</u>,powershell.exe -NoProfile -ExecutionPolicy bypass -File "C:\\zabbix-agent-scripts\\DaysSinceLastUpdate.ps1"

то можно получить значение скрипта PS
zabbix_get -s @host -k <u>DaysSinceLastUpdate</u>