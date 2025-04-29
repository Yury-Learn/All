#linux #files #bash 
### Основы

#### 1. **setfacl** и **getfacl** 
- используются для настройки ACL и отображения ACL соответственно.

#### 2. **Команды для настройки ACL:**

- Чтобы добавить разрешение для пользователя:
```sh
setfacl -m u:user:permissions /path/to/file
```
**permissions --- rwx -wx**    
- Чтобы добавить разрешение для группы: 
```sh
setfacl -m g:group:permissions /path/to/file
```
   
- Чтобы разрешить всем файлам или каталогам наследовать записи ACL из каталога, в котором они находятся: 
```sh
setfacl -dm "entry" /path/to/dir
```
   
- Чтобы удалить конкретную запись: 
```sh
setfacl -x "entry" /path/to/file
```
   
- Чтобы удалить все записи: 
```sh
setfacl -b path/to/file
```

### Пример. 

Изменить разрешения для файла `test.txt`, принадлежащего пользователю liza и группе docs, так, чтобы:
- пользователь ivan имел права на чтение и запись в этот файл;
- пользователь misha не имел никаких прав на этот файл.

#### 1. Исходные данные
```sh
$ ls -l test.txt
```
	:$_
	-rw-r-r-- 1 liza docs 8 янв 22 15:54 test.txt

```sh
getfacl test.txt
```
	:$_
	file: test.txt
	owner: liza
	group: docs
	user::rw-
	group::r--
	other::r--

#### 2. Установить разрешения (от пользователя liza):
```sh
setfacl -m u:ivan:rw- test.txt
setfacl -m u:misha:--- test.txt
```

#### 3. Просмотреть разрешения (от пользователя liza):
```sh
getfacl test.txt
```
	:$_
	file: test.txt
	owner: liza
	group: docs
	user::rw-
	user:ivan:rw-
	user:misha:---
	group::r--
	mask::rw-
	other::r--

- **Примечание**

Символ «+» (плюс) после прав доступа в выводе команды `ls -l` указывает на использование ACL:
```sh
ls -l test.txt
```
	:$_
	-rw-rw-r--+ 1 liza docs 8 янв 22 15:54 test.txt