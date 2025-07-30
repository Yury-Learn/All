логово
`git init` 
`git config --global user.name "Yury-Learn"`
`git config --global user.email rogal@inbox.ru`
 статус файлов
 `git status`
подготавливаем
`git add file1` 
размещаем
`git commit -m "Cool"`
размещаем с подготовкой
`git commit -am "Cool2"` 
`git log`
откатываемся на последний коммит
 `git restore` 
откатываем даже удаление
`git restore --staged file1` высвобождаем индекс
`git restore file1`

изменения с последнего коммита
 `git diff` 
переименовать или перемещать 
`git mv file1` сразу делает add
удалить
`git rm file`
`git rm --cached file1`

файл *.gitignore* описываем что игнорировать(не размещать в индекс)
	- папки
- > [!note] файлы с расширением docm docx 	*.doc [mx]
- docker-compose.yml
итд

.gitignore нужно добавить  в репо
`git add .gitignore`
`git commit -m "Add ignore"`

`git branch -a` ветки
`git branch new-api` создали ветку  *new-api*
`git checkout new-api` переключаемся на *new-api*
`git checkout 42342342(hash)` передвигаем HEAD
`git checkout -b dev` создать и передвинуться на ветку в конце можно передать hash


`git merge bug-fix` слияние с master
`git branch -d bug-fix` удаление ветки с которой слились, потому что не нужна

`git reset --hard hash`

### On-line
`git remote add origin https://` добавляем репо, origin принятый общий сервер

`git remote -v` info
`git push origin master` отправить изменения ветки **master**
`git clone https://` получить ветку
`git pull origin master`