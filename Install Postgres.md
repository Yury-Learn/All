---
tags: postgresql, linux
---
# How To Install PostgreSQL 15,14,13,12 on Debian 12 (Bookworm) - TechViewLeo

## Step 1: Update system

Begin the installation by ensuring your system is up-to-date.

```sh
sudo apt update && sudo apt upgrade -y
```

After an update a reboot may be required. Run the commands below to confirm if it is required.

```sh
[ -f /var/run/reboot-required ] && sudo reboot -f
```

## Step 2: Add PostgreSQL repositories

Not all PostgreSQL database release versions are available in the OS APT repositories. We shall add official PostgreSQL repositories before installing any packages.

```sh
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
```

Also import the repository GPG key.

```sh
curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc|sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/postgresql.gpg
```

Update the package lists.

```sh
sudo apt update
```

## Step 3: Install PostgreSQL 15,14,13,12 on Debian 12

Finally install PostgreSQL server and client packages.

```sh
## Install PostgreSQL 15 ###
sudo apt install postgresql-15

## Installing PostgreSQL 14 ###
sudo apt install postgresql-14

## Install PostgreSQL 13 ###
sudo apt install postgresql-13

## Install PostgreSQL 12 ###
sudo apt install postgresql-12
```

Once the installation is complete, start PostgreSQL service and enable automatic start on reboot.

```sh
##  PostgreSQL 15 ###
sudo systemctl enable --now postgresql@15-main.service

##  PostgreSQL 14 ###
sudo systemctl enable --now postgresql@14-main.service

##  PostgreSQL 13 ###
sudo systemctl enable --now postgresql@13-main.service

##  PostgreSQL 12 ###
sudo systemctl enable --now postgresql@12-main.service
```

Then check the status of the service with the following command.

```sh
$ systemctl status postgresql@*-main.service
● postgresql@14-main.service - PostgreSQL Cluster 14-main
     Loaded: loaded (/lib/systemd/system/postgresql@.service; enabled; preset: enabled)
     Active: active (running) since Tue 2023-07-25 10:53:34 UTC; 4min 30s ago
   Main PID: 4561 (postgres)
      Tasks: 7 (limit: 4531)
     Memory: 17.4M
        CPU: 393ms
     CGroup: /system.slice/system-postgresql.slice/postgresql@14-main.service
             ├─4561 /usr/lib/postgresql/14/bin/postgres -D /var/lib/postgresql/14/main -c config_file=/etc/postgresql/14/main/postgresql.conf
             ├─4563 "postgres: 14/main: checkpointer "
             ├─4564 "postgres: 14/main: background writer "
             ├─4565 "postgres: 14/main: walwriter "
             ├─4566 "postgres: 14/main: autovacuum launcher "
             ├─4567 "postgres: 14/main: stats collector "
             └─4568 "postgres: 14/main: logical replication launcher "

Jul 25 10:53:31 deb12 systemd[1]: Starting postgresql@14-main.service - PostgreSQL Cluster 14-main...
Jul 25 10:53:34 deb12 systemd[1]: Started postgresql@14-main.service - PostgreSQL Cluster 14-main.
```

You can check the version of your PostgreSQL with the following commands:

```sh
sudo -u postgres psql -c "SELECT version();"
```

The output will be like below:

```
                                                          version                                                           
-----------------------------------------------------------------------------------------------------------------------------
 PostgreSQL 14.8 (Debian 14.8-1.pgdg120+1) on x86_64-pc-linux-gnu, compiled by gcc (Debian 12.2.0-14) 12.2.0, 64-bit
(1 row)
```

## Step 4: Secure your PostgreSQL Database

Connect to PostgreSQL CLI management console.

```sh
$ sudo -u postgres psql
psql (15.1 (Debian 15.1-1.pgdg110+1))
Type "help" for help.

postgres=# 
```

Set strong password for **_postgres_** user.

```sql
postgres=# ALTER USER postgres PASSWORD 'DBStr0ngUserPassw0rd';
ALTER ROLE
postgres=#
```

Then exit the shell with the following command.

```sql
postgres=# \q
```

## Step 5: Allowing remote connections (optional)

By default, PostgreSQL listens from the local host connection. To allow remote connection, edit the configuration file.

```sh
sudo nano /etc/postgresql/*/main/postgresql.conf
```

Set to **listen_addresses = ‘*’** in the CONNECTIONS AND AUTHENTICATION section to instruct the server to listen on all network interfaces. Also, remove the # to comment it out for it to function.

