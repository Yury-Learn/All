### Не правильный формат файлов docker-compose-ce.yaml
Первый вариант с Volumes внутри, второй вариант вытаскиваем наружу для удоства переноса.
Создаем docker-compose.yml или переносим свой файл в /opt/docker
Бывает ошибка с обращением к Volumes (в доступе отказано - permission denied), которые снаружу. Нужно упасть внутрь папки Volume. Посмотреть права и выдать такие же права сверху в созданном каталоге. (Наш пример: gpg,jwt,db)
1. Запускаем с стандартным конфигом. 
2. Заходим внутрь контейнера sudo docker compose exec -it ID /bin/bash
3. Смотрим права на директорию ls -l /etc/passbolt/ 
4. смотрим права drwxrwx--- 
5. sudo chmod 770 jwt_volume/  выдаем права
6. sudo chown  ksb:ksb jwt_volume/ выдаем права на пользователя
7. тушим docker compose down -v
8. меняем docker-compose.yml 
9. запускаем docker compose up -d


version: "3.9"
services:
  db:
    image: mariadb:10.11
    restart: unless-stopped
    environment:
      MYSQL_RANDOM_ROOT_PASSWORD: "true"
      MYSQL_DATABASE: "msqpassbolt"
      MYSQL_USER: "userpassbolt"
      MYSQL_PASSWORD: "az2pNLqEoUeLFgW"
    volumes:
      - database_volume:/var/lib/mysql

  passbolt:
    image: passbolt/passbolt:latest-ce
    # Alternatively you can use rootless:
    # image: passbolt/passbolt:latest-ce-non-root
    restart: unless-stopped
    depends_on:
      - db
    environment:
      APP_FULL_BASE_URL: https://pass.ksb.local
      DATASOURCES_DEFAULT_HOST: "db"
      DATASOURCES_DEFAULT_USERNAME: "userpassbolt"
      DATASOURCES_DEFAULT_PASSWORD: "az2pNLqEoUeLFgW"
      DATASOURCES_DEFAULT_DATABASE: "msqpassbolt"
    volumes:
      - gpg_volume:/etc/passbolt/gpg
      - jwt_volume:/etc/passbolt/jwt
      - ./cert/pass.ksb.local.crt:/etc/ssl/certs/certificate.crt:ro
      - ./cert/pass.ksb.local.key:/etc/ssl/certs/certificate.key:ro
    command:
      [
        "/usr/bin/wait-for.sh",
        "-t",
        "0",
        "db:3306",
        "--",
        "/docker-entrypoint.sh",
      ]
    ports:
      - 80:80
      - 443:443
    # Alternatively for non-root images:
    # - 80:8080
    # - 443:4433

volumes:
  database_volume: (во втором варианте убрать)
  gpg_volume: (во втором варианте убрать)
  jwt_volume: (во втором варианте убрать)



  ### Правильно должно быть так.

version: "3.9"
services:
  db:
    image: mariadb:10.11
    restart: unless-stopped
    environment:
      MYSQL_RANDOM_ROOT_PASSWORD: "true"
      MYSQL_DATABASE: "msqpassbolt"
      MYSQL_USER: "userpassbolt"
      MYSQL_PASSWORD: "az2pNLqEoUeLFgW"
    volumes:
      - .db:/var/lib/mysql

  passbolt:
    # image: passbolt/passbolt:latest-ce
    # Alternatively you can use rootless:
    image: passbolt/passbolt:latest-ce-non-root
    restart: unless-stopped
    depends_on:
      - db (volume выдернули наружу)
    environment:
      APP_FULL_BASE_URL: https://pass.ksb.local
      DATASOURCES_DEFAULT_HOST: "db"
      DATASOURCES_DEFAULT_USERNAME: "userpassbolt"
      DATASOURCES_DEFAULT_PASSWORD: "az2pNLqEoUeLFgW"
      DATASOURCES_DEFAULT_DATABASE: "msqpassbolt"
    volumes:
      - .gpg:/etc/passbolt/gpg (volume выдернули наружу)
      - .jwt:/etc/passbolt/jwt (volume выдернули наружу)
      - ./cert/pass.ksb.local.crt:/etc/ssl/certs/certificate.crt:ro
      - ./cert/pass.ksb.local.key:/etc/ssl/certs/certificate.key:ro
    command:
      [
        "/usr/bin/wait-for.sh",
        "-t",
        "0",
        "db:3306",
        "--",
        "/docker-entrypoint.sh",
      ]
    ports:
      - 80:80
      - 443:443
    # Alternatively for non-root images:
    # - 80:8080
    # - 443:4433



    P.S: Меняем MariaDB на PostgreSQL, т.к. её еще кто-то может помочь починить. 



