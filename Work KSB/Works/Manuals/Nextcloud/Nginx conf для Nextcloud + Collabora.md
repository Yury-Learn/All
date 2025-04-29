---
tags:
  - nginx
  - "#nextcloud"
"#nginx":
---
server {
	listen 80;
	listen 443 ssl;
	server_name nc.ksb-soft.ru;
	
        ssl_certificate_key /etc/nginx/ssl/nc.ksb-soft.ru.key;
	ssl_certificate /etc/nginx/ssl/nc.ksb-soft.ru.pem;

	location / {
        	proxy_pass http://localhost:8081;
        	proxy_set_header Host $host;
        	proxy_set_header X-Real-IP $remote_addr;
        	proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        	proxy_set_header X-Forwarded-Proto $scheme;
        	add_header Strict-Transport-Security "max-age=15552000; includeSubDomains" always;

	
            proxy_set_header   X-Forwarded-Host $server_name;
	        proxy_set_header   X-Forwarded-Proto https;

                client_max_body_size        100m;
                proxy_connect_timeout       3000;
                proxy_send_timeout          3000;
                proxy_read_timeout          3000;

                send_timeout                3000;
                proxy_max_temp_file_size 0;
	}
        	location ^~ /.well-known {
        	location = /.well-known/carddav { return 301 /remote.php/dav/; }
        	location = /.well-known/caldav  { return 301 /remote.php/dav/; }
        	location /.well-known/acme-challenge	{ try_files $uri $uri/ =404; }
        	location /.well-known/pki-validation	{ try_files $uri $uri/ =404; }
        	return 301 /index.php$request_uri;
	}
}

server {
    listen 443 ssl;
    server_name collabora.ksb.local;

    ssl_certificate  /etc/nginx/ssl/collabora.ksb.local.pem;
    ssl_certificate_key /etc/nginx/ssl/collabora.ksb.local.key.pem;

    location ^~ /loleaflet {
        proxy_pass https://10.38.89.51:9980;
        proxy_set_header Host $http_host;
    }

    # WOPI discovery URL
    location ^~ /hosting/discovery {
        proxy_pass https://10.38.89.51:9980;
        proxy_set_header Host $http_host;
    }

    # Capabilities
    location ^~ /hosting/capabilities {
        proxy_pass https://10.38.89.51:9980;
        proxy_set_header Host $http_host;
    }

    # main websocket
    location ~ ^/lool/(.*)/ws$ {
        proxy_pass https://10.38.89.51:9980;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "Upgrade";
        proxy_set_header Host $http_host;
        proxy_read_timeout 36000s;
    }

    # download, presentation and image upload
    location ~ ^/lool {
        proxy_pass https://10.38.89.51:9980;
        proxy_set_header Host $http_host;
    }

    # Admin Console websocket
    location ^~ /lool/adminws {
        proxy_pass https://10.38.89.51:9980;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "Upgrade";
        proxy_set_header Host $http_host;
        proxy_read_timeout 36000s;
    }
}