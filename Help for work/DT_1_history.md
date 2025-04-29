[ksb@ksb-dt ~]$ history 
    1  sudo dnf update
    2  ping 8.8.8.8
    3  cat /etc/resolv.conf 
    4  nano /etc/resolv.conf 
    5  sudo nano /etc/resolv.conf 
    6  sudo dnf update
    7  sudo dnf upgrade
    8  sudo dnf install fail2ban
    9  sudo dnf install epel-release -y
   10  sudo dnf install fail2ban
   11  hostname
   12  ip a | grep ens
   13  sudo nano /etc/fail2ban/jail.local
   14  sudo systemctl restart fail2ban.service 
   15  sudo systemctl enable fail2ban.service 
   16  sudo nano /etc/ssh/sshd_config
   17  sudo systemctl restart sshd
   18  logout
   19  reboot
   20  sudo reboot
   21  ip a | grep ens
   22  cat /etc/os-release 
   23  logout
   24  sudo dnf check-update
   25  sudo dnf install fail2ban
   26  ls -l /etc/fail2ban/
   27  cat /etc/fail2ban/jail.local
   28  ss -tulpn
   29  sudo ss -tulpn
   30  sudo systemctl status avahi-daemon
   31  sudo systemctl stop avahi-daemon
   35  sudo ss -tulpn
   39  sudo hostnamectl set-hostname ksb-dt
   40  exit
   41  docker -v
   42  sudo docker -v
   43  sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo       
   44  sudo dnf install docker-ce docker-ce-cli containerd.io
   45  sudo systecmtl status docker
   77  sudo systemctl start docker
   49  sudo systemctl enable docker
   50  docker -v
   51  docker ps
   52  sudo docker ps
   53  ip a
   54  sudo dnf install nginx
   55  ls -l
   56  cat /etc/*-release
   57  sudo mkdir -p docker/dt
   58  cd docker/dt/
   59  ls -l
   60  sudo nano docker-compose.yml
   61  htop
   62  sudo dnf install htop
   63  htop
   64  ls -l
   65  sudo docker compose up -d
   66  sudo docker compose logs -f
   67  ls -l
   68  sudo docker compose logs -f
   69  sudo nano /etc/nginx/conf.d/dt.conf
   70  sudo nginx -t
   71  ip a
   72  ls -l
   73  ls -l /etc/ssl
   74  cd
   75  ls -l
   76  sudo cp dt.ksb.local.pem /etc/ssl/certs/
   77  ls -l /etc/ssl/certs/
   78  mkdir /etc/ssl/private/
   79  sudo mkdir /etc/ssl/private/
   80  sudo cp dt.ksb.local.key /etc/ssl/private/
   81  sudo chmod -R 600 /etc/ssl/private/
   82  sudo chown -R root: /etc/ssl/private/
   83  ls -l
   84  rm dt.ksb.local.key
   85  rm dt.ksb.local.pem
   86  ls -l
   87  sudo nginx -t
   88  sudo nano /etc/nginx/conf.d/dt.conf
   89  sudo nginx -t
   90  sudo systemctl restart nginx
   91  sudo journalctl -xeu nginx.service
   92  sudo semanage port -l
   93  sudo semanage port -l | grep http
   94  sudo semanage port -a -t http_port_t -p tcp 9443
   95  sudo semanage port -l | grep http
   96  sudo systemctl restart nginx
   97  sudo systemctl status nginx
   98  sudo systemctl enable nginx
   99  ip a
  100  sudo systemctl stop firewalld
  101  sudo systemctl start firewalld
  102  sudo firewall-cmd --zone=public --permanent --add-service=https
  103  sudo firewall-cmd --zone=public --permanent --help
  104  sudo firewall-cmd --zone=public --permanent -h
  105  sudo firewall-cmd --help
  106  sudo firewall-cmd --zone=public --permanent --list-all
  107  sudo firewall-cmd --zone=public --permanent --add-port=9443
  108  sudo firewall-cmd --zone=public --permanent --add-port=9443/tcp
  109  sudo firewall-cmd --zone=public --permanent --add-port=8443/tcp
  110  sudo firewall-cmd --zone=public --permanent --list-all
  111  sudo firewall-cmd --get-default-zone
  112  sudo firewall-cmd --zone=public --permanent --list-all
  113  ss -4lnt
  114  sudo firewall-cmd --zone=public --permanent --add-service=http
  115  sudo firewall-cmd --reload
  116  sudo audit2why < /var/log/audit/audit.log
  117  setenforce 0
  118  sudo setenforce 0
  119  getenforce
  120  sudo setenforce 1
  121  ls -l /vat/log/
  122  sudo ls -l /vat/log/
  123  sudo ls -l /var/log/
  124  sudo ls -l /var/log/audit/
  125  sudo audit2why < /var/log/audit/audit.log
  126  sudo echo -e "audit2why < /var/log/audit/audit.log"
  127  sudo bash -c "audit2why < /var/log/audit/audit.log"
  128  sudo setsebool -P httpd_can_network_connect 1
  129  getenforce
  130  sudo nano /etc/systemd/system/nftables-rules.service
  131  sudo systemctl daemon-reload
  132  sudo systemctl start nftables-rules.service
  133  sudo journalctl -xeu nftables-rules.service
  134  sudo nft list ruleset
  135  sudo systemctl start nftables-rules.service
  136  sudo systemctl status nftables-rules.service
  137  ip a
  138  sudo nano /etc/systemd/system/nftables-rules.service
  139  sudo systemctl start nftables-rules.service
  140  sudo systemctl daemon-reload
  141  sudo systemctl start nftables-rules.service
  142  sudo nano /etc/systemd/system/nftables-rules.service
  143  sudo systemctl daemon-reload
  144  sudo systemctl start nftables-rules.service
  145  cat /etc/nginx/conf.d/
  146  cat /etc/nginx/conf.d/dt.conf
  147  cd docker/dt/
  148  sudo docker compose logs -f
  149  sudo docker compose down -v
  150  sudo docker system prune -a
  151  ls -l
  152  sudo rm -rf data/
  153  sudo rm -rf postgresql/
  154  sudo rm -rf postgresql_data/
  155  ls -l
  156  sudo docker images
  157  sudo docker compose up -d
  158  ls -l /etc/nginx/
  159  ls -l /etc/nginx/conf.d/
  160  ls -l /etc/nginx/default.d/
  161  ls -l /etc/nginx/nginx.conf
  162  sudo nano /etc/nginx/nginx.conf
  163  sudo systemctl restart nginx
  164  sudo docker compose ps
  165  sudo docker compose logs -f
  166  ls -l data/
  167  history
  168  sudo bash -c "audit2why < /var/log/audit/audit.log"
  169  ls -la data/
  170  ls -l
  171  sudo chown -R ksbadmin: data
  172  ls -la
  173  sudo docker compose down
  174  sudo docker compose up -d
  175  sudo docker compose logs -f
  176  sudo docker compose down -v
  177  sudo docker system prune -a
  178  sudo rm -rf data/
  179  sudo rm -rf postgresql/
  180  sudo rm -rf postgresql_data/
  181  sudo docker compose up -d
  182  sudo docker compose logs -f
  183  sudo docker compose down -v
  184  sudo rm -rf postgresql/
  185  sudo rm -rf postgresql_data/
  186  sudo rm -rf data/
  187  ls -l
  188  mkdir -p data/.dependency-track
  189  sudo mkdir -p data/.dependency-track
  190  ls -l
  191  sudo chown -R ksbadmin: data/
  192  ls -l
  193  sudo docker compose up -d
  194  sudo docker compose logs -f
  195  ls -la data/
  196  ls -la data/.dependency-track/
  197  cat docker-compose.yml
  198  ss -4lnt
  199  ss -tulp
  200  sudo docker compose ps
  201  sudo docker compose logs -f
  202  sudo nano /etc/nginx/conf.d/dt.conf
  203  cat /etc/nginx/conf.d/dt.conf
  204  cd
  205  sudo cp ksb-dt.ksb.local.pem /etc/ssl/certs/
  206  sudo cp ksb-dt.ksb.local.key /etc/ssl/private/
  207  sudo chown root: /etc/ssl/private/ksb-dt.ksb.local.key
  208  sudo chmod 600 /etc/ssl/private/ksb-dt.ksb.local.key
  209  ls -l
  210  rm ksb-dt.ksb.local.key
  211  rm ksb-dt.ksb.local.pem
  212  ls -l
  213  sudo systemctl restart nginx
  214  ping 172.17.0.41
  215  ls -l
  216  cd docker/
  217  ls -l
  218  cd dt/
  219  ls -l
  220  sudo nano docker-compose.yml
  221  sudo docker compose down
  222  sudo docker compose up -d
  223  ls -l
  224  ss -4lnt
  225  telnet 172.17.0.41 8443
  226  curl -h
  227  curl https://172.17.0.41:8443
  228  exit
  229  ls -l
  230  ls -l docker/dt/
  231  cat docker/dt/docker-compose.yml
  232  s -4lnt
  233  ss -4lnt
  234  ls -l /etc/nginx/conf.d/
  235  ls -l /etc/nginx/conf.d/dt.conf
  236  cat /etc/nginx/conf.d/dt.conf
  237  ls -l /etc/systemd/system/nftables-rules.service
  238  cat /etc/systemd/system/nftables-rules.service
  239  semanage port list
  240  semanage port -l
  241  sudo semanage port -l
  242  sudo semanage port -l | grep http
  243  sudo bash -c "audit2why < /var/log/audit/audit.log"
  244  sudo firewall-cmd --zone=public --permanent --list
  245  sudo firewall-cmd --zone=public --permanent --list-all
  246  cd docker/dt/
  247  ls- l
  248  ls -l
  249  sudo docker compose lofs -f
  250  sudo docker compose logs -f
  251  getenforce
  252  setenforce 0
  253  sudo setenforce 0
  254  getenforce
  255  sudo setenforce 1
  256  exit
  257  ls /home/ksbadmin/
  258  ls /home/ksbadmin/docker/
  259  ls /home/ksbadmin/docker/dt/
  260  ls /etc/nginx/
  261  cat /etc/nginx/nginx.conf
  262  cat /etc/nginx/conf.d/dt.conf
  263  logout
  264  ls -l
  265  ls -l /home
  266  ls -l /home/ksbadmin
  267  ls -l /home/ksbadmin/docker/
  268  ls -la /home/ksbadmin/docker/
  269  ls -la /home/ksbadmin/docker/dt/
  270  cat /home/ksbadmin/docker/dt/docker-compose.yml
  271  logout
  272  sudo systemctl stop nftables-rules.service
  273  ip a | grep ens
  274  logout
  275  exit
  276  pwd
  277  cd ..
  278  pwd
  279  usermod -l ksb ksbadmin
  280  su -
  281  ls -l
  282  cd /home/
  283  ls -l
  284  mc
  285  cd ksbadmin/
  286  ls
  287  cd docker/
  288  ls -l
  289  cd dt/
  290  ls -l
  291  sudo docker compose down
  292  sudo nano docker-compose.yml
  293  sudo su
  294  exit
  295  cd /etc/ansible/playbooks/
  296  cat /etc/passwd
  297  cd /home/ksb/docker/dt/
  298  sudo docker compose up
  299  sudo docker compose down
  300  sudo docker compose up -d
  301  cd /
  302  cd ~
  303  pwd
  304  ls
  305  mkdir scripts
  306  mkdir bom_gen
  307  mkdir ansible
  308  ls -l
  309  cd /bom_gen
  310  ls -l
  311  cd bom_gen/
  312  ls
  313  python3 cpedict_exporter.py
  314  ls
  315  ls -la
  316  ls /etc/
  317  sudo dnf install ansible
  318  ls /etc/ansible/
  319  sudo mkdir /etc/ansible/hosts
  320  sudo mkdir /etc/ansible/hosts/
  321  sudo rm /etc/ansible/hosts
  322  sudo mkdir /etc/ansible/hosts
  323  sudo mkdir /etc/ansible/playbooks
  324  sudo dnf install mc
  325  sudo mc
        cd /etc/ansible/
        ansible-vault create vault.yml 
  326  sudo EDITOR=nano ansible-vault edit /etc/ansible/vault.yml
  327  cd /etc/ansible/
  328  ls
  329  sudo nano hosts/packages.yml
  330  sudo EDITOR=nano ansible-vault edit /etc/ansible/vault.yml
  331  cd /home/ksb/scripts/
  332  ls
  333  cat main_packages_exporter.sh
  334  sudo nano main_packages_exporter.sh
  335  cat main_packages_exporter.sh
  336  nano DT_os_packages_exporter.sh
  337  sudo bash main_packages_exporter.sh
  338  cd /etc/ansible/playbooks/
  339  ls
  340  cd /home/ksb/scripts/
  341  ls
  342  nano main_packages_exporter.sh
  343  mc
  344  sudo ansible-playbook -i /etc/ansible/hosts/packages.yml --vault-password-file /root/ansible_pass /etc/ansible/playbooks/packages.yml
  345  ssh ksb@10.38.22.93
  346  sudo ansible-playbook -i /etc/ansible/hosts/packages.yml --vault-password-file /root/ansible_pass /etc/ansible/playbooks/packages.yml
  347  ssh ksb@10.38.22.93
  348  cd /etc/ansible/
  349  sudo EDITOR=nano ansible-vault edit /etc/ansible/vault.yml
  350  sudo ansible-playbook -i /etc/ansible/hosts/packages.yml --vault-password-file /root/ansible_pass /etc/ansible/playbooks/packages.yml
  351  sudo nano /etc/ansible/hosts/packages.yml
  352  sudo nano ansible.cfg
  353  sudo ansible-playbook -i /etc/ansible/hosts/packages.yml --vault-password-file /root/ansible_pass /etc/ansible/playbooks/packages.yml
  354  cd ~/scripts/
  355  ls
  356  sudo bash main_packages_exporter.sh
  357  nano main_packages_exporter.sh
  358  ls /etc/ansible/playbooks/
  359  nano /etc/ansible/playbooks/packages.yml
  360  ls -l
  361  nano main_packages_exporter.sh
  362  ls /etc/ansible/hosts/
  363  nano /etc/ansible/hosts/packages.yml
  364  nano /etc/ansible/playbooks/packages.yml
  365  sudo bash main_packages_exporter.sh
  366  nano /etc/ansible/playbooks/packages.yml
  367  nano /etc/ansible/playbooks/packages.yml
  368  nano main_packages_exporter.sh
  369  sudo $PATH
  370  sudo /bin/bash
  371  sudo /bin/bash main_packages_exporter.sh
  372  reboot now
  373  sudo reboot now
  374  echo "$PATH"
  375  cd ~/scripts/
  376  ls -l
  377  sudo bash main_packages_exporter.sh
  378  history
  379  su -
  380  exit
  381  pwd
  382  cd ~/scripts/
  383  nano main_packages_exporter.sh
  384  bash main_packages_exporter.sh
  385  rm main_packages_exporter.sh
  386  nano main_packages_exporter.sh
  387  bash main_packages_exporter.sh
  388  sudo bash main_packages_exporter.sh
  389  nano main_packages_exporter.sh
  390  sudo bash main_packages_exporter.sh
  391  nano main_packages_exporter.sh
  392  nano DT_os_packages_exporter.sh
  393  sudo bash main_packages_exporter.sh
  394  ls
  395  rm DT_os_packages_exporter.sh
  396  nano DT_os_packages_exporter.sh
  397  sudo bash main_packages_exporter.sh
  398  ls -l
  399  nano DT_os_packages_exporter.sh
  400  ls -l
  401  sudo bash main_packages_exporter.sh
  402  ls -la
  403  pwd
  404  ls -la /home/ksb/bom_gen/
  405  sudo bash main_packages_exporter.sh
  406  pwd
  407  cd ../
  408  mc
  409  sudo mc
  410  cd ~/scripts/
  411  sudo bash main_packages_exporter.sh
  412  sudo crontab -l
  413  sudo crontab -e
  414  sudo crontab -l
  415  sudo mkdir /var/log/sca
  416  sudo touch /var/log/sca/cpe_exporter.log
  417  sudo touch /var/log/sca/main_packages_exporter.log
  418  sudo systemctl restart crond.service
  419  history
  420  cd ~/scripts/
  421  nano DT_os_packages_exporter.sh
  422  sudo EDITOR=nano ansible-vault edit /etc/ansible/vault.yml
  423  cd /etc/ansible/
  424  ls -l
  425  cd playbooks/
  426  ls -l
  427  cat packages.yml
  428  cd ..
  429  cat hosts/packages.yml
  430  cd hosts/
  431  sudo nano packages.yml
  432  cat hosts/packages.yml
  433  pwd
  434  sudo cat packages.yml
  435  sudo EDITOR=nano ansible-vault edit /etc/ansible/vault.yml
  436  sudo nano packages.yml
  437  sudo EDITOR=nano ansible-vault edit /etc/ansible/vault.yml
  438  sudo nano packages.yml
  439  history
  440  cd ~/scripts/
  441  sudo bash main_packages_exporter.sh
  442  cat /etc/ansible/hosts/packages.yml
  443  nano /etc/ansible/hosts/packages.yml
  444  sudo nano /etc/ansible/hosts/packages.yml
  445  sudo bash main_packages_exporter.sh
  446  sudo nano /etc/ansible/hosts/packages.yml
  447  sudo EDITOR=nano ansible-vault edit /etc/ansible/vault.yml
  448  psw
  449  pwd
  450  ls
  451  sudo basj DT_os_packages_exporter.sh
  452  sudo bash DT_os_packages_exporter.sh
  453  sudo bash main_packages_exporter.sh
  454  sudo EDITOR=nano ansible-vault edit /etc/ansible/vault.yml
  455  sudo nano /etc/ansible/hosts/packages.yml
  456  sudo bash main_packages_exporter.sh
  457  sudo restart
  458  cd ../
  459  pwd
  460  restart now
  461  sudo restart now
  462  restart
  463  sudo reboot
  464  sudo bash main_packages_exporter.sh
  465  cd ~/scripts/
  466  sudo bash main_packages_exporter.sh
  467  history
  468  sudo ansible-playbook -i /etc/ansible/hosts/packages.yml --vault-password-file /root/ansible_pass /etc/ansible/playbooks/packages.yml
  469  sudo nano /etc/ansible/hosts/packages.yml
  470  sudo bash main_packages_exporter.sh
  471  sudo nano /etc/ansible/hosts/packages.yml
  472  sudo cat /etc/ansible/hosts/packages.yml
  473  cd /etc/ansible/hosts/
  474  pfw
  475  pwd
  476  ls
  477  rm packages.yml
  478  ls
  479  sudo rm packages.yml
  480  sudo nano packages.yml
  481  sudo bash ~/scripts/main_packages_exporter.sh
  482  sudo nano packages.yml
  483  ssh ksb@10.38.26.201
  484  ssh kali@10.38.22.101
  485  sudo bash ~/scripts/main_packages_exporter.sh
  486  cat /etc/*-release
  487  ls -l
  488  cat packages.yml
  489  cd ~/docker/dt
  490  ls -l
  491  nano docker-compose.yml
  492  sudo mc
  493  more docker-compose.yml
  494  ls -l
  495  cat /etc/fail2ban/jail.local
  496  cat /etc/ssh/sshd_config
  497  sudo cat /etc/ssh/sshd_config
  498  sudo nano /etc/ssh/sshd_config
  499  sudo systectl restart ssh
  500  sudo systemctl restart ssh
  501  sudo ls -ls /etc/ssh/
  502  sudo ls -la /etc/ssh/
  503  sudo /etc/ssh/ssh restart
  504  sudo systemctl restart sshd
  505  hostname
  506  ss -tulpn
  507  pwd
  508  ls -l
  509  more docker-compose.yml
  510  sudo more /etc/nginx/conf.d/dt.conf
  511  sudo more /etc/systemd/system/nftables-rules.service
  512  sudo nft list ruleset
  513  sudo nano /etc/systemd/system/nftables-rules.service
  514  ls -l /etc/nginx/conf.d/
  515  ls -l /etc/nginx/default.d/
  516  ls -l /etc/nginx/nginx.conf
  517  cd ~/docker/
  518  ls -l
  519  mc
  520  exit
  521  ls
  522  cd scripts/
  523  ls
  524  sudo bash main_packages_exporter.sh
  525  sudo mc
  526  history





  sudo crontab -e


00 1 * * 1 bash /home/ksb/scripts/cpe_exporter.sh >> /var/log/sca/cpe_exporter.log 2>&1
20 2 * * 1 bash /home/ksb/scripts/main_packages_exporter.sh >> /var/log/sca/main_packages_exporter.log 2>&1



