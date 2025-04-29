### Узнаем свой IP через консоль

get -O - -q icanhazip.com
wget -O - -q ip.mysokol.ru
curl ifconfig.me
wget -O - -q ifconfig.me/ip
lynx --source http://formyip.com/ | awk '/The/{print $5}'
wget -q -O - http://formyip.com/ | awk '/The/{print $5}'
wget -q -O - http://checkip.dyndns.com/ | awk '{print $6}' | sed 's/<.*>//' 
curl -s checkip.dyndns.org | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}'
curl ipinfo.io/ip
wget -qO- ident.me 
curl v4.ident.me
curl v4.ifconfig.co
curl v6.ifconfig.co
wget -qO- eth0.me
wget -qO- ipecho.net/plain
wget -qO- ipecho.net
wget -qO- myip.gelma.net
curl 2ip.ru
curl internet-lab.ru/ip
nslookup myip.opendns.com. resolver1.opendns.com



curl -kv [dns name or ip address]  [port] для проверки отклика ресурса