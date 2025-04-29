#bash #linux #snmp

```
snmpwalk -v3 -l authPriv -u snmp-poller -a SHA -A "PASSWORD1" -x AES -X "PASSWORD1" 10.10.60.50

snmpget -v3 -l authPriv -u snmp-poller -a SHA -A "PASSWORD1" -x AES -X "PASSWORD1" 10.10.60.50 sysName.0 system.sysUpTime.0
```


```
snmpwalk -v2c -c public 192.168.1.1 .1.3.6.1.2.1.1.5.0
```