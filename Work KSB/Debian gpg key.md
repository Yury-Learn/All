#key #repo #debian 

Here is how I add GPG keys in my Debian 10 Buster.

### For regular repositories.
    # Debian 10.
    wget -O - https://ftp-master.debian.org/keys/archive-key-10.asc \
        | gpg --no-default-keyring --keyring /etc/apt/trusted.gpg --import
 
### For repositories with security updates.
    # Debian 10.
    wget -O - https://ftp-master.debian.org/keys/archive-key-10-security.asc \
        | gpg --no-default-keyring --keyring /etc/apt/trusted.gpg --import |

### list Repo

> #
> deb     http://deb.debian.org/debian buster main contrib non-free
> deb-src http://deb.debian.org/debian buster main contrib non-free
> #
> deb     http://deb.debian.org/debian buster-updates main contrib non-free
> deb-src http://deb.debian.org/debian buster-updates main contrib non-free
> #
> deb     http://security.debian.org/ buster/updates main contrib non-free
> deb-src http://security.debian.org/ buster/updates main contrib non-free
> #