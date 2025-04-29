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
    ssl_ciphers "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA3
84:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES12
8-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384";

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
    ssl_ciphers "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA3
84:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES12
8-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384";

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