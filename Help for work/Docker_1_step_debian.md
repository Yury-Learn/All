#docker 
# Установка Docker в Ubuntu. 
1. Обязательно надо обновить до актуального состояния ситсему:
	`sudo apt update && sudo apt upgrade`

2. Установка доп пакета ядра, который позволит использовать Aufs для контейнеров Docker. С помощью этой файловой системы мы сможем следить за изменениями и делать мгновенные снимки контейнеров:
	`sudo apt install linux-modules-extra-$(uname -r) linux-image-extra-virtual`

3. Ещё надо установить пакеты, необходимые для работы apt по https:
	`sudo apt install apt-transport-https ca-certificates curl software-properties-common`

4. Устанавливаем программу из официального репозитория разработчиков. Сначала надо добавить ключ репозитория:
	`curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -`

5. Затем добавьте репозиторий docker в систему:
	`sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"`

	`sudo apt update && apt-cache policy docker-ce`

6. Установка Docker на Ubuntu:
	`sudo apt install -y docker-ce`

7. Добавляем пользователя в группу docker. (Если этого не сделать, то будет ошибка при запуске)
	 `sudo usermod -aG docker $(whoami)`

8. Проверяем запущен ли сервис:
	 `sudo systemctl status docker`



systemctl docker down
systemctl docker up -d