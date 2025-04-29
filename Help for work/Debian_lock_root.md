# Посмотреть содержагте конфига
cat /etc/ssh/sshd_config

# Редактируем конфигурационный файл
- PermitRootLogin no

# После редактирования надо перезагрузить сервис.
/etc/init.d/ssh restart

