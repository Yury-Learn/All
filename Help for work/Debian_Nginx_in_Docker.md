# Установка и запуск Nginx в Docker-контейнере на Ubuntu.

	# Конфигурационные файлы Nginx
	Создаем основную директорию, в которой будут храниться папки и файлы конфигурации для отображения нашей web-страницы.

	1. mkdir -p serverspace
	2. cd serverspace

	Создадим несколько директорий и в них создадим файлы конфигурации для нашего тестового сайта, в котором запустим Nginx в Docker.

	1. mkdir -p project/conf-files
	2. mkdir -p html/files
	3. touch project/conf-files/serverspace.ru.conf
	4. touch project/nginx.conf
	5. touch html/files/serverspace.html

	Должны получить список следующего содержимого:

	1. tree serverspace/

	Перейдёс к их настройке. Внесём изменения в файле serverspace.ru.conf удобным для нас текстовым редактором.

	1. vim /serverspace/project/conf-files/serverspace.ru.conf (или nano)

	Запишем наш код:

	server {
	listen 80;
	server_name _;
	root /usr/share/nginx/html;
	index serverspace.html;
	location / {
	try_files $uri $uri/ =404;
	}
	}

	Перейдём к настройке файла nginx.conf и вставим наш код:

	user www-data;
	worker_processes auto;
	pid /run/nginx.pid;
	include /etc/nginx/modules-enabled/*.conf;
	events {
	worker_connections 768;
	}
	http {
	sendfile on;
	tcp_nopush on;
	types_hash_max_size 2048;
	default_type application/octet-stream;
	ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3; # Dropping SSLv3, ref: POODLE
	ssl_prefer_server_ciphers on;
	access_log /var/log/nginx/access.log;
	error_log /var/log/nginx/error.log;
	gzip on;
	include /etc/nginx/conf.d/*.conf;
	include /etc/nginx/sites-enabled/*;
	}


	В файле html/files/serverspace.html добавим код, в котором указываются заголовок сайта и одна строка с текстом:

	<h2 id="rt-3">Welcome to the Test-Site from Serverspace</h2>

	Перейдём к запуску Nginx в Docker-контейнере.

# Запуск контейнера.

	Запустим контейнер с помощью команды:

	docker run --name nginx-serverspace -p 80:80 -v /root/serverspace/html/files/:/usr/share/nginx/html/ -v /root/serverspace/project/nginx.conf:/etc/nginx/nginx.conf -v /root/serverspace/project/conf-files/:/etc/nginx/conf.d/ -d nginx

docker run – запускает контейнер;
–name nginx-serverspace – указывает название контейнера;
-p 80:80 – прослушиваемый порт;
-v /path/to/file – указывает путь откуда будет извлекаться файлы и передаваться в контейнер Nginx;
-d nginx – запускаемый образ в контейнере
После успешного запуска контейнера получим результат и проверим статус с помощью команды “docker ps”


Перейдём по IP адресу созданного сервера, где откроется web-страница с нашим заголовком. (192.168.1.195)
