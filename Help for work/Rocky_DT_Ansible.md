ANSIBLE
playbook - задачи
vault - логины с паролями
hosts - объекты 

/home/etc/ 
Создаем папки 
- ansible
- scripts
- vault

Создаем sudo ansible-vault create vault.yml








/etc/ansimble/packages.yml создаем под SUDO.


---

all:
  children:
    debian_servers:
      hosts:
        mail:
          ansible_host: 172.17.0.4
          ansible_user: "{{user_4}}"
          ansible_ssh_pass: "{{pass_4}}"
          ansible_become_pass: "{{pass_4}}"
      vars:
        ansible_connection: ssh
        ansible_become: yes
        ansible_become_method: sudo
    centos_servers:
      hosts:
        gitlab:
          ansible_host: 172.17.0.5
          ansible_user: "{{user_5}}"
          ansible_port: 2222
          ansible_ssh_pass: "{{pass_5}}"
          ansible_become_pass: "{{pass_5}}"
        dev:
          ansible_host: 172.17.0.6
          ansible_user: "{{user_6}}"
          ansible_ssh_pass: "{{pass_6}}"
          ansible_become_pass: "{{pass_6}}"
      vars:
        ansible_connection: ssh
        ansible_become: yes
        ansible_become_method: sudo
      children:
        localhost:
          hosts:
            sca:
              ansible_host: 127.0.0.1
              ansible_become_pass: "{{pass_41}}"
              ansible_connection: local
              ansible_become: yes
              ansible_become_method: sudo






GNU nano 5.6.1                                              main_packages_exporter.sh                                             
Изменён  #!/bin/bash

ansible-playbook -i /etc/ansible/hosts/packages.yml --vault-password-file /root/ansible_pass /etc/ansible/playbooks/packages.yml
cd /home/ksb/scripts
bash DT_os_packages_exporter.sh 