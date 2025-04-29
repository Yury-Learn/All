---
tags:
  - users
  - bash
  - linux
---
- Чтобы удалить пользователя, не удаляя пользовательские файлы и каталоги, выполните:
```sh
sudo deluser username
```

-  Если необходимо удалить домашний каталог пользователя и его содержимое, используйте флаг --remove-home:
```sh
sudo deluser --remove-home username
```

В результате появится следующее сообщение:
>Looking for files to backup/remove ...