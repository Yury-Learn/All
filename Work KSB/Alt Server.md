#alt #network 

## 1. Конфигурационные файлы

Конфигурационные файлы сетевых служб **systemd** хранятся в каталоге */etc/systemd/network*.

Существует три типа конфигурационных файлов:

- .network — описывают параметры сети: IP, маршруты, DNS и другие;
- .link — описывают физические параметры каждого интерфейса: имя, MAC, MTU и т.д.;
- .netdev — описывают виртуальные интерфейсы, мосты.

1. ==Перезапустить systemd-networkd.service, чтобы настройки вступили в силу:==
    
```
systemctl restart systemd-networkd
```
### 2. Проводной интерфейс с DHCP

**Примечание:** Настройки для Ethernet-интерфейсов могут также изменяться в [ЦУС](https://www.altlinux.org/%D0%A6%D0%A3%D0%A1 "ЦУС") (модуль [Ethernet-интерфейсы](https://www.altlinux.org/Alterator-net-eth "Alterator-net-eth"). В этом случае будут созданы файлы конфигурации */etc/systemd/network/alterator-<Имя_интерфейса>.network,* например, /etc/systemd/network/alterator-enp0s3.network.

  
Пример файла */etc/systemd/network/20-enp0s3.network*:

	[Match]
	Name = enp0s3
	
	[Network]
	DHCP = ipv4
	LinkLocalAddressing = no
	IPv6AcceptRA = false
	
	[DHCPv4]
	UseDomains = true
	UseDNS = yes

###  3. Проводной интерфейс со статическим IP-адресом

Файл */etc/systemd/network/20-enp0s3.network*:

	[Match]
	Name = enp0s3
	
	[Network]
	IPv6AcceptRA = false
	Address = 192.168.0.196/24
	Gateway = 192.168.0.1
	Domains = test.alt
	DNS = 8.8.8.8
	
	[DHCPv4]

### 4. Сетевой мост с DHCP

Для создания моста на интерфейсе enp0s8 необходимо выполнить следующие действия:

1. Создать виртуальный интерфейс моста. Для этого создать файл, например, */etc/systemd/network/20-bridge.netdev* со следующим содержимым:
    
	    [NetDev]
	    Name=vmbr0
	    Kind=bridge
	    MACAddress=08:00:27:43:79:7b
    
    Можно не задавать MAC-адрес, в этом случае он будет сгенерирован на основе названия интерфейса и идентификатора машины.
    
2. Перезапустить `systemd-networkd.service`, чтобы настройки вступили в силу:
    
```sh
systemctl restart systemd-networkd
```
    
3. Проверка:
    
```sh
ip a
```
    3: enp0s8: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1000
        link/ether 08:00:27:43:79:7a brd ff:ff:ff:ff:ff:ff
    4: vmbr0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1000
        link/ether 08:00:27:43:79:7b brd ff:ff:ff:ff:ff:ff
    
    Интерфейс vmbr0 обнаружен, но выключен (DOWN).
    
4. Привязать реальный сетевой интерфейса Ethernet (в примере — **enp0s8**) к виртуальному мосту. Для этого создать файл, например, */etc/systemd/network/20-bridge.network* со следующим содержимым:
    
	    [Match]
	    Name=enp0s8
	    
	    [Network]
	    Bridge=vmbr0
    
    Реальному сетевому интерфейсу не должно быть назначено никакого IP-адреса.
    
5. Указать сетевые настройки виртуального моста. Для этого создать файл, например, */etc/systemd/network/20-bridge-dhcp.network* со следующим содержимым:
    
	    [Match]
	    Name=vmbr0
	    
	    [Network]
	    DHCP=ipv4
    
6. Перезапустить `systemd-networkd.service`, чтобы настройки вступили в силу:
    
```sh
systemctl restart systemd-networkd
```
    
7. Проверка:
    
```sh
ip a
```
    3: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel master vmbr0 state UP group default qlen 1000
        link/ether 08:00:27:43:79:7a brd ff:ff:ff:ff:ff:ff
    4: vmbr0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
        link/ether 08:00:27:43:79:7b brd ff:ff:ff:ff:ff:ff
        inet 192.168.0.189/24 metric 1024 brd 192.168.0.255 scope global dynamic vmbr0
           valid_lft 258385sec preferred_lft 258385sec
        inet6 fd47:d11e:43c1:0:a00:27ff:fe43:797b/64 scope global mngtmpaddr noprefixroute 
           valid_lft forever preferred_lft forever
        inet6 fe80::a00:27ff:fe43:797b/64 scope link 
           valid_lft forever preferred_lft forever
    

  

### 5. Объединение сетевых интерфейсов (bonding)

Создание объединения (**bond**) на интерфейсах **enp0s8** и **enp0s9** с режимом работы **active-backup**:

1. Создать объединённый интерфейс. Для этого создать файл, например, */etc/systemd/network/bond.netdev* со следующим содержимым:
    
	    [NetDev]
	    Name=bond0
	    Kind=bond
	    
	    [Bond]
	    Mode=active-backup
	    PrimaryReselectPolicy=always
	    MIIMonitorSec=10s
    
2. В качестве основного указать интерфейс **enp0s8** (файл */etc/systemd/network/enp0s8-bond0.network*):
    
	    [Match]
	    Name=enp0s8
	    
	    [Network]
	    Bond=bond0
	    PrimarySlave=true
    
3. В качестве запасного указать интерфейс enp0s9 (файл */etc/systemd/network/enp0s9-bond0.network*):
    
	    [Match]
	    Name=enp0s9
	    
	    [Network]
	    Bond=bond0
    
4. Указать сетевые настройки для виртуального интерфейса (файл */etc/systemd/network/bond0.network*):
    
	    [Match]
	    Name=bond0
	    
	    [Network]
	    DHCP=ipv4
    
5. Перезапустить **systemd-networkd** или перечитать настройки **networkctl**, чтобы настройки вступили в силу:
    
```
    networkctl reload
```
    
6. Проверка
    
```
    networkctl 
```
	IDX LINK   TYPE     OPERATIONAL SETUP     
      1 lo     loopback carrier     unmanaged
      2 enp0s3 ether    routable    configured
      3 enp0s8 ether    enslaved    configured
      4 enp0s9 ether    enslaved    configured
      6 bond0  bond     routable    configured
    
   5 links listed.
    
   Если отключить кабель от интерфейса **enp0s8** соединение сохранится:
   
```
networkctl 
```
	   IDX LINK   TYPE     OPERATIONAL      SETUP     
      1 lo     loopback carrier          unmanaged
      2 enp0s3 ether    routable         configured
      3 enp0s8 ether    no-carrier       configured
      4 enp0s9 ether    enslaved         configured
      6 bond0  bond     degraded-carrier configured
    

### 6. VLAN

В данном примере создадим два **VLAN**-интерфейса с идентификаторами 100 и 200 на интерфейсе enp0s3.

1. Создать **VLAN**-интерфейсы. Для этого создать два файла. Первый файл */etc/systemd/network/20-enp0s3.netdev* со следующим содержимым:
    
	    [NetDev]
	    Name=enp0s3.100
	    Kind=vlan
	    
	    [VLAN]
	    Id=100
	    
    Второй файл */etc/systemd/network/21-enp0s3.netdev* со следующим содержимым:
    
	    [NetDev]
	    Name=enp0s3.200
	    Kind=vlan
	    
	    [VLAN]
	    Id=200
    
2. Привязать сетевой интерфейса Ethernet к **VLAN**. Для в файл настройки сетевого интерфейса enp0s3, например */etc/systemd/network/alterator-enp0s3.network* добавить имена **VLAN**-интерфейсов:
    
	    [Match]
	    Name = enp0s3
	    [Network]
	    DHCP = ipv4
	    LinkLocalAddressing = no
	    IPv6AcceptRA = false
	    VLAN=enp0s3.100
	    VLAN=enp0s3.200
	    [DHCPv4]
	    UseDomains = true
	    UseDNS = yes
	    
1. Указать сетевые настройки для каждой **VLAN**. Для интерфейса **enp0s3.100** со статическим IP-адресом создать файл */etc/systemd/network/enp0s3.100.network* со следующим содержимым:
    
	    [Match]
	    Name=enp0s3.100
	    
	    [Network]
	    DHCP=no
	    
	    [Address]
	    Address=192.168.30.25/25
    
    Содержимое второго файла */etc/systemd/network/enp0s3.200.network* для интерфейса **enp0s3.200**:
    
	    [Match]
	    Name=enp0s3.200
	    
	    [Network]
	    DHCP=no
	    
	    [Address]
	    Address=192.168.30.145/25
    
4. Перезапустить `systemd-networkd.service`, чтобы настройки вступили в силу:
    
```sh
    systemctl restart systemd-networkd
```
    
5. Проверка:
    
```
ip -br a
```
    lo               UNKNOWN        127.0.0.1/8 ::1/128 
    enp0s3           UP             192.168.0.196/24 fe80::a00:27ff:fe85:1f31/64 
    enp0s3.100@enp0s3 UP             192.168.30.25/25 fe80::a00:27ff:fe43:79aa/64 
    enp0s3.200@enp0s3 UP             192.168.30.145/25 fe80::a00:27ff:fe85:1f31/64
    
    или
    
```
 networkctl list 
```
    IDX LINK       TYPE     OPERATIONAL SETUP      
      1 lo         loopback carrier     unmanaged
      2 enp0s3     ether    routable    configured 
      3 enp0s3.100 vlan     routable    configured 
      4 enp0s3.200 vlan     routable    configured 
    
    4 links listed.