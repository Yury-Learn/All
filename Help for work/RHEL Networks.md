#network #bash
`systemctl restart NetworkManager`
`ifdown eth1 && ifup eth1`
`nmcli networking off && nmcli networking on`
`nmtui`