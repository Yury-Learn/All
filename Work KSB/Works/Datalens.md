#datalens #docker 

Цепочка90!

10.38.22.101
ksb 
qGxtghg4j5VeJFHSFR
## Datalens

POSTGRES_PASSWORD: "EhhWjSsVG3Mzu22e3R"
      POSTGRES_DB: postgres
      POSTGRES_USER: ksb-user

### docker-compose.yml
- postgres
	POSTGRES_PASSWORD: "EhhWjSsVG3Mzu22e3R"
	POSTGRES_DB: ksb-datalens
	POSTGRES_USER: ksb-user




ksbadmin@ksb-soft.ru
7hyDBL6omWkMoB7uQG

user_db
ipqS2733EyWsTuu4Rn


docker inspect 

There should be a line in your 
`postgresql.conf`
 file that says:
`   port = 1486   `
`listen_address = *`

`pq_hba.conf`
>	host *testdb* *testuser* 0.0.0.0/0 md5

psql -h 10.38.22.54 -U user_db -d datalens -p 5442


Change that.The location of the file can vary depending on your install options. On Debian-based distros it is 
`/etc/postgresql/8.3/main/`
On Windows it is 
`C:\Program Files\PostgreSQL\9.3\data`

Don't forget to 
`sudo service postgresql restart`
 for changes to take effect.

createuser --interactive
createdb *testdb*
psql 
	grant all privileges on database *testdb* to *testuser*
	alter user *testuser* with encrypted password '*testpassword*'
