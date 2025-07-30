#network #linux 

```sh
ip route del default via 1.2.3.4 dev eth0 proto static metric 100
ip route add default via 1.2.3.4 dev eth0 proto static metric 90

```
You should now be able to see the result using the following command :

```sh
ip route
```