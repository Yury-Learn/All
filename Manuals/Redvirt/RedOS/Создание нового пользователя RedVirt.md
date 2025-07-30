#redvirt 

по ssh на eng.gisno.redvirt
```sh
ovirt-aaa-jdbc-tool user add test1 --attribute=firstName=Ivan  
--attribute=lastName=Ivanov 
```

> [!ВЫВОД]
> updating user test1...  
> user updated successfully


### Установка пароля пользователя
```
ovirt-aaa-jdbc-tool user password-reset test1 --password-validto="2025-08-01 12:00:00-0800" 
```

> [!ВЫВОД]
> Password:  
> updating user test1...  
> user updated successfully

Администратор может задать пароль пользователя. Однако следует помнить, что  
необходимо установить значение для --password-valid-to, в противном случае время  
истечения срока действия пароля по умолчанию равно текущему времени. Формат  
даты устанавливается в виде ГГГГ-MM-ДД ЧЧ:ММ:ССX.

### Просмотр информации о пользователе
```
ovirt-aaa-jdbc-tool user show test1
```

```
ovirt-aaa-jdbc-tool user edit test1 --attribute=email=ivanovi@  
example.com
```

