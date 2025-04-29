#debian #linux #fail2ban #users #network #tmux
- очищаем clone
```bash
rm -f /etc/machine-id
dbus-uuidgen --ensure=/etc/machine-id
```

 - суперпользователь 
```bash
sudo adduser <example username>
sudo usermod -aG sudo/wheel <example username>
```
- установка пакетов
```bash
apt update && apt-get dist-upgrade
apt install mc net-tools tree ncdu bash-completion curl dnsutils htop iftop pwgen exa screen sudo wget bat ripgrep  duf fd fzf btop
```
- tmux
```bash
apt install tmux && touch ~/.tmux.conf && echo "setw -g mouse on" >> ~/.tmux.conf && echo "set-hook -g session-created 'split -h mc ; split -v btop'" >> ~/.tmux.conf && source ~/.bashrc && tmux source ~/.tmux.conf
```
- подсветка
```
# TRIAL without installation

git clone --recursive --depth 1 --shallow-submodules https://github.com/akinomyoga/ble.sh.git
make -C ble.sh
source ble.sh/out/ble.sh

# Quick INSTALL to BASHRC (If this doesn't work, please follow Sec 1.3)

git clone --recursive --depth 1 --shallow-submodules https://github.com/akinomyoga/ble.sh.git
make -C ble.sh install PREFIX=~/.local
echo 'source ~/.local/share/blesh/ble.sh' >> ~/.bashrc
```

- Подсказчик cheatsheet
```bash
cd /tmp \
  && wget https://github.com/cheat/cheat/releases/download/4.4.2/cheat-linux-amd64.gz \
  && gunzip cheat-linux-amd64.gz \
  && chmod +x cheat-linux-amd64 \
  && sudo mv cheat-linux-amd64 /usr/local/bin/cheat
```
- Замена cd zoxide
```bash
apt install zoxide
echo 'eval "$(zoxide init bash)"' > ~/.bashrc && source ~/.bashrc
```
- установка fail2ban
`apt install fail2ban`
[[Fail2ban_Debian_Rocky]]

mcedit /etc/fail2ban/jail.d/default.conf
[sshd]
enabled  = true
findtime = 120
maxretry = 3
bantime = 43200
- подсветка синтаксиса
`cp /usr/share/mc/syntax/sh.syntax /usr/share/mc/syntax/unknown.syntax`

#### Имя
1. пишем имя
`hostnamectl set-hostname _____`
1. редактируем файл `mcedit /etc/hosts`
   >127.0.1.1 имя_хоста
3. Перезапуск сети
   `systemctl restart networking`
OR
`systemctl start systemd-resolved`
`systemctl enable systemd-resolved`

  
- настройка интерфейсов
```sh
cat <<EOL > /etc/network/interfaces
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).
# /etc/network/interfaces.d/*
# The loopback network interface

auto lo
iface lo inet loopback
auto ens160
iface ens160 inet static
address 10.38.22.106
netmask 255.255.255.0
gateway 10.38.22.1

#для новых машин
#dns-nameservers 8.8.8.8
#для машин, которые водим в домен

dns-nameservers 10.38.22.4
dns-search ksb.ksb-soft.ru
EOL
```

 - Отключаем NetworkManager
```sh
sudo systemctl stop NetworkManager
sudo systemctl disable NetworkManager
sudo systemctl mask NetworkManager
```
  - редактируем DNS
файл
> etc\\resolv.conf

> domain ksb.ksb-soft.ru
> search ksb.ksb-soft.ru
> nameserver 10.38.22.4
> nameserver 10.38.22.5

==REBOOT==

---

```sh
wget https://raw.githubusercontent.com/imbicile/shell_colors/master/shell_color
chmod +x shell_color
./shell_color
rm shell_color
source ./.bashrc
```

#### tmux
[[Tmux | Основная инструкция]]
`apt install tmux`
- управление мышкой edit .conf
>/etc/tmux.conf`
OR
>~/.tmux.conf
Вставляем
> set -g mouse on

source ~/.bashrc

#### etc/hosts доменные имена

>127.0.0.1 localhost.localdomain localhost
>10.38.22.98 pxe.ks.test pxe
>127.0.1.1 pxe

certbot.eff.org
eval "$(direnv hook bash)"

#### IPTables
[[IP_Tables]]

#### Docker
[[Docker_1_step_debian | Установка]]
[[Docker_Compose_2_step_debian | Docker compose]]
[[Docker_Compose_3_step_debian | Docker compose 2]]
[[Alias Docker | алиасы для Docker для удобной работы]]

Alias
alias ls="exa"
alias ll="exa -alh"
alias tree="exa --tree"