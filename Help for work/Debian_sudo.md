1. Заходим под root (переключаемся su -)
2. apt install sudo (устанавливаем, если нет)
3. nano /etc/sudoers (смотрим содержимое)
4. В файле находим строку %sudo ALL=(ALL:ALL) ALL
	При её наличии добавляем пользователя в группу sudo
5. usermod -aG sudo name_user
6. Так же можем добавить в файле
	name_user ALL=(ALL:ALL) ALL
7. Выходим (Ctrl + X); Соглашаемся с сохранением (Yes). 