---
tags: zabbix
---
1. Сvотрим базу данных
	`grep "^DB" /etc/zabbix/zabbix_server.conf`

2. Заходим средствами PostgreSQL
```sql
	psql -U zabbix -d zabbix -h localhost
	password: zabbix 
```
3. Внутри оболчки PSQL
	`UPDATE users SET passwd = '$2a$10$ZXIvHAEP2ZM.dLXTm6uPHOMVlARXX7cqjbhM6Fn0cANzkCQBWpMrS' WHERE username = 'Admin';`
4. Пароль сброситься на Admin или zabbix