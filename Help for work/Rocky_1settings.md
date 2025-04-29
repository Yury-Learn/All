### Шаги после установки ОС RockyLinux.

1. sudo dnf install epel-realese -y (добавляем репозиторий CentOS)
2. Настройка /etc/ssh/sshd_config
   *Root* - no

3. fail2ban - settings, enable, restart

4. dnf install mc

5. sudo hostnamectl set-hostname example.local

6. date - согласно поясу

7. adduser 8host

8. usermod -aG wheel 8host (reboot server)

9. dnf update && dnf upgrade

10. snapshot перед установкой сервиса