```sql
#------------------------------------------------------------------>
# CONNECTIONS AND AUTHENTICATION
#------------------------------------------------------------------>

# - Connection Settings -

listen_addresses = '*'          # what IP address(es) to listen on;
                                        # comma-separated list of a>
                                        # defaults to 'localhost'; >
                                        # (change requires restart
```

Password authentication on your PostgreSQL server can be enabled by running the following command.

```sh
sudo sed -i '/^host/s/ident/md5/' /etc/postgresql/*/main/pg_hba.conf
```

Then change the identification method from **peer** to **trust,** which accepts the connection without further requirements with the following command.

```sh
sudo sed -i '/^local/s/peer/trust/' /etc/postgresql/*/main/pg_hba.conf
```

Specify the remote network range or IP address allowed to connect by creating an entry to the _pg_hba.conf_ file.

```sh
sudo nano /etc/postgresql/*/main/pg_hba.conf
```

Add the following entry to the file to accept all remote connections.

```
host      all      all      0.0.0.0/0       md5
```

To allow IP from a local network, you could use the following:

```
host      all      all      192.168.200.0/24      md5
```

Save the file and restart the PostgreSQL service to apply changes.

```sh
sudo systemctl restart postgresql@15.service
```

## Step 6: Create a User and Database

Open PostgreSQL `psql` shell.

```sh
sudo -i -u postgres 
```

A user is created using `createuser` command

```sql
createuser mydbuser
```

To create database on PostgreSQL, use the commands

```sql
createdb myDB
```

Create a password for the user. First, log in to the shell:

```
$ psql
```

Set strong password for the user.

```sql
ALTER USER mydbuser PASSWORD 'myDBPassword';
```

Assign the database to the new user:

```sql
GRANT ALL PRIVILEGES ON DATABASE newDB to techviewleo;
```

Quit the shell:

```sql
\q
```

## Step 7: Create a table, input data, and clean it

Access the database created.

```sh
sudo -i -u postgres psql myDB
```

To create a table. Use the **CREATE** statement to do so. I will be creating a simple table with the attributes as shown below.

```sql
CREATE TABLE colleagues (
        ID                       int,
        First_Name          varchar(50),
        Last_Name          varchar(50),
        Department         varchar(50)
);
CREATE TABLE
```

Then populate your table with data using the following command with the **INSERT** statement:

```sql
INSERT INTO colleagues 
VALUES  ( 2019, 'Mark', 'Carlton', 'Accounts'),
             ( 2341, 'Jane', 'Doe', 'IT'),
             ( 2134, 'John', 'Doe', 'HR'),
             ( 3123, 'Sia', 'Nungari', 'Reception'),
             ( 6231, 'Karen', 'Karfield', 'Reception'),
             ( 6543, 'Amos', 'Wart', 'Accounts');
INSERT 0 6
```

To Query a table, use the **SELECT** statement.

```sql
newDB=# SELECT * FROM colleagues;
  id  | first_name | last_name | department 
------+------------+-----------+------------
 2019 | Mark       | Carlton   | Accounts
 2341 | Jane       | Doe       | IT
 2134 | John       | Doe       | HR
 3123 | Sia        | Nungari   | Reception
 6231 | Karen      | Karfield  | Reception
 6543 | Amos       | Wart      | Accounts
(6 rows)
```

You can remove a row from a table using the **DELETE** command.

```sql
newDB=# DELETE FROM colleagues WHERE Department = 'Accounts';
DELETE 2
```

Then check the table; the records from the Accounts department are removed.

```sql
newDB=# SELECT * FROM colleagues;
  id  | first_name | last_name | department 
------+------------+-----------+------------
 2341 | Jane       | Doe       | IT
 2134 | John       | Doe       | HR
 3123 | Sia        | Nungari   | Reception
 6231 | Karen      | Karfield  | Reception
(4 rows)
```

To drop a table, use the **DROP** statement:

```sql
newDB=# DROP TABLE colleagues;
DROP TABLE
```

## Step 8: Connect to PostgreSQL from a remote instance

For remote connection use syntax:

```sh
psql 'postgres://<username>:<password>@<host>:<port>/<db>?sslmode=disable'
```

Here is an example.

```sh
psql 'postgres://mydbuser:myDBPassword@192.168.1.20:5432/newDB?sslmode=disable'
```

You can now operate your PostgreSQL database server like it was local.

## Show Database 
```sql
\l
```

### Логи
```sh
 tail -f /var/lib/postgresql/15/main/pg_log/postgresql-<>.log
```