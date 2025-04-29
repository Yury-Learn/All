# Для создания сертификата нужно использовать автоскрипт запуска
  На выбор есть 3 скрипта:
    autorequest.sh        
    autosslcrt.sh          
    autosslpem.sh 

    Заходим по пути, где лежат скрипты
    1)cd /etc/ssl/ca/
    2)./autorequest.sh
    3)sudo chmod -R 777 /etc/ssl/ca/*
    4)WinSCP (проще копировать)



1. Код скрипта autorequest.sh 

#!/bin/bash

### Запрос ввода hostname
read -p "Введите hostname: " hostname

### Создание директории в /etc/ssl/ca/hostname
mkdir -p "/etc/ssl/ca/$hostname"

### Запрос ввода -----begin certificate request-----
echo "Введите -----begin certificate request----- (введите '-----END CERTIFICATE REQUEST-----' в новой строке, чтобы закончить ввод):"
cert_request=""
while IFS= read -r line; do
    cert_request+="$line\n"
    if [[ $line == "-----END CERTIFICATE REQUEST-----" ]]; then
        break
    fi
done

### Создание файла hostname.csr в директории /etc/ssl/ca/hostname
echo -e "$cert_request" > "/etc/ssl/ca/$hostname/$hostname.csr"

### Создание файла hostname.cnf
echo "
[ req ]
default_bits = 2048
distinguished_name = req_distinguished_name
req_extensions = req_ext
[ req_distinguished_name ]
countryName = Country Name (2 letter code)
countryName_default = RU
stateOrProvinceName = State or Province Name (full name)
stateOrProvinceName_default = Chuvashia
localityName = Locality Name (eg, city)
localityName_default = Cheboksary
organizationName = Organization Name (eg, company)
organizationName_default = KSB-SOFT
commonName = Common Name (eg, YOUR name or FQDN)
commonName_max = 64
commonName_default = $hostname
[ req_ext ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = DNS:$hostname" > "/etc/ssl/ca/$hostname/$hostname.cnf"

### Генерация приватного ключа
openssl genpkey -algorithm RSA -out "/etc/ssl/ca/$hostname/$hostname.key"

### Создание сертификата
openssl x509 -req -days 730 -CA /etc/ssl/ca/rootCA.crt -CAkey /etc/ssl/ca/rootCA.key -passin pass:334424334424 -extfile "/etc/ssl/ca/$hostname/$hostname.cnf" -extensions req_ext -in "/etc/ssl/ca/$hostname/$hostname.csr" -out "/etc/ssl/ca/$hostname/$hostname.pem"

### Вывод содержимого сертификата
more "/etc/ssl/ca/$hostname/$hostname.pem"



2. Код скрипта autosslcrt.sh


#!/bin/bash

### Запрос ввода hostname
read -p "Введите hostname: " hostname

### Создание директории в /etc/ssl/ca/hostname
mkdir -p "/etc/ssl/ca/$hostname"

### Создание файла hostname.cnf
echo "
[ req ]
default_bits = 2048
distinguished_name = req_distinguished_name
req_extensions = req_ext
[ req_distinguished_name ]
countryName = Country Name (2 letter code)
countryName_default = RU
stateOrProvinceName = State or Province Name (full name)
stateOrProvinceName_default = Chuvashia
localityName = Locality Name (eg, city)
localityName_default = Cheboksary
organizationName = Organization Name (eg, company)
organizationName_default = KSB-SOFT
commonName = Common Name (eg, YOUR name or FQDN)
commonName_max = 64
commonName_default = $hostname
[ req_ext ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = DNS:$hostname" > "/etc/ssl/ca/$hostname/$hostname.cnf"

### Генерация приватного ключа
openssl genpkey -algorithm RSA -out "/etc/ssl/ca/$hostname/$hostname.key"

### Создание файла hostname.csr в директории /etc/ssl/ca/hostname
openssl req -new -key "/etc/ssl/ca/$hostname/$hostname.key" -config "/etc/ssl/ca/$hostname/$hostname.cnf" -reqexts req_ext -out "/etc/ssl/ca/$hostname/$hostname.csr"

### Создание сертификата
openssl x509 -req -days 730 -CA /etc/ssl/ca/rootCA.crt -CAkey /etc/ssl/ca/rootCA.key -passin pass:334424334424 -extfile "/etc/ssl/ca/$hostname/$hostname.cnf" -extensions req_ext -in "/etc/ssl/ca/$hostname/$hostname.csr" -out "/etc/ssl/ca/$hostname/$hostname.crt"


3. Код скрипта autosslpem.sh



#!/bin/bash

### Запрос ввода hostname
read -p "Введите hostname: " hostname

### Создание директории в /etc/ssl/ca/hostname
mkdir -p "/etc/ssl/ca/$hostname"

### Создание файла hostname.cnf
echo "
[ req ]
default_bits = 2048
distinguished_name = req_distinguished_name
req_extensions = req_ext
[ req_distinguished_name ]
countryName = Country Name (2 letter code)
countryName_default = RU
stateOrProvinceName = State or Province Name (full name)
stateOrProvinceName_default = Chuvashia
localityName = Locality Name (eg, city)
localityName_default = Cheboksary
organizationName = Organization Name (eg, company)
organizationName_default = KSB-SOFT
commonName = Common Name (eg, YOUR name or FQDN)
commonName_max = 64
commonName_default = $hostname
[ req_ext ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = DNS:$hostname" > "/etc/ssl/ca/$hostname/$hostname.cnf"

### Генерация приватного ключа
openssl genpkey -algorithm RSA -out "/etc/ssl/ca/$hostname/$hostname.key"

### Создание файла hostname.csr в директории /etc/ssl/ca/hostname
openssl req -new -key "/etc/ssl/ca/$hostname/$hostname.key" -config "/etc/ssl/ca/$hostname/$hostname.cnf" -reqexts req_ext -out "/etc/ssl/ca/$hostname/$hostname.csr"

### Создание сертификата
openssl x509 -req -days 730 -CA /etc/ssl/ca/rootCA.crt -CAkey /etc/ssl/ca/rootCA.key -passin pass:334424334424 -extfile "/etc/ssl/ca/$hostname/$hostname.cnf" -extensions req_ext -in "/etc/ssl/ca/$hostname/$hostname.csr" -out "/etc/ssl/ca/$hostname/$hostname.pem"