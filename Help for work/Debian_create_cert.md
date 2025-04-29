#!/bin/bash

# Тут hostname прошу ввести
read -p "Введите hostname: " hostname

# Создаю директорию в /etc/ssl/ca/hostname
mkdir -p "/etc/ssl/ca/$hostname"

# Тут запрос ключик esxi15
echo "Введите -----begin certificate request----- (введите '-----END CERTIFICATE REQUEST-----' в новой строке, чтобы закончить ввод):"
cert_request=""
while IFS= read -r line; do
    cert_request+="$line\n"
    if [[ $line == "-----END CERTIFICATE REQUEST-----" ]]; then
        break
    fi
done

# Мне уже лень описывать
echo -e "$cert_request" > "/etc/ssl/ca/$hostname/$hostname.csr"

# Ну тут все понятно
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

# Генерация приватного ключа
openssl genpkey -algorithm RSA -out "/etc/ssl/ca/$hostname/$hostname.key"

# Создание сертификата
openssl x509 -req -days 730 -CA /etc/ssl/ca/rootCA.crt -CAkey /etc/ssl/ca/rootCA.key -passin pass:$$$ -extfile "/etc/ssl/ca/$hostname/$hostname.cnf" -extensions req_ext -in "/etc/ssl/ca/$hostname/$hostname.csr" -out "/etc/ssl/ca/$hostname/$hostname.pem"

# Вывожу сертификат дял копирования
more "/etc/ssl/ca/$hostname/$hostname.pem"