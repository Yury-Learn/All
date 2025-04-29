### Стандартизация Операционных Систем


Базовая ос: Rocky linux

Тип установки: minimal install

Язык: en_US

Файловая система: xfs

Менеджер томов: LVM 

Разделы: корневой раздел на всю ОС, swap рассчитывается автоматически

Учетная запись пользователя: ksb

Пользователь может получить права sudo: да

Время: если есть доступ в интернет - использовать синхронизацию времени через интернет

firewall: включен

selinux: включен, если не мешает

Скрипт для автоматической установки приложений во вложении

bootstrap-rocky.sh

Умеет настраивать прокси, ставить докер, postgres, gitlab-runner, netdata, создавать пользователя и заносить его в sudo.Необходимо запускать от root.

Дополнительное установленное ПО:


 1. sudo dnf update && sudo dnf install epel-release -y

 2. sudo dnf install bash-completion mc htop nano wget curl traceroute strace ncdu net-tools bind-utils systemd-timesyncd.service -y
    Если нужен docker:


  3. sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
        4. sudo dnf install docker-ce docker-ce-cli docker-compose-plugin -y


5. sudo systemctl enable --now docker

! Не разрешать пользователю ksb работать с docker напрямую
    Если нужен gitlab-runner:


6. curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.rpm.sh" | sudo bash
        7. sudo dnf install gitlab-runner -y

    Если нужна netdata:


8. wget -O /tmp/netdata-kickstart.sh https://my-netdata.io/kickstart.sh && sh /tmp/netdata-kickstart.sh --disable-telemetry

 ! либо, если установлен docker - контейнером установить. но последний раз с этим конткретным контейнером были проблемы на этой ОС
        9. sudo systemctl enable --now netdata

       10. sudo firewall-cmd --permanent --add-port=19999/tcp && sudo firewall-cmd --reload

Если на машине необходимо держать несколько контейнеров с разным ПО - необходимо разместить директории с ПО по пути /opt/docker/




#### Script >>> bootstrap-rocky.sh (лежит на Яндекс диске, полезные вещи)