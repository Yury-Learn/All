# При попытке ручной репликации данных между контроллерами домена Active Directory в остатке Active Directory Sites and Services (dssite.msc) появилась ошибка.
- При проверке репликации с помощью repadmin, у одного из DC появляется ошибка: (2148074274) The target principal name is incorrect.

1) Остановите службу Kerberos Key Distribution Center (KDC) на контроллере домена, на котором появляется ошибка “The target principal name is incorrect” и измените тип запуска на Disabled. Можно изменить настройки службы из консоли services.msc или с помощью PowerShell:

	Get-Service kdc -ComputerName msk-dc03 | Set-Service –startuptype disabled –passthru
2) Перезагрузите этот контроллер домена.
3) netdom resetpwd /server:<Название домена> /userd:<имя уз> /passwordd:*
	netdom resetpwd /server:ksb-dc1 /userd:ksb\svetlov.an /passwordd:* (указать надо админа доменя)
4) Перезагрузите проблемный DC и запустите службу KDC. Попробуйте запустить репликацию и проверить ошибки.

5) Ввести команды по очереди: 
	repadmin /syncall
	repadmin /replsum
	repadmin /showrepl