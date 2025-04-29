### PostgreSQL ошибка: psql: FATAL: Ident authentication failed for user "your_username"

Исправления: 

Заходим. 
sudo nano /var/lib/pgsql/data/pg_hba.conf

Прописываем доступ для IPv4: 
0.0.0.0/0 - все интерфейсы
127.0.0.1/32 - только для локальной машины
10.38.22.100 - только для сетевого интерфейса

Не забываем указать *md5* (меняем параметр *Ident*)