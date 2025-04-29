## Если не устанавливается пакет и выходит похожие сообщения, то.
[ksb@notify ~]$ sudo dnf install fail2ban
[sudo] password for ksb: 
Last metadata expiration check: 1:45:18 ago on Tue Jan 30 07:18:09 2024.
No match for argument: fail2ban
Error: Unable to find a match: fail2ban

1. Надо сперва установить.
sudo yum install epel-release
2. Можно пробовать установку своего пакета по новой
В нашем примере: sudo yum/dnf install fail2ban




## Ошибка: Failed to download metadata for repo 'pgdg-common': repomd.xml GPG signature verification error: Bad GPG signature
Лечится такой командой
sudo dnf --disablerepo=* -y install https://download.postgresql.org/pub/repos/yum/reporpms/EL-9-x86_64/pgdg-redhat-repo-latest.noarch.rpm && sudo dnf check-update -y