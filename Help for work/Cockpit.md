### Red Hat Enterprise Linux

Cockpit is available in Red Hat Enterprise Linux 7 and later.

1. On RHEL 7, enable the _Extras_ repository.
    
    ```
    sudo subscription-manager repos --enable rhel-7-server-extras-rpms
    ```
    
    RHEL 8 does not need any non-default repositories.
    
2. Install cockpit:
    
    ```
    sudo yum install cockpit
    ```
    
3. Enable cockpit:
    
    ```
    sudo systemctl enable --now cockpit.socket
    ```
    
4. On RHEL 7, or if you use non-default zones on RHEL 8, open the firewall:
    
    ```
    sudo firewall-cmd --add-service=cockpit
    sudo firewall-cmd --add-service=cockpit --permanent
    ```
    
### CentOS

Cockpit is available in CentOS 7 and later:

1. Install cockpit:
    
    ```
    sudo yum install cockpit
    ```
    
2. Enable cockpit:
    
    ```
    sudo systemctl enable --now cockpit.socket
    ```
    
3. Open the firewall if necessary:
    
    ```
    sudo firewall-cmd --permanent --zone=public --add-service=cockpit
    sudo firewall-cmd --reload
    ```
    

### Debian

Cockpit is available in Debian since version 10 (Buster).

1. To get the latest version, we recommend to enable the [backports repository](https://backports.debian.org/) (as root):
    
    ```
    . /etc/os-release
    echo "deb http://deb.debian.org/debian ${VERSION_CODENAME}-backports main" > \
        /etc/apt/sources.list.d/backports.list
    apt update
    ```
    
2. Install or update the package:
    
    ```
    apt install -t ${VERSION_CODENAME}-backports cockpit
    ```
    

When updating Cockpit-related packages and any dependencies, make sure to use `-t ...-backports` as above, so backports are included.

### Ubuntu

```
. /etc/os-release
sudo apt install -t ${VERSION_CODENAME}-backports cockpit
```