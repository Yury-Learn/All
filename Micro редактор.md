#linux #editor
## 1. Установка. Тут всё просто. Micro есть в базовых репозиториях дистрибутивов, так что можно сделать так:

```sh
apt install micro
```

Я хотел получить самую свежую версию, поэтому сделал вот так:

```sh
curl https://getmic.ro | bash
```
```sh
mv micro /usr/bin/micro
```

По сути это просто одиночный бинарник на Go. Можно скачать из репозитория (https://github.com/zyedidia/micro).

## 2. Делаем micro редактором по умолчанию:

```sh
update-alternatives --install /usr/bin/editor editor /usr/bin/micro 50
```
```sh
update-alternatives --set editor /usr/bin/micro
```

### MC
Для того, чтобы в Midnight Commander (mc) он тоже выступал в качестве редактора, надо добавить в ~/.bashrc пару переменных:

export EDITOR=micro
export VISUAL=micro

И перечитать файл:

```sh
 source ~/.bashrc
```