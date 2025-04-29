### Определение используемой службы журналирования

Чтобы определить используемую на источнике службу журналирования,
выполните команду:

####если установлена ОС Astra Linux, Debian или Ubuntu:

dpkg --list | grep syslog

####если ALT Linux, CentOS, Oracle Linux или Red Hat Enterprise Linux:

rpm -qa *syslog*

#### если SUSE Linux Enterprise Server:

zypper search *syslog* --installed-only | grep 'i |'
На экране появится название используемой службы.


Не обязательно вводить полное название службы, достаточно ввести часть.