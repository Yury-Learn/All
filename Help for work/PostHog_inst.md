- Обязательно подготовить сервер на Rocky Linux

Инструкции по установке PostHog Docker Compose
После установки предварительных условий выполните следующую команду для загрузки исходных файлов:

git clone https://github.com/PostHog/posthog
После этого выполните следующую команду для настройки базы данных:

docker-compose -f docker-compose.dev.yml up -d redis db
Затем перейдите в клонированный каталог, создайте и активируйте виртуальную среду:

cd postho gpython3 -m venv envsource env/bin/activate

- После этого выполните следующие команды для установки зависимостей:

pip install -r requirements.txt --break-system-packages
pip install -r requirements-dev.txt --break-system-packages

- В конце запустите приложение с помощью следующих команд:

DEBUG=1 python3 manage.py migrateDEBUG=1 ./bin/start

- Наконец, получите доступ к приложению в браузере по следующей ссылке.

http://localhost:8000