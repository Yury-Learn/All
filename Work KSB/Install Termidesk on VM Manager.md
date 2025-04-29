#vmmanager #termidesk

## Подготовка VMmanager

- Создайте учётную запись администратора для интеграции.
	1. Чтобы добавить учётную запись:
		1. Перейдите в раздел **Пользователи** →кнопка **Новый пользователь**.
		2. Если пользователя надо добавить в группы, выберите нужные **Группы**. 
		3. Выберите вариант добавления:
		    - **Приглашение пользователей**;
		    - **Создание пользователей**.
		4. Выберите для пользователя **Роль в системе**.
		    - **Пользователь**;
		    - **Продвинутый пользователь**;
		    - **Администратор**.
		5. Укажите **E-mail** пользователя. Этот адрес будет использоваться в качестве имени пользователя.
		6. Если вы выбрали вариант **Создание пользователей**, введите **Пароль** или нажмите **генерировать**. Созданный пароль вы можете **скопировать в буфер** обмена.
		7. Нажмите **Пригласить** (**Создать**).  
		    [![](https://www.ispsystem.ru/docs/static/25377634/image-2023-11-3012-20-25.png)](https://www.ispsystem.ru/docs/static/25377634/image-2023-11-3012-20-25.png)


1. Создайте ВМ, которая будет использоваться для создания VDI. Подробнее см. в статье [Создание виртуальных машин](https://www.ispsystem.ru/docs/vmmanager-admin/virtual-nye-mashiny/sozdanie-virtual-nyh-mashin).
2. Установите на ВМ агент Termidesk по инструкции из [официальной документации](https://wiki.astralinux.ru/termidesk-help/latest/dokumentatsiya/ekspluatatsionnaya-dokumentatsiya/agent/agent-ustanovka-i-udalenie/ustanovka-v-srede-os-astra-linux-special-edition-1-7/ustanovka-agenta-vrm).
3. В настройках ВМ разрешите подключения по протоколу SPICE. Подробнее см. в статье [SPICE](https://www.ispsystem.ru/docs/vmmanager-admin/vnutrennee-ustrojstvo/ispol-zuemye-podsistemy/spice).
4. Создайте образ на основе подготовленной ВМ. Подробнее см. в статье [Пользовательские образы виртуальных машин](https://www.ispsystem.ru/docs/vmmanager-admin/shablony/pol-zovatel-skie-obrazy-virtual-nyh-mashin).

## 