## Почта внутри сети ходит с шифрованием
    - Порт 25 TLS/SSL version 1.2

# Создаем справочник. Тома. 
Поддерево: o=allusers,o=contacts
Имя LDAP сервера: ip adress or dns name (server)
Поддерево на Сервере: ou=my,dc=domain,dc=ru
Bind DN: my.domain.ru\service or service@my.domain.ru
Bind пароль: *****
Фильтр для поиска: (&(objectCategory=person)(mail=*)(objectClass=user)) - (*звездочка)

# Создаем динамическую группу. Пользователь. Домены. Создаем группу рассылки.

Настоящее Имя: Сотрудники
Фильтр для поисков: directory://o=allusers,o=contacts?mail?sub?(&(objectCategory=person)(mail=*@mydomain.ru)(objectClass=user)) (*звездочка)
P.S: Фильтр для поиска сортирует по справочнику.

# Скрипт для сервера AD, который должен быть.

<?xml version="1.0" encoding="utf-8" ?>
<configuration>
    <startup> 
        <supportedRuntime version="v4.0" sku=".NETFramework,Version=v4.5.2" />
    </startup>
  <appSettings>
    <add key="ADBaseDN" value="OU=my,DC=domain,DC=ru" /> 
    <add key="ADAddress" value="IP adress:389" />
    <add key="ADAccountNameAttribute" value="sAMAccountName" />
    <add key="ADGroupNameAttribute" value="sAMAccountName" />
    <add key="ADGroupRealNameAttribute" value="cn" />
    <add key="ADCGAccountStatus" value="employeetype" />
    <add key="ADCGSyncAllOnStart" value="true" />
    <add key="ADCGDefaultDomainName" value="domain.ru" />
    <add key="ADCGPostCreateScript" value="adsync-postcreate" />
    <add key="ADCGPostUpdateScript" value="adsync-postupdate" />
    <add key="ADCGGroupStatus" value="description" />
    <add key="ADObjectClass" value="organizationalPerson" />
    <add key="ADGroupObjectClass" value="group" />
    <add key="CGProAddress" value="mail.domain.ru" />
    <add key="CGProPort" value="106" />
    <add key="CGProSSL" value="false" />
    <add key="CGProSecureLogin" value="false" />
    <add key="CGProUsername" value="postmaster" />
    <add key="LogDir" value="C:\\Program Files (x86)\\CommuniGate Systems\\ADSync-CGP" /> (путь к файлу логов)
    <add key="LogLevel" value="4" />
    <add key="LogSizeLimit" value="3" />
    <add key="LogRotationPeriod" value="60" />
    <add key="CacheSize" value="10000" />
    <add key="displayName" value="RealName" />
    <add key="sn" value="surname" />
    <add key="department" value="ou" />
    <add key="title" value="title" />
<!--
    <add key="company" value="company" />
    <add key="mobile" value="mobile" />
-->
    <add key="CGProPasswordEncrypted" value="AFnSoeKqxIdHEbFUuLbEwu2QsSiPljO8K5PTJOp3Tf35R+xsTrY7CPRUk1aToNA7xKz0TvbeO2PZV3g6W9Z4ejY=" /> - ключ SSL(пример) или логин и пароль.
  </appSettings>
</configuration>