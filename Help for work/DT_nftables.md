sudo nano /etc/systemd/system/nftables-rules.service


### Config


[Unit]
Description=Apply nftables rules on host
After=networking.service

[Service]
Type=oneshot
#Create table
ExecStart=/sbin/nft add table inet firewall-host
#Create chain
ExecStart=/sbin/nft add chain inet firewall-host INPUT { type filter hook input priority 0; }
#For 22
ExecStart=/sbin/nft insert rule inet firewall-host INPUT iif ens33 tcp dport 22 ip saddr { 10.38.40.79, 10.38.40.68, 10.38.40.15 } accept
ExecStart=/sbin/nft add rule inet firewall-host INPUT iif ens33 tcp dport 22 drop
#For 8443
ExecStart=/sbin/nft insert rule inet firewall-host INPUT iif ens33 tcp dport 8443 ip saddr { 10.38.40.79, 10.38.40.68, 10.38.40.15 } accept
ExecStart=/sbin/nft add rule inet firewall-host INPUT iif ens33 tcp dport 8443 drop
#For 9443
ExecStart=/sbin/nft insert rule inet firewall-host INPUT iif ens33 tcp dport 9443 ip saddr { 10.38.40.79, 10.38.40.68, 10.38.40.15 } accept
ExecStart=/sbin/nft add rule inet firewall-host INPUT iif ens33 tcp dport 9443 drop
ExecStop=/sbin/nft delete table inet firewall-host
RemainAfterExit=yes


[Install]
WantedBy=multi-user.target