1. cat docker-compose-ce-SHA512SUM.txt 
2. 1d4e2eb93e6b7ffb0edfa464d56c8e1eb07d4eaeae3865ee5707f9a17d5c0aaf18f39977eea3b3ce86be93c8d626acfdd479c1898831dae032ab00d269092359  docker-compose-ce.yaml


1. Для запуска docker compose нестандартного файла, используем команду 
sudo docker compose -f docker-compose-ce.yaml up -d
2. Для остановки docker compose нестандартного файла, используем команду 
sudo docker compose -f docker-compose-ce.yaml down

### Команда для установки PassBolt not Root (add user)
- docker compose exec passbolt ./bin/cake passbolt register_user -u svetlov.an@ksb-soft.ru -f Aleksey -l Svetlov -r admin

### Docker-Compose.yml (Без root)


version: "3.7"
services:
  db:
    image: postgres:latest
    restart: unless-stopped
    environment:
      POSTGRES_DB: "passbolt"
      POSTGRES_USER: "passboltsecurity"
      POSTGRES_PASSWORD: "P4ssb0ltSec123@"
    volumes:
      - ./database_volume:/var/lib/postgresql/data

  passbolt:
    # image: passbolt/passbolt:latest
    # Alternatively you can use rootless:
    image: passbolt/passbolt:latest-ce-non-root
    restart: unless-stopped
    tty: true
    depends_on:
      - db
    environment:
      APP_FULL_BASE_URL: https://pass.ksb.local
      DATASOURCES_DEFAULT_DRIVER: Cake\Database\Driver\Postgres
      DATASOURCES_DEFAULT_ENCODING: "utf8"
      DATASOURCES_DEFAULT_URL: "postgres://passboltsecurity:P4ssb0ltSec123@@db:5432/passbolt?schema=passbolt"
      EMAIL_TRANSPORT_DEFAULT_HOST: "smtp.domain.tld"
      EMAIL_TRANSPORT_DEFAULT_PORT: 587
    volumes:
      - ./gpg_volume:/etc/passbolt/gpg
      - ./jwt_volume:/etc/passbolt/jwt
      - ./cert/pass.ksb.local.crt:/etc/ssl/certs/certificate.crt:ro
      - ./cert/pass.ksb.local.key:/etc/ssl/certs/certificate.key:ro
      # - ./cert.pem:/etc/passbolt/certs/certificate.crt:ro
      # -  ./key.pem:/etc/passbolt/certs/certificate.key:ro
    command: >
      bash -c "/usr/bin/wait-for.sh -t 0 db:5432 -- /docker-entrypoint.sh"
    ports:
     # - 80:80
     # - 443:443
    # Alternatively for non-root images:
      - 80:8080
      - 443:4433

 -# volumes:
 -# database_volume:
 -# gpg_volume:
 -# jwt_volume:




### Команда для создания первого администратора

docker compose exec passbolt ./bin/cake passbolt register_user \
-u svetlov.an@ksb-soft.ru\
-f Aleksey \
-l Svetlov \
-r admin