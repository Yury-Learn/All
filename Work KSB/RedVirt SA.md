## Install RV SA
#redvirt #standalone

```sh
mkdir -p /srv/data
chown 36:36 /srv/data
chmod 0755 /srv/data
```

Поменять строку `alerting` на `unified_alerting` в файле:

```
/usr/share/ovirt-engine-dwh/conf/grafana.ini.in
```

![[Pasted image 20241107082735.png]]


```sh
engine-setup --accept-defaults
```

```sh
engine-config -s ImageTransferProxyEnabled=false
systemctl restart ovirt-engine
```