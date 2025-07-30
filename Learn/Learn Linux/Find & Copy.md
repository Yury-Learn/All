``` sh
find <where to search> -type f -user <name of usr> -exec cp --parents {} /destination \; 
```
- -type f - ищем файлы (f)
- -user <> - имя пользователя 
- -exec - выполнение команды с  полученным выводом `find`
- cp - именно комманда копирования
- --parents {} /(куда вставить) - добавить исходный путь к КАТАЛОГУ
