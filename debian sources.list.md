## Обновление списка репозиториев
1. Cохраним sources.list
`cp /etc/apt/sources.list ~/sources.list`

2. Обновляем файл с репозиториями _/etc/apt/sources.list_, изменив релиз с bullseye на bookworm
```
echo -e "deb https://deb.debian.org/debian bookworm main" | sudo tee /etc/apt/sources.list.
echo -e "deb-src https://deb.debian.org/debian bookworm main" | sudo tee -a /etc/apt/sources.list
```
```
echo -e "deb https://deb.debian.org/debian bookworm-updates main" | sudo tee -a /etc/apt/sources.list
echo -e "deb-src https://deb.debian.org/debian bookworm-updates main" | sudo tee -a /etc/apt/sources.list

```
```
echo -e "deb http://security.debian.org/ bookworm-security main" | sudo tee -a /etc/apt/sources.list
echo -e "deb-src http://security.debian.org/ bookworm-security main" | sudo tee -a /etc/apt/sources.list
```
 Если вы использовали прошивки (firmware) из репозитория non-free, подключите репозиторий non-free-firmware для их обновления.
```
echo -e "deb https://deb.debian.org/debian bookworm main non-free-firmware" | sudo tee -a /etc/apt/sources.list
```
- Команда `| sudo tee /etc/apt/sources.list` : 
	1. Символ `|` используется для передачи вывода предыдущей команды в следующую команду. 
	2. `tee` - это утилита командной строки, которая считывает из стандартного ввода и записывает в стандартный вывод и одновременно в файлы. Здесь мы используем `tee` с `sudo`, чтобы получить права суперпользователя и записать вывод в файл `/etc/apt/sources.list`.

3. проверить список репозиториев
`cat /etc/apt/sources.list`

4. Выполняем обновление списка пакетов из нового репозитория:
`apt update`

```
echo -e "deb https://deb.debian.org/debian bookworm main" | sudo tee /etc/apt/sources.list.d/debian.list
echo -e "deb-src https://deb.debian.org/debian bookworm main" | sudo tee -a /etc/apt/sources.list.d/debian.list
```
```
echo -e "deb https://deb.debian.org/debian bookworm-updates main" | sudo tee -a /etc/apt/sources.list.d/debian.list
echo -e "deb-src https://deb.debian.org/debian bookworm-updates main" | sudo tee -a /etc/apt/sources.list.d/debian.list

```
```
echo -e "deb http://security.debian.org/ bookworm-security main" | sudo tee -a /etc/apt/sources.list.d/debian.list
echo -e "deb-src http://security.debian.org/ bookworm-security main" | sudo tee -a /etc/apt/sources.list.d/debian.list
```

```
 apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 
```
- добавить ключи

```
cp /etc/apt/trusted.gpg /etc/apt/trusted.gpg.d
```