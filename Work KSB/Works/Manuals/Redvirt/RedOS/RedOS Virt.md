#redvirt


User
1. 
```
 ovirt-aaa-jdbc-tool user add testuser --attribute=firstName=Test  --attribute=lastName=User
```
создать новую учетную запись пользователя
2. 
```
ovirt-aaa-jdbc-tool user password-reset test1 --password-valid-to="2035-08-01 12:00:00-0800"
```
задать пароль пользователя. Однако следует помнить, что  
необходимо установить значение для --password-valid-to, в противном случае время  
истечения срока действия пароля по умолчанию равно текущему времени. Формат  
даты устанавливается в виде ГГГГ-MM-ДД ЧЧ:ММ:ССX.
 3. 
```
ovirt-aaa-jdbc-tool user show testuser
```
посмотреть подробную информацию об учетной записи
 4.	
```
ovirt-aaa-jdbc-tool user edit testuser --attribute=email=ivanovi@example.com
```
обновить информацию о пользователе, например адрес  электронной почты
5.  
```
ovirt-aaa-jdbc-tool user delete testuser
```
удалить учетную запись пользователя
6.
```
 ovirt-aaa-jdbc-tool user edit admin --flag=+disabled
```
Отключите администратора по умолчанию командой:

```
ovirt-aaa-jdbc-tool user edit <имя_пользователя> --flag=-disabled
```
включить отключенного пользователя, выполните команду
7. 
ovirt-aaa-jdbc-tool group add group1

novadmin
Novgorod53_ad
	- ClusterAdmin

1cgisno
Novgorod53_1c
	- UserVmManager
	- DiskOperator
	- DiskCreator
	- VnicProfileUser