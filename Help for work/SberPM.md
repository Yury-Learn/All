---
tags: sberpm, license, docker
---
ansible-playbook -i inventories/local tasks.yml -e "@../config.yml" -e  "cert_renew=yes"
ansible-playbook -i inventories/local deploy.yml -e "@../config.yml"

![[Pasted image 20240403095826.png]]