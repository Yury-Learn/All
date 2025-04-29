# Ansible очень чувствителен к "ПРОБЕЛАМ".

Для того, что бы работало шифрование для файла Vault.yml 

1. cd /etc/ansible/
2. ansible-vault create vault.yml 
3. sudo EDITOR=nano ansible-vault edit /etc/ansible/vault.yml
4. su - (root)
5. nano /root/ansible_pass (записываем сюда ключ) (права доступа -rw--------)
6. exit
7. sudo EDITOR=nano ansible-vault edit /etc/ansible/vault.yml (вызываем для проверка работоспособности ключа)



- api key >> web_dt >> Administration >> Teams >> Create Team >> Your_name
- Permissions: 
	ACESS_MANAGEMENT
	BOM_UPLOAD
	PROJECT_CREATION_UPLOAD

	copy api keys (example): odt_F60tBjNf7ltDKUDB8NxmOBB4L3ao2RJt 



###	open file DT_os_packages_exporter.sh


	  curl -X "POST" "${API_URL}" \
       -H 'Content-Type: multipart/form-data' \
       -H 'X-Api-Key: odt_F60tBjNf7ltDKUDB8NxmOBB4L3ao2RJt' \   *Меняем на свой*
       -F "autoCreate=true" \
       -F "projectName=${HOST}" \
       -F "bom=@${SBOM}"
  echo -e " - ${GREEN}SBOM uploaded to DT${NC}"
  cd "$SRC_DIR"



### Файлы в /home/user/scripts/
	- cpe_exporter.sh
	- DT_os_packages_exporter.sh
	- main_packages_exporter.sh

### Файлы в /home/user/bom_gen/
	- bom_gen.py
	- bom_gen.py.bak
	- cpe_dict_full
	- cpedict_exporter.py
	- official-cpe-dictionary_v2.3.xml

### папки в /etc/ansible/ + файлы
	- hosts
	- playbooks
	- roles 
	- ansible.cfg
	- vault.yml


### файл для рашифровки vault.yml 
    /root/ansible_pass


