If you are using NetworkManager, the proper way to change the metric for the default route is to modify the connection associated with interface enp0s3 in this way:

`   nmcli connection modify <connection-name> ipv4.route-metric 1   `

and then re-activate the connection:

`   nmcli connection up <connection-name>   `

You can find the value for 

`<connection-name>`

 in the output of 

`nmcli connection`

