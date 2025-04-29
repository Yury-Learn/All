```sh
nmcli general status
nmcli general hostname
nmcli device status
nmcli connection show
```

```sh
nmcli connection show "Проводное соединение 2"
```

```sh
nmcli conn up "Проводное соединение 2"
```

```sh
nmcli connection add con-name "dhcp" type ethernet ifname enp24s0
```

```sh
nmcli connection add con-name "static" ifname enp2s0 autoconnect no type ethernet ip4 192.168.0.210 gw4 192.168.0.1
```

```sh
nmcli conn modify "static" ipv4.dns 8.8.8.8
```

```sh
 nmcli conn modify "static" +ipv4.dns 8.8.4.4
```

```sh
nmcli conn modify "static" +ipv4.addresses 192.168.0.240/24
```

```sh
 nmcli connection up static
```