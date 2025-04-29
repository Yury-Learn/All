## Updating Nextcloud to the latest version

#### 1.  Что следует учитывать: 

![:warning:](https://github.githubassets.com/images/icons/emoji/unicode/26a0.png ":warning:") В случае потери или повреждения данных я бы рекомендовал всегда регулярно создавать резервные копии и делать новую резервную копию перед каждым обновлением.**

[The Nextcloud documentation](https://docs.nextcloud.com/server/latest/admin_manual/maintenance/upgrade.html) В документации Nextcloud перечислены два важных правила при обновлении Nextcloud:

1. Прежде чем вы сможете перейти на следующую основную версию, Nextcloud обновится до последней дополнительной версии и исправления.**
    
2. Вы не можете пропустить основные выпуски. Всегда увеличивайте основную версию только на один шаг за раз.
    

#### 2. Теоретический пример процедуры обновления:

Учитывая эти два правила, позвольте мне кратко описать путь обновления, если бы мы начали с установки Nextcloud `23.0.9` с помощью Docker Compose:

1.  Текущая установка `23.0.9`. `23.0.9`
    
2.  [Docker Hub](https://hub.docker.com/_/nextcloud/tags).Первый шаг — всегда обновляться до последней второстепенной версии и исправления текущей основной версии. Вы можете проверить наличие последней доступной дополнительной версии или исправления Nextcloud в Docker Hub.  
    обновиться до последней минорной версии/патча`23.0.11`
    
3. Теперь, когда у нас есть обновление до последней второстепенной версии и исправление, мы можем обновить нашу версию до следующей основной версии. Имейте в виду, что основные выпуски нельзя пропускать. Мы должны увеличивать основную версию только на один шаг за раз. Однако вы можете сразу перейти к последней минорной и исправленной версии.  
    перейти на следующую специальность`24.0.7`
    
4. Теперь вы можете неоднократно увеличивать основную версию, пока не достигнете последней версии Nextcloud:  
    перейти на следующую специальность`25.0.1`
    

#### 3. Пример процедуры обновления на практике:

1. Предположим, мы начали с версии Nextcloud `23.0.9`, и `docker-compose.yml` выглядит примерно так:
    
    ```
    ---
    version: "3"
    services:
      nextcloud:
        image: "nextcloud:23.0.9-apache"
    
        ...
    ```
    
2. Остановим контейнеры  
    
    ```
    docker-compose down
    ```
    
3. Обновите образ Nextcloud Docker до `23.0.11`, последней дополнительной версии и исправления текущей основной версии. Пока не увеличивайте основную версию!
    
    ```
    ---
    version: "3"
    services:
      nextcloud:
        image: "nextcloud:23.0.11-apache"
    
        ...
    ```
    
4. Теперь вы можете запустить Nextcloud. Nextcloud автоматически установит все необходимые обновления. Во время обновления веб-интерфейс Nextcloud автоматически отключается. Вы можете проверить, успешно ли завершилось обновление, войдя в веб-интерфейс Nextcloud по адресу localhost:8080. Кроме того, вы также можете просмотреть записи журнала, чтобы отслеживать ход обновления:
    
    ```
    docker-compose up -d
    
    docker-compose logs -f
    # nextcloud_1  | Initializing nextcloud 23.0.11.1 ...
    # nextcloud_1  | Upgrading nextcloud from 23.0.9.1 ...
    # ...
    # #### And a few moments later ####
    # ...
    # #### The following line indicates that the Nextcloud web server has started ####
    # nextcloud_1  | [Sun Nov 13 17:36:38.725816 2022] [core:notice] [pid 1] AH00094: Command line: 'apache2 -D FOREGROUND'
    ```
    
5. Снова остановим контейнер
    
    ```
    docker-compose down
    ```
    
6. ![:warning:](https://github.githubassets.com/images/icons/emoji/unicode/26a0.png ":warning:") Теперь мы можем обновить версию Nextcloud до следующей основной версии `24.0.7`. мы можем мгновенно обновиться до последней минорной и исправленной версии. Никогда не пропускайте важные релизы. Увеличивайте основную версию только по одному шагу за раз.
    
    ```
    ---
    version: "3"
    services:
      nextcloud:
        image: "nextcloud:24.0.7-apache"
    
        ...
    ```
    
7. Запустите Nextcloud. Опять же, в журналах должно быть указано, что Nextcloud обнаружил старую версию и применил обновление:
    
    ```
    docker-compose up -d
    
    docker-compose logs -f
    # nextcloud_1  | Initializing nextcloud 24.0.7.1 ...
    # nextcloud_1  | Upgrading nextcloud from 23.0.11.1 ...
    # ...
    # #### And a few moments later ####
    # ...
    # #### The following line indicates that the Nextcloud web server has started ####
    # nextcloud_1  | [Sun Nov 13 17:44:05.397079 2022] [core:notice] [pid 1] AH00094: Command line: 'apache2 -D FOREGROUND'
    ```
    
8. Завершите работу еще раз, измените образ Docker на последнюю основную версию и, наконец, перезапустите:
    
    ```
    docker-compose down
    ```
    
    ```
    ---
    version: "3"
    services:
      nextcloud:
        image: "nextcloud:25.0.1-apache"
    
        ...
    ```
    
    ```
    docker-compose up -d
    ```
    

Поздравляем, теперь у вас должна быть установлена ​​последняя версия Nextcloud.![:tada:](https://github.githubassets.com/images/icons/emoji/unicode/1f389.png ":tada:")

---

Обновление MariaDB до последней минорной или исправленной версии.

![:warning:](https://github.githubassets.com/images/icons/emoji/unicode/26a0.png ":warning:") Перед обновлением MariaDB обязательно сделайте резервные копии!!!**

Если Nextcloud несовместим с вашей текущей версией MariaDB, нет необходимости обновлять оба образа Docker одновременно. Вместо этого вы можете сначала обновить Nextcloud до последней основной, дополнительной версии и версии исправления, а затем выполнить обновление MariaDB.

Обновление до последней минорной или исправленной версии тривиально. Просто замените тег образа Docker в `docker-compose.yml` последней доступной версией. Пример `docker-compose.yml` со старой версией MariaDB `10.4.8-bionic`:

```
---
version: "3"
services:
  mariadb:
    image: "mariadb:10.4.8-bionic"

    ...
```

`docker-compose.yml` обновлен последней версией MariaDB `10.9.4-jammy` от ноября 2022 г. (последнюю доступную версию можно найти в Docker Hub):

```
---
version: "3"
services:
  mariadb:
    image: "mariadb:10.9.4-jammy"

    ...
```

Затем просто перезапустите Nextcloud и MariaDB, используя `docker-compose down`, а затем `docker-compose up -d`.

После обновления операторы журнала могут содержать ошибки из MariaDB из-за неправильных схем базы данных или проблем совместимости. Примеры журналов:

```
mariadb_1    | 2022-11-13 17:53:06 13 [ERROR] Incorrect definition of table mysql.column_stats: expected column 'histogram' at position 10 to have type longblob, found type varbinary(255).
mariadb_1    | 2022-11-13 17:53:06 13 [ERROR] Incorrect definition of table mysql.column_stats: expected column 'hist_type' at position 9 to have type enum('SINGLE_PREC_HB','DOUBLE_PREC_HB','JSON_HB'), found type enum('SINGLE_PREC_HB','DOUBLE_PREC_HB').
```

Luckily, MariaDB ships with the utility program `mariadb-upgrade` to identify and fix these compatibility issues:

1. Prerequisite: the MariaDB Docker container must be running.
    
2. Establish an interactive shell session for the MariaDB container:
    
    ```
    docker-compose exec mariadb bash
    ```
    
3. Inside the MariaDB Docker container, run the following command. It should prompt for your MariaDB’s root password:
    
    ```
    mariadb-upgrade --user=root --password
    # Enter password:
    # Phase 1/7: Checking and upgrading mysql database
    # Processing databases
    # mysql
    # mysql.column_stats                                 OK
    #
    # ...
    #
    # nextcloud.oc_webauthn                              OK
    # nextcloud.oc_whats_new                             OK
    # sys
    # sys.sys_config                                     OK
    # Phase 7/7: Running 'FLUSH PRIVILEGES'
    # OK
    ```
    

Congrats, you’ve successfully updated MariaDB. Your logs should contain no more error statements. For a more in-depth documentation on how to upgrade MariaDB please refer to the [official MariaDB documentation](https://mariadb.com/docs//all/service-management/upgrades/community-server/release-series-cs10-5).