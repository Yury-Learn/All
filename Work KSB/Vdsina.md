---
tags: vdsina, users, sudo
---
```sh
apt install fail2ban -y && systemctl start fail2ban && systemctl enable fail2ban
```

```sh
adduser user
usermod -aG sudo user
su - user
nano /etc/ssh/sshd_config
> #PermitRootLogin yes
sudo service sshd restart

```

```
touch /var/log/auth.log
```
port: 20533
URI-path: /vdsinapanel

>IP	194.164.35.46
>User	root
>Pass	VYN2K9wDYiiM5vi8
> 
>rogal@inbox.ru
>http://194.164.35.46:8588/
>Пароль VYN2K9wDYiiM5vi8

> [!NOTE]
> Вы заказали сервер с предустановленным OpenVPN. Доступ в панель управления: [http://194.164.35.46:8080/](http://194.164.35.46:8080/) 
> Пользователь: admin
> Пароль: VYN2K9wDYiiM5vi8

```
apt install mc net-tools tree ncdu bash-completion curl dnsutils htop iftop pwgen exa screen sudo wget bat ripgrep  duf fd fzf btop
```

```
curl -fsSL https://get.casaos.io | sudo bash
```

http://194.164.35.46 
bbyyll
21r_Casaos

> [!WG Easy]
> 🔧 Settings
> 
> Default password: `casaos`
> 
> ⚠️ Warning!
> 
> You need to change at least change the mandatory parameter `WG_HOST` for this app to work properly.  
> It’s value has to be a domain (or an IP address) that points to this server (accesible from WAN).
> 
> Same applies to the `WG_PORT` parameter. Change it to the port accessible from outside your LAN if it differs from the default 51820.

## Adguard
1. bbyyll / 21r_Ad