### Требования системы:

dependency track - сервер разметки уязвимостей. 
роки 9
4 ядра
16гб оперативы
100гб памяти

------------------------- Конфиг docker-compose.yml -------------------------------

### [ksbadmin@ksb-dt ~]$ cat /home/ksbadmin/docker/dt/docker-compose.yml 
version: '3.7'

services:
  apiserver:
    container_name: dtrack-apiserver
    image: dependencytrack/apiserver
    depends_on:
      - db
    environment:
      - ALPINE_DATABASE_MODE=external
      - ALPINE_DATABASE_URL=jdbc:postgresql://db:5432/dtrack
    #jdbc:postgresql://db:5432/dtrack
      - ALPINE_DATABASE_DRIVER=org.postgresql.Driver
    #  - ALPINE_DATABASE_DRIVER_PATH=/extlib/postgresql-42.2.5.jar
      - ALPINE_DATABASE_USERNAME=dtrack
      - ALPINE_DATABASE_PASSWORD=DTpg!2604#
    # - ALPINE_DATABASE_POOL_ENABLED=true
    # - ALPINE_DATABASE_POOL_MAX_SIZE=20
    # - ALPINE_DATABASE_POOL_MIN_IDLE=10
    # - ALPINE_DATABASE_POOL_IDLE_TIMEOUT=300000
    # - ALPINE_DATABASE_POOL_MAX_LIFETIME=600000
    #
    # Optional HTTP Proxy Settings
    # - ALPINE_HTTP_PROXY_ADDRESS=proxy.example.com
    # - ALPINE_HTTP_PROXY_PORT=8888
    # - ALPINE_HTTP_PROXY_USERNAME=
    # - ALPINE_HTTP_PROXY_PASSWORD=
    # - ALPINE_NO_PROXY=
    #
    networks:
      - dtrack
    deploy:
      resources:
        limits:
          memory: 12288m
        reservations:
          memory: 8192m
      restart_policy:
        condition: on-failure
    ports:
      - "127.0.0.1:8081:8080"
    volumes:
      - "./data:/data"
    restart: unless-stopped

  frontend:
    container_name: dtrack-frontend
    image: dependencytrack/frontend
    depends_on:
      - apiserver
    environment:
      # The base URL of the API server.
      # NOTE:
      #   * This URL must be reachable by the browsers of your users.
      #   * The frontend container itself does NOT communicate with the API server directly, it just serves static files.
      #   * When deploying to dedicated servers, please use the external IP or domain of the API server.
      - API_BASE_URL=https://10.38.22.59:8443
    networks:
      - dtrack
#    volumes:
#      - "dependency-frontend:/data:ro"
#      - "/var/lib/docker/volumes/dtrack_dependency-frontend/_data/default.conf:/etc/nginx/conf.d/default.conf"
    ports:
      - "127.0.0.1:8080:8080"
    restart: unless-stopped

  db:
    container_name: dtrack-db
    image: postgres:10
    restart: unless-stopped
    environment:
      - POSTGRES_USER=dtrack
      - POSTGRES_PASSWORD=DTpg!2604#
      - POSTGRES_DB=dtrack
    networks:
      - dtrack
    volumes:
      - ./postgresql:/var/lib/postgresql
      - ./postgresql_data:/var/lib/postgresql/data

networks:
  dtrack:

#volumes:
#  dependency-frontend:




### Если проблемы с SELinux и nginx

setsebool -P httpd_can_network_connect 1

или ( не тестил, может тоже сработает)

setsebool -P httpd_can_network_relay 1

### nginx and ssl

https://www.digitalocean.com/community/tutorials/how-to-create-a-self-signed-ssl-certificate-for-nginx-in-ubuntu-20-04-1

### Приколы с firewall

sudo firewall-cmd --zone=public --permanent --add-service=https

часть команд: https://www.digitalocean.com/community/tutorials/how-to-create-a-self-signed-ssl-certificate-for-nginx-in-ubuntu-20-04-1

semanage port -a -t http_port_t -p tcp 9443


## Команда для отключения SELinux
setenforce 0 - выключение политик SELinux
setenforce 1 - включение политики SELinux


## Надо смотреть правила Firewalld
  systemctl daemon-reload
  Рестрат firewalld



### Nging Config

[ksbadmin@ksb-dt ~]$ cat /etc/nginx/conf.d/dt.conf 
server {
    listen 9443 ssl;
    server_name ksb-dt.ksb.local;
    ssl_certificate /etc/ssl/certs/ksb-dt.ksb.local.pem;
    ssl_certificate_key /etc/ssl/private/ksb-dt.ksb.local.key;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 1440m;
    ssl_session_tickets off;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers off;
    ssl_ciphers "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384";

    access_log /var/log/nginx/dt.access.log;
    error_log /var/log/nginx/dt.error.log;

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header   Host $host;
        proxy_set_header   X-Real-IP $remote_addr;
        proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Host $server_name;

        client_max_body_size        100m;
        proxy_connect_timeout       300;
        proxy_send_timeout          300;
        proxy_read_timeout          300;

        send_timeout                300;
    }
}

server {
    listen 8443 ssl;
    server_name ksb-dt.ksb.local;
    ssl_certificate /etc/ssl/certs/ksb-dt.ksb.local.pem;
    ssl_certificate_key /etc/ssl/private/ksb-dt.ksb.local.key;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 1440m;
    ssl_session_tickets off;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers off;
    ssl_ciphers "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384";

    access_log /var/log/nginx/dt-api.access.log;
    error_log /var/log/nginx/dt-api.error.log;

    location / {
        proxy_pass http://127.0.0.1:8081;
        proxy_set_header   Host $host;
        proxy_set_header   X-Real-IP $remote_addr;
        proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Host $server_name;

        client_max_body_size        100m;
        proxy_connect_timeout       300;
        proxy_send_timeout          300;
        proxy_read_timeout          300;

        send_timeout                300;
    }
}
