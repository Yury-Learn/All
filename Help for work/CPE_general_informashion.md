nvd.nist.gov - словари, критичности и вектор
access.redhat.com - смотрим по системам Rocky (баг трекер, портал для пользователей)
cve.mitre.org - база уязвимостей
security-traceker.debian.org - смотрим по debian 


Common Platform Enumeration (CPE) - можно увидеть на базе NVD


cpe:2.3:a:gnu:glibc:2.34*:*:*:*:*:*:*:*

CPE - база словарей
2.3 - версия словарей 2.3
а - application 
o - operathion system
hw (h) - hardware

gnu - vendor (производитель) - кусок ОС
Есть приложение, которое называется File и вендор нужно для определения.

glibc - название пакета
2.34 - версия пакета (2.34* - звездочка, что бы версии не терялись, фактическое называние = 2.34-83.el9.7)

2.34-83 - версия программы
el9.7 - версия ОС
патч: подверсии: апдейты




Package URL (PURL) - эта еще одна база разметки уязвимостей для разметки уязвимостей

pkg:pypi/django@3.2.9

pkg - это база PURL(ов) 
pypi - это пакет для питона, который берется из pipy
/django - это пакет
@3.2.9 - это версия

OSS index - база уязвимостей питона.




https://nvd.nist.gov/products/cpe - словарик уязвимостей


пример CPE кода
<cpe-item name="cpe:/a:google:chrome:34.0.1847.12">
    <title xml:lang="en-US">Google Chrome 34.0.1847.12</title> - читаемо для обычных людей
    <references>
      <reference href="http://src.chromium.org/viewvc/chrome/releases/">Product</reference> - ссылка на релиз
    </references>
    <cpe-23:cpe23-item name="cpe:2.3:a:google:chrome:34.0.1847.12:*:*:*:*:*:*:*"/> - используем его
  </cpe-item>



  Конвертируем словарик xml to json. Убираем всё лишнее. Используем только название продукта и CPE код для работы. (Обязательно в обратном порядке) Название может одно и тоже, а ключ должен быть уникальным.
  Json - ключ - уникальный. Ставим тут CPE код.
  		значение - название софта (он может быть одно и то же)


  		Формат ДИКТ. Режим его в 5 раз его размер.

<cpe-item name="cpe:/a:nginx:nginx:0.1.0" deprecated="true" deprecation_date="2021-11-01T16:02:37.240Z">
    <title xml:lang="en-US">Nginx 0.1.0</title>
    <references>
      <reference href="http://nginx.org/en/download.html">Change Log</reference>
    </references>
    <cpe-23:cpe23-item name="cpe:2.3:a:nginx:nginx:0.1.0:*:*:*:*:*:*:*">
      <cpe-23:deprecation date="2021-11-01T12:02:37.240-04:00">
        <cpe-23:deprecated-by name="cpe:2.3:a:f5:nginx:0.1.0:*:*:*:*:*:*:*" type="NAME_CORRECTION"/>
      </cpe-23:deprecation>
    </cpe-23:cpe23-item>
  </cpe-item>


  Тут поменялся Vendor NGINX на F5 и показывает время, когда это изменилось. 
  можно забирать 1 раз в неделю, перед инвентаризации



apt list --installed > installed

переносим данные о установленных файлах в файл на debian