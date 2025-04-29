MikoPBX

### Ошибка №1
Иногда маршрутизатор может подменять IP адрес. 
Поэтому надо в сетевых настройках Firewall через Web морду добавить разрешающие правила для конкретных IP адресов провайдера SIP номеров. 
example:
- ping sip.infranet.ru
- вставляем [91.143.144.6]

### Вызов CLI Asterisk 
- asterisk -r
- смотрим регистрацию pjsip: pjsip show registrations


### Показывает дерикторию места нахождения
- whereis asterisk - показывает дерикторию места нахождения

### Команда для просмотра регистрации номеров
 
- sngrep - это SIP messages flow viewer


### Комнада для отображения правил для iptaables

iptables -nvL