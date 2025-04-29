Ip a (Узнать ip)
export ftp_proxy="http://ksbproxy:3128" 
export http_proxy="http://ksbproxy:3128" 
export https_proxy="http://ksbproxy:3128" 
export socks_proxy="socks://ksbproxy:3128"
env | grep -i proxy
sudo nano /etc/apt/apt.conf
Acquire::http::proxy "http://ksbproxy:3128/"; 
Acquire::https::proxy "http://ksbproxy:3128/"; 
Acquire::ftp::proxy "http://ksbproxy:3128/"; 
Acquire::socks::proxy "socks://ksbproxy:3128/"; 
Acquire::::Proxy "true";
https://obu4alka.ru/proxy-terminal-system-linux.html
su - # Вход под root
apt update
apt install sudo
adduser zabbix # Создание пользователя zabbix
passwd zabbix # Изменение пароля пользователя zabbix
usermod -aG sudo zabbix # Выдача sudo прав для пользователя zabbix
sudo nano /etc/apt/sources.list
deb http://deb.debian.org/debian bullseye main 
deb-src http://deb.debian.org/debian bullseye main 
deb http://deb.debian.org/debian bullseye-updates main 
deb-src http://deb.debian.org/debian bullseye-updates main
sudo apt update 
sudo apt-get install openssh-server
sudo apt install wget
sudo apt update 
sudo apt upgrade
sudo wget https://repo.zabbix.com/zabbix/6.4/debian/pool/main/z/zabbix-release/zabbix-release_6.4-1+debian11_all.deb
sudo dpkg -i zabbix-release_6.4-1+debian11_all.deb
apt-get update –y
sudo apt install zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent
sudo nano /etc/php/7.4/apache2/php.ini
date.timezone = Europe/Moscow
sudo apt-get install mysql.server
mysql 
SET GLOBAL log_bin_trust_function_creators = 1; 
create database zabbix character set utf8mb4 collate utf8mb4_bin; 
create user zabbix@localhost identified by '334424'; 
grant all privileges on zabbix.* to zabbix@localhost; 
quit;
zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql -uzabbix -p zabbix
sudo nano /etc/zabbix/zabbix_server.conf
DBPassword=334424
systemctl restart zabbix-server zabbix-agent apache2
systemctl enable zabbix-server zabbix-agent apache2
http://server_ip_or_name/zabbix
nano /etc/locale.gen # нужно раскомментировать строчку
># en_US.UTF-8 UTF-8
```sh
locale-gen
service apache2 restart
sudo apt install ufw
sudo ufw allow from any to any port 10050 proto tcp
```
 
