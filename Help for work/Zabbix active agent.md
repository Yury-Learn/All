#zabbix #windows #linux 
### Клиент
1. на клиенте в zabbix_agentd.conf прописываем ServerActive 
2. правильный ==hostname==
3. перезапускаем service 
4. смотрим лог файл
### Сервер
1. на сервере прописываем узел с правильным ==hostname==
2. добавляем template **active**
3. мониторим