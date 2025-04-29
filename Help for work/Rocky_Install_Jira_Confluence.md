### Установка PostgreSQL на Red Hat Enterprise Linux - https://victorz.ru/202109091472
### Установка и активация Atlassian Confluence на CentOS 9 - https://victorz.ru/202302202827
### Установка и активация Atlassian JIRA Sowtware на CentOS 9 - https://victorz.ru/202302212850

Для jira обязательно надо сделать эти команды

firewall-cmd --get-active-zones
sudo firewall-cmd --zone=public --add-port=8080/tcp --permanent
sudo firewall-cmd --zone=public --list
sudo firewall-cmd --zone=public --list-all
firewall-cmd --reload
firewall-cmd --zone=public --list-all


### SSL to Jira https://computingforgeeks.com/install-and-configure-jira-on-debian/