Покажу на примере настройки сертификата в Nginx.

Будем выпускать сертификат для доменного имени zabbix.internal и IP адреса 172.30.245.222. Будет работать и так, и эдак. 

Выпускаем ключ и сертификат для своего CA:

```bash
 mkdir ~/tls && cd ~/tls
 openssl ecparam -out myCA.key -name prime256v1 -genkey
 openssl req -x509 -new -nodes -key myCA.key -sha256 -days 9999 -out myCA.crt
```

Вам зададут серию вопросов. Отвечать можно всё, что угодно. В данном случае это не важно. Выпускаем ключ и сертификат для сервера:

```bash
openssl genrsa -out zabbix.internal.key 2048
openssl req -new -key zabbix.internal.key -out zabbix.internal.csr
```

Тут тоже зададут похожие вопросы. Отвечать можно всё, что угодно. Готовим конфигурационный файл:

`mcedit zabbix.internal.ext`

>authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

>alt_names
IP.1 = 172.30.245.222
DNS.1 = zabbix.internal

Генерируем сертификат на его основе:

```bash
openssl x509 -req -in zabbix.internal.csr -CA myCA.crt -CAkey myCA.key \
-CAcreateserial -out zabbix.internal.crt -days 9999 -sha256 -extfile zabbix.internal.ext
```

Копируем сертификат и ключ в директорию веб сервера:

```bash
mkdir /etc/nginx/certs
cp zabbix.internal.crt /etc/nginx/certs/.
cp zabbix.internal.key /etc/nginx/certs/.
```

Создаём файл dhparam, который понадобится для конфигурации Nginx:
```openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048```


Добавляем в конфиг Nginx в целевом виртуальном хосте:

> listen     443 http2 ssl;
> server_name   zabbix.internal 172.30.245.222;
> ssl_certificate /etc/nginx/certs/zabbix.internal.crt;
> ssl_certificate_key /etc/nginx/certs/zabbix.internal.key;
> ssl_dhparam /etc/ssl/certs/dhparam.pem;

Перезапускаем Nginx:
```bash
nginx -t
nginx -s reload
```
Передаём на свой компьютер файл myCA.crt и добавляем его в хранилище корневых доверенных центров сертификации. Настройка будет зависеть от операционной системы. Если нужно тут же, локально на сервере с Debian 12 настроить доверие этому CA, то делаем так:
```bash
cp myCA.crt /usr/local/share/ca-certificates/.
update-ca-certificates
```
Теперь можно браузером заходить по доменному имени или IP адресу, будет работать самоподписанный сертификат на 9999 дней без каких-либо предупреждений.

Получилась готовая инструкция для копипаста, которую можно сохранить и пользоваться.
