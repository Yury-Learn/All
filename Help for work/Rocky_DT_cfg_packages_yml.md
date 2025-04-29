---
all:
  children:
    debian_servers:
      hosts:
        ksb-ca:
          ansible_host: 10.38.22.93
          ansible_user: "{{user_2293}}"
          ansible_ssh_pass: "{{pass_2293}}"
          ansible_become_pass: "{{pass_2293}}"
        ksb-kms:
          ansible_host: 10.38.22.31
          ansible_user: "{{user_2231}}"
          ansible_ssh_pass: "{{pass_2231}}"
          ansible_become_pass: "{{pass_2231}}"
        ksb-mail:
          ansible_host: 10.38.22.3
          ansible_user: "{{user_223}}"
          ansible_ssh_pass: "{{pass_223}}"
          ansible_become_pass: "{{pass_223}}"
        ksb-redmine:
          ansible_host: 10.38.22.202
          ansible_user: "{{user_22202}}"
          ansible_port: 2222
          ansible_ssh_pass: "{{pass_22202}}"
          ansible_become_pass: "{{pass_22202}}"
        ksb-trueconf:
          ansible_host: 10.38.89.78
          ansible_user: "{{user_8978}}"
          ansible_ssh_pass: "{{pass_8978}}"
          ansible_become_pass: "{{pass_8978}}"
        kali1:
          ansible_host: 10.38.22.103
          ansible_user: "{{user_22103}}"
          ansible_ssh_pass: "{{pass_22103}}"
          ansible_become_pass: "{{pass_22103}}"
        kali2:
          ansible_host: 10.38.22.102
          ansible_user: "{{user_22102}}"
          ansible_ssh_pass: "{{pass_22102}}"
          ansible_become_pass: "{{pass_22102}}"
        kali3:
          ansible_host: 10.38.22.101
          ansible_user: "{{user_22101}}"
          ansible_ssh_pass: "{{pass_22101}}"
          ansible_become_pass: "{{pass_22101}}"
        kali4:
          ansible_host: 10.38.22.88
          ansible_user: "{{user_2288}}"
          ansible_ssh_pass: "{{pass_2288}}"
          ansible_become_pass: "{{pass_2288}}"
      vars:
        ansible_connection: ssh
        ansible_become: yes
        ansible_become_method: sudo
    centos_servers:
      hosts:
        student-postgres:
          ansible_host: 10.38.20.19
          ansible_user: "{{user_2019}}"
          ansible_ssh_pass: "{{pass_2019}}"
          ansible_become_pass: "{{pass_2019}}"
        marketing:
          ansible_host: 10.38.20.114
          ansible_user: "{{user_20114}}"
          ansible_ssh_pass: "{{pass_20114}}"
          ansible_become_pass: "{{pass_20114}}"
        ksb-xwiki:
          ansible_host: 10.38.22.203
          ansible_user: "{{user_22203}}"
          ansible_ssh_pass: "{{pass_22203}}"
          ansible_become_pass: "{{pass_22203}}"
        ksb-jira_confluence:
          ansible_host: 10.38.26.201
          ansible_user: "{{user_26201}}"
          ansible_ssh_pass: "{{pass_26201}}"
          ansible_become_pass: "{{pass_26201}}"
      vars:
        ansible_connection: ssh
        ansible_become: yes
        ansible_become_method: sudo
      children:
        localhost:
          hosts:
            ksb-dt:
              ansible_host: 127.0.0.1
              ansible_become_pass: "{{pass_2259}}"
              ansible_connection: local
              ansible_become: yes
              ansible_become_method: sudo