1. Устанавливаем правила для crontab

sudo EDITOR=nano crontab -l

00 1 * * 1 bash /home/ksb/scripts/cpe_exporter.sh >> /var/log/sca/cpe_exporter.log 2>&1
20 2 * * 1 bash /home/ksb/scripts/main_packages_exporter.sh >> /var/log/sca/main_packages_exporter.log 2>&1

-  создаем /var/log/sca/cpe_exporter.log
- создаем /var/log/sca/main_packages_exporter.log

sudo crontab -e (проверяем правила)