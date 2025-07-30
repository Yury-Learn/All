1 часть)

1.1 hostnamectl set-hostname repo.ks.test

1.2

----------------------------------------------------------------------------------------------------------------------------
				для новых машин, первая установка ALD Pro
----------------------------------------------------------------------------------------------------------------------------

```
echo -e "deb http://dl.astralinux.ru/astra/frozen/1.7_x86-64/1.7.4/repository-base 1.7_x86-64 main non-free contrib" | sudo tee /etc/apt/sources.list
```

```
echo -e "deb http://dl.astralinux.ru/astra/frozen/1.7_x86-64/1.7.4/repository-extended 1.7_x86-64 main contrib non-free" | sudo tee -a /etc/apt/sources.list
```

```
echo -e "deb https://dl.astralinux.ru/aldpro/stable/repository-main/ 2.1.0 main" | sudo tee /etc/apt/sources.list.d/aldpro.list
```

```
echo -e "deb https://dl.astralinux.ru/aldpro/stable/repository-extended/ generic main" | sudo tee -a /etc/apt/sources.list.d/aldpro.list
```

----------------------------------------------------------------------------------------------------------------------------
				развернут Репозиторий, но машины не в домене
-----------------------------------------------------------------------------------------------------
```
echo -e "deb http://10.38.22.130/repos/os-base/ 1.7_x86-64 main non-free contrib" | sudo tee /etc/apt/sources.list
```

```
echo -e "deb http://10.38.22.130/repos/os-extended/ 1.7_x86-64 main contrib non-free" | sudo tee -a /etc/apt/sources.list
```

```
echo -e "deb http://10.38.22.130/repos/os-main/ 1.7_x86-64 main contrib non-free" | sudo tee -a /etc/apt/sources.list
```

```
echo -e "deb http://10.38.22.130/repos/aldpro-main/ 2.1.0 main" | sudo tee /etc/apt/sources.list.d/aldpro.list
```

```
echo -e "deb http://10.38.22.130/repos/aldpro-extended/ generic main" | sudo tee -a /etc/apt/sources.list.d/aldpro.list
```


----------------------------------------------------------------------------------------------------------------------------
				развернут Репозиторий, машины в домене
----------------------------------------------------------------------------------------------------------------------------

echo -e "deb http://repo.ks.test/repos/os-base/ 1.7_x86-64 main non-free contrib" | sudo tee /etc/apt/sources.list
echo -e "deb http://repo.ks.test/repos/os-extended/ 1.7_x86-64 main contrib non-free" | sudo tee -a /etc/apt/sources.list
echo -e "deb http://repo.ks.test/repos/os-main/ 1.7_x86-64 main contrib non-free" | sudo tee -a /etc/apt/sources.list

echo -e "deb http://repo.ks.test/repos/aldpro-main/ 2.1.0 main" | sudo tee /etc/apt/sources.list.d/aldpro.list
echo -e "deb http://repo.ks.test/repos/aldpro-extended/ generic main" | sudo tee -a /etc/apt/sources.list.d/aldpro.list



```
sudo -i
```
```
cat <<EOL > /etc/apt/preferences.d/aldpro
Package: *
Pin: release n=generic
Pin-Priority: 900
EOL
```

```
cat <<EOL > /etc/hosts
# ip и имя клиента
127.0.0.1 localhost.localdomain localhost
10.38.22.135	pxe.ks.test	pxe
127.0.1.1 pxe
EOL
```

```
#127.0.0.1 localhost.localdomain localhost
#192.168.30.16 client1.domain.test client1
#127.0.1.1 client1

```
```
sudo systemctl stop NetworkManager
sudo systemctl disable NetworkManager
sudo systemctl mask NetworkManager

```
```
cat <<EOL > /etc/network/interfaces
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
address 10.38.22.135
netmask 255.255.255.0
gateway 10.38.22.1
#для новых машин
dns-nameservers 8.8.8.8
#для машин, которые водим в домен
#dns-nameservers 10.38.22.129
dns-search ks.test
EOL

```
#####REBOOOT####

reboot


2 часть)

sudo apt update && sudo apt install astra-update -y && sudo astra-update -A -r -T && sudo DEBIAN_FRONTEND=noninteractive apt-get install -q -y aldpro-client


3 часть)

cat <<EOL > /etc/resolv.conf
search ks.test
# ip контролера домена
nameserver 10.38.22.129
EOL


sudo /opt/rbta/aldpro/client/bin/aldpro-client-installer -c ks.test -u admin -p 123_Qwerty -d pxe -i -f


-с имя_домена

-u логин_админа

-p пароль_админа

-d имя_машины_в_домене



---------------------------------------------------------------------------
Проверка корректной установки окружения сервера из сетевого репозитория
----------------------------------------------------------------------------


Перед установкой клиентской части ПК «ALD Pro» следует проверить корректность
настроек,


1) на сервере объем оперативной памяти не менее 2 ГБ;

2) на сервере ОС Astra Linux функционирует на максимальном уровне защищенности. Для проверки необходимо от имени привилегированного пользователя выполнить в терминале команду:

sudo astra-modeswitch get

Результат выполнения команды должен быть:
2

3) в файле /etc/hostname указано корректное имя сервера в формате FQDN;

4) в файле /etc/hosts указаны корректные данные сервера;

5) в файле /etc/apt/sources.list указаны репозитории ОС Astra Linux;

6) в файле /etc/apt/sources.list.d/aldpro.list указаны репозитории

ПК «ALD Pro»;

7) для ПК «ALD Pro» присутствует файл /etc/apt/preferences.d/aldpro, определяющий его приоритет;

8) сетевой интерфейс сервера настроен на статический IP-адрес и в качестве DNSсервера указан первый контроллер домена.

9) проверить доступность dl.astralinux.ru с сервера, выполнив в терминале команду:

ping -c 3 dl.astralinux.ru

10) в файле /etc/resolv.conf указаны имя домена и IP-адрес первого контроллера домена:

cat /etc/resolv.conf



```
sudo apt dist-upgrade -y -o Dpkg::Options::=--force-confnew
```

```
DEBIAN_FRONTEND=noninteractive apt-get install -y -q aldpro-client
```

```
sudo /opt/rbta/aldpro/client/bin/aldpro-client-installer --domain ald.company.lan --account admin --password 'AstraLinux_174' --host pc-1 --gui --force
```

```
ipa privilege-add-permission 'Host Enrollment' --permissions='System: Add Hosts'
```
```
ipa role-add-member 'Enrollment Administrator' --users=enrolladmin
```
```
ipa dnsrecord-del ald.company.lan. pc-2 --del-all
```
```
 ipa host-del pc-2.ald.company.lan
```

```
sudo salt-key -y -d pc-2.ald.company.lan
```

```
ipa host-add pc-2.ald.company.lan --random --ip-address=10.0.1.52 --force
```
```
sudo ipa-client-install --mkhomedir --password='6FjD8g5sagj9apBOjzEKYoy' -U
```