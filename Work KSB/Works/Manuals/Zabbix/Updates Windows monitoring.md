#windows #zabbix

на server качаем скрипты 
проверяем 
powershell -NoProfile -ExecutionPolicy bypass -File >  "C:\\zabbix-agent-scripts\\DaysSinceLastUpdate.ps1"

добавляем user parametrs
UserParameter=DaysSinceLastUpdate,powershell.exe -NoProfile -ExecutionPolicy bypass -File "C:\\zabbix-agent-scripts\\DaysSinceLastUpdate.ps1"

Создаем template  или  Item