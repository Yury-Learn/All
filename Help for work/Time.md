#linux #bash #date #ntp

```sh
timedatectl set-timezone Europe/Moscow
```
	 `timedatectl list-timezones`

```sh
apt update && apt upgrade tzdata
```

```sh
systemctl status systemd-timesyncd
systemctl enable systemd-timesyncd
```

`ntpdate pool.ntp.org`

```
	 apt install ntpdate
	 systemctl start ntp
	 systemctl enable ntp
```

Windows
```cmd
w32tm /stripchart /computer:[ИМЯ ИЛИ IP АДРЕС] /dataonly /samples:3
```


```sh
ntpdate -q [ИМЯ ИЛИ IP АДРЕС]
```


### Synchronize time Automatically Using NTP

NTP client can automatically be configured to query NTP server by using the NTPd daemon.

Install NTP on Ubuntu/Debian

```
sudo apt install ntp -y
```

The installation of NTP will mask the **`systemd-timesyncd.service`**.

The NTP service is set to run by default after installation. First check if the client is synchronized with NTP:

```
timedatectl
```

The output will show if the system clock is synchronized or not. The output below clearly indicates time is not synced to any server.

```
               Local time: Sat 2022-05-14 12:20:04 UTC
           Universal time: Sat 2022-05-14 12:20:04 UTC
                 RTC time: Sat 2022-05-14 12:20:04
                Time zone: Etc/UTC (UTC, +0000)
System clock synchronized: no
              NTP service: n/a
          RTC in local TZ: no
```

To configure the NTP client to synchronize time from your NTP server, edit the ntp configuration file:

```
 sudo vim /etc/ntp.conf 
```

Replace public NTP pool servers with your server.

```
#pool 0.ubuntu.pool.ntp.org iburst
#pool 1.ubuntu.pool.ntp.org iburst
#pool 2.ubuntu.pool.ntp.org iburst
#pool 3.ubuntu.pool.ntp.org iburst

pool 192.168.59.38 iburst
```

Ideally the server can be added without commenting out the default NTP servers by making it the preferred reference clock using the **prefer** option:

```
pool 192.168.59.38 prefer iburst
```

Save the configuration file and restart ntp.

```
 sudo systemctl restart ntp
```

The client is now successfully configured to sychronize system time with NTP server. This can be verified by running the command:

```
ntpq -p
```

```
     remote           refid      st t when poll reach   delay   offset  jitter
==============================================================================
 192.168.59.38   .POOL.          16 p    -   64    0    0.000   +0.000   0.000
 ntp.ubuntu.com  .POOL.          16 p    -   64    0    0.000   +0.000   0.000
*192.168.59.38   91.189.89.198    3 u    2   64    1    1.732  +16.240   0.089
 chilipepper.can 17.253.34.251    2 u    8   64    1  255.060  -41.243   0.000
 pugot.canonical 17.253.108.125   2 u    5   64    1  171.300   -0.021   0.000
 golem.canonical 134.71.66.21     2 u    4   64    1  263.212  -45.093   0.000
 alphyn.canonica 194.58.200.20    2 u    5   64    1  251.289   +2.991   0.000
```

From the output we can see NTP server (192.168.56.103) as the time synchronization host/source in the queue.

Confirm NTP service is set to start at boot time:

```
systemctl is-enabled ntp
```

To enable NTP service to start at boot time, just in case is not enabled, then you would run the command:

```
systemctl enable ntp
```

Great, your NTP Clients should now be able to query the time services from your NTP Server.