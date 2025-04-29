### Редирект с HTTP на HTTPS - пример найстроки.
	Стандартная страница веб скина для клиента Samoware расположена по следующему пути:
		/opt/CommuniGate/WebSkins/login.wssp

		Именно код этой страницы я буду править. Что нам нужно сделать:
		1. Определить – выполнил ли клиент безопасное подключение.
		2. Если подлкючение безопасное (HTTPS), то выполняет код страницы login.wssp.
		3. Если подключение не безопасное (HTTP), то нужно выполнить редирект с HTTP на HTTPS.
		Приступим. Общий шаблон выглядит следующим образом:

		<!--%%IF (REQUESTSECURE() == "YES") -->
		
		выполнить код со страницы login.wssp
		<!--%%ELSE -->
		<HTML>
		<HEAD>
		 <META HTTP-EQUIV=REFRESH CONTENT="0; url=https://com01.%%domainName%%/">
		 <TITLE>Redirecting to secure interface</TITLE>
		</HEAD>
		</HTML>
		<!--%%ENDIF-->



%%domainName%% – возвращает имя домена CommuniGate Pro – itproblog.ru в моем случае. Поэтому в начале мне пришлось дополнить URL значением “com01.”, т.к. в моем DNS сервер CommuniGate зарегистрирован как com01.itproblog.ru. Если у вас используется какой-то нестандартный порт, то необходимо это указать в url, на который выполняется редирект. Например, https://com01.%%domainName%%:9100/

Функция REQUESTSECURE() возвращает значение “YES”, если клиент выполнил безопасное подключение. В противном случае функция возвращает пустое значение.

Итого, что мы делаем:

1. Открываем файл /opt/CommuniGate/WebSkins/login.wssp на редактирование:
vim /opt/CommuniGate/WebSkins/login.wssp

2. В самое начала файла добавляем строчку:
<!--%%IF (REQUESTSECURE() == "YES") -->  
(дальше текст начинается с <DOCTYPE html> и т.д. <HTML>, <HEAD>...)

3. В самый конец файла добавляем оставшиеся строчки:

Ставим строки после (</html>)
<!--%%ELSE -->
<HTML>
<HEAD>
 <META HTTP-EQUIV=REFRESH CONTENT="0; url=https://com01.%%domainName%%/">
 <TITLE>Redirecting to secure interface</TITLE>
</HEAD>
</HTML>
<!--%%ENDIF-->


4. Сохраняем изменения.

5. Перезапускаем сервер CommuniGate:

	/etc/rc.d/init.d/CommuniGate stop
	/etc/rc.d/init.d/CommuniGate start

6. Проверяем. Заходим на http://com01.itproblog.ru/ должен быть переход на https://