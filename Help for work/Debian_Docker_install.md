### Что такое Docker
Docker – это программа, благодаря которой можно упростить процесс разработки и управления (например, тестирования и размещения) приложений с помощью виртуальных блоков — контейнеров. Контейнеризация программ лежит в основе работы Docker.

Каждый виртуальный блок можно масштабировать, развернуть или переместить из одной среды в другую (например, из персонального компьютера в дата-центр и наоборот). При этом не придётся изменять или дорабатывать код. Контейнеризация позволяет выделить инфраструктуру приложения и работать с ней как с отдельной сущностью.

Для создания контейнера достаточно запустить шаблонный элемент — образ docker. Это можно сделать из публичного репозитория Docker Hub. В момент запуска срабатывает разметка файловой системы, создаётся сетевой интерфейс и назначается IP-адрес. После этого контейнер активирован и готов к работе.

####Преимущества установки Docker:

работает не только на Linux, но и на Windows и MacOS,
позволяет запускать проекты на виртуальном web-сервере,
на одном хосте можно параллельно запускать около тысячи контейнеров.

### Как установить Docker в Debian
Руководство по настройке Docker на Debian:

1. Обновите пакеты: 
sudo apt update

2. Установите пакеты, которые необходимы для работы пакетного менеджера apt по протоколу HTTPS: 
sudo apt install apt-transport-https ca-certificates curl software-properties-common

3. Добавьте GPG-ключ репозитория Docker: 
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

4. Добавьте репозиторий Docker: 
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb\_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

5. Снова обновите пакеты: 
sudo apt update

6. Переключитесь в репозиторий Docker, чтобы его установить: 
apt-cache policy docker-ce

7. Установите Docker: 
sudo apt install docker-ce

8. Проверьте работоспособность программы: 
sudo systemctl status docker

9. Чтобы использовать утилиту docker, нужно добавить ваше имя пользователя в группу Docker. Для этого введите в терминале команду: 
sudo usermod -aG docker ${user}              (reboot обязательно)
(Где user — имя пользователя.)

10. Введите: 
su - ${user}

11. Когда терминал запросит пароль, введите пароль пользователя.

Готово, вы установили Docker в Дебиан. Теперь вы можете использовать утилиту.

## Установка Docker Engine - Debian

### Add Docker's official GPG key:
1. sudo apt-get update
2. sudo apt-get install ca-certificates curl
3. sudo install -m 0755 -d /etc/apt/keyrings
4. sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
5. sudo chmod a+r /etc/apt/keyrings/docker.asc

### Add the repository to Apt sources:
6. echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
7. sudo apt-get update


## Установка Docker Compose plugin
1. sudo apt-get update
2. sudo apt-get install docker-compose-plugin

Проверка версии 

3. Docker Compose Version