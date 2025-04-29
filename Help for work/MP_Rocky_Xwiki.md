### Инструкция по сбору данных хромает.

Инструкция по настройке с помощью Python скрипта https://help.ptsecurity.com/projects/siem/8.1/ru-RU/help/3552476939

1) Для начала необходимо проверить наличие следующих пакетов: интерпретатор языка Python версии 3.0 и выше; пакеты auditd и audispd версии 2.6 и выше; пакет rsyslog версии 8 и выше или пакет syslog-ng версии 3 и выше.
2) Далее необходимо выполнить 4 шага, описанных в инструкции. В целом все понятно, единственное в шаге №4 необходимо выполнить скрипт со следующими параметрами:
sudo ./configure_siem_host.py --dst=tcp:10.38.22.85:1468 --syslog_service=rsyslog --restart

В параметре "--syslog_service=" необходимо указать тот syslog, который используется на сервере. Описание параметров скрипта есть в инструкции, 10.38.22.85:1468 это адрес коллектора SIEM.


### Дополнения к основной инструкции

setenforce 0
getenforce
sudo semanage port -a -t syslogd_port_t -p tcp 1468
setenforce 1
systemctl restart rsyslog.service
sudo nano /etc/audit/auditd.conf >>> priority_boost = 4 (поменять на 8)
sudo service auditd stop
sudo service auditd start
sudo nano /etc/audit/auditd.conf >>> q_depth = 1200 (поменяли на 2400) - не обязательно. 
sudo service auditd stop
sudo service auditd start

Уточнения по Xwiki. После этого ошибки пропали.


Для перезапуска сервиса AuditD
sudo service auditd stop
sudo service auditd start