sudo mkdir -p /srv/repo/alse/base  
[ -d /media/cdrom ] || sudo mkdir /media/cdrom  
sudo mount /путь_к_ISO-образу /media/cdrom  
sudo cp -a /media/cdrom/* /srv/repo/alse/base  
sudo umount /media/cdrom

etc/ap/sorces/list

deb file:/srv/repo/alse/base  x....