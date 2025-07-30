#dpkg #apt

## How to fix “dpkg was interrupted, you must manually run sudo dpkg –configure -a to correct the problem” error.

```sh
sudo rm /var/lib/apt/lists/lock

sudo rm /var/cache/apt/archives/lock

cd /var/lib/dpkg/updates

sudo rm ***

sudo apt-get update

apt --fix-broken install
```


