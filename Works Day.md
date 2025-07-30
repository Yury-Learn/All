
kurtyakov.au@ksb-soft.ru
temp1024

mail.ksb-soft.ru
993
465

``` bash
apt install tmux && touch ~/.tmux.conf && echo "setw -g mouse on" >> ~/.tmux.conf && echo "set-hook -g session-created 'split -h mc ; split -v btop'" >> ~/.tmux.conf && source ~/.bashrc && tmux source ~/.tmux/conf
```

# Nmon


# ESxi16
Сетевая доступность от данных серверов к коллектору SIEM есть. Необходимо выполнить всего две инструкции:
1) https://help.ptsecurity.com/projects/siem/8.1/ru-RU/help/5308596363 - повторяем все шаги, единственное, в 7 шаге, в параметре Syslog.global.logHost необходимо указать данное значение tcp://10.38.22.85:1514 (это адрес коллектора SIEM)
2) https://help.ptsecurity.com/projects/siem/8.1/ru-RU/help/5308597131 - тут все просто, также выполняем все шаги.

Инструкции необходимо выполнить на каждом сервере.

На этом настройка серверов закончена, спасибо!