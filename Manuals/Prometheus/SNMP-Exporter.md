#prometheus #grafana #snmp-exporter
### Установить последнюю версию SNMP Exporter

```
$ cd ~/Downloads
$ wget https://github.com/prometheus/snmp_exporter/releases/download/v0.21.0/snmp_exporter-0.21.0.linux-amd64.tar.gz
$ tar xzf snmp_exporter-0.21.0.linux-amd64.tar.gz 
$ sudo mv snmp_exporter-0.21.0.linux-amd64 /opt/snmp_exporter
$ sudo ln -s /opt/snmp_exporter/snmp_exporter /usr/local/bin/snmp_exporter
```


1.  Перейдите в каталог загрузок. 
2. Загрузите последнюю версию архива Exporter.
3. Извлеките исполняемый файл snmp_exporter
4. Переместите папку в /opt и переименуйте snmp_exporter.
5. Символическая ссылка на исполнителя для удобного вызова.

Теперь `snmp_exporter` можно запускать по любому пути, готовому к ретрансляции метрик.

### Создание службы Systemd

Чтобы управлять экспортером как системным процессом, мы создадим файл модуля systemd.

```
$ sudo nano /etc/systemd/system/snmp-exporter.service
```

```
[Unit]
Description=Prometheus SNMP Exporter
After=network-online.target

[Service]
User=prometheus
Restart=on-failure
ExecStart=/usr/local/bin/snmp_exporter --config.file /opt/snmp_exporter/snmp.yml

[Install]  
WantedBy=multi-user.target
```

Это определяет поведение при запуске и пользовательский контекст. Теперь запустите службу:

```
$ sudo systemctl daemon-reload
$ sudo systemctl enable snmp-exporter
$ sudo systemctl start snmp-exporter
```

Статус проверки показывает, что SNMP Exporter активно работает:

```
$ sudo systemctl status snmp-exporter
● snmp-exporter.service - Prometheus SNMP Exporter
     Loaded: loaded (/etc/systemd/system/snmp-exporter.service; enabled; vendor prese>
     Active: active (running) since Thu 2022-02-23 15:12:53 UTC; 3 days ago
       Docs: https://github.com/prometheus/snmp_exporter
   Main PID: 488552 (snmp_exporter)
      Tasks: 7 (limit: 1137)
     Memory: 5.4M
     CGroup: /system.slice/snmp-exporter.service
             └─488552 /usr/local/bin/snmp_exporter --config.file=/opt/snmp_exporter/snmp.
```

### Добавление цели экспортера SNMP в Prometheus

Чтобы Prometheus начал получать статистику сетевой инфраструктуры, нам необходимо определить SNMP Exporter как цель парсинга.

 Изменить `/opt/prometheus/prometheus.yml`: 

```
scrape_configs:

  - job_name: ‘snmp_exporter‘
    metrics_path: /snmp
    static_configs:
     - targets: 
       - 192.168.1.1 # Router IP   
     params:
       module: [if_mib]
    relabel_configs:   
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: 127.0.0.1:9116 # SNMP Exporter
```

Это настраивает сервер Prometheus для:

- Очистите метрики от конечной точки экспортера snmp `/snmp`.`/snmp`
- Получение данных для сетевых интерфейсов через IF-MIB
- Переименуйте результаты с помощью IP-адреса маршрутизатора для запроса.
- Переопределить исходный адрес в системе экспортера

Мы могли бы добавить другие устройства, предоставив больше целевых IP-адресов. Сохраните файл и перезапустите Prometheus, чтобы изменения вступили в силу.

Теперь мы готовы визуализировать очищенные данные!


## Создание информационных панелей сетевых устройств в Grafana


Хотя Prometheus предоставляет функциональный веб-интерфейс для просмотра показателей и оповещений, визуализация остается на зачаточном уровне. В этом проявляется преимущество Grafana — он превосходно преобразует данные временных рядов в подробные графики. Рабочий процесс Grafana состоит из:

1.  Добавить источник данных Прометея 
2. Craft metric queries using PromQL
3. Настройте графические параметры 

Мы поэтапно создадим панель мониторинга производительности маршрутизатора.

### Creating a New Dashboard Создание новой панели мониторинга 

Войдите на свой сервер Grafana и щелкните значок +, чтобы добавить новую панель мониторинга:

Откроется пустая сетка, в которой вы можете заполнить настраиваемые графики показателей:

Мы будем создавать панели постепенно. Добавьте описательный заголовок, чтобы цель была ясна.

### Building Metric Query Panels  

Панели визуализируют результаты определяемых нами запросов PromQL. В качестве примера простого запуска счетчик времени работы SNMP может отображаться в абсолютном выражении или конвертироваться в часы:

**Router Uptime Query Запрос времени работы маршрутизатора** 

```
# Absolute seconds  
sysUpTime{instance="192.168.1.1"} 

# Friendly hours format
sysUpTime{instance="192.168.1.1"} / 3600
```

Параметры формата позволяют настраивать единицы измерения и десятичные знаки:

Дополнительные общие метрики SNMP, для которых мы можем отображать графики:

- Interface bandwidth utilization Использование полосы пропускания интерфейса 
- Total bytes transmitted Всего передано байтов 
- CPU load average Средняя загрузка процессора 
- Firmware version string Строка версии прошивки 

**Bandwidth Usage Query Запрос использования полосы пропускания** 

```
((rate(ifInOctets{instance="192.168.1.1"}[5m]) + rate(ifOutOctets{instance="192.168.1.1"}[5m])) * 8) / 1000000 
```

Это вычисляет Мбит/с за 5 минут на основе счетчиков байтов

Дублируйте панели и расположите их в столбцы, чтобы построить:

### Дополнительные настройки и лучшие практики

Grafana  настраиваемая, помимо запросов и графиков по умолчанию. Полезные конфигурации включают в себя:

**Color coding Цветовое кодирование** 

Отображать пороговые значения, превращая панели в зеленый, оранжевый или красный цвет в зависимости от уровня серьезности:

**Smoothing Сглаживание** 

Используйте скользящие средние, чтобы укротить шумную волатильность и превратить ее в плавный тренд:

```
avg_over_time(ifOutOctets{instance="192.168.1.1"}[5m])
```

**Annotations Аннотации** 

Добавьте маркеры, связывающие такие события, как изменения конфигурации или перезапуски, с влиянием показателей:

**Templating Шаблонизация** 

Используйте раскрывающиеся списки для динамического переключения отображаемого устройства или сетевого интерфейса:

! SOME OUTPUT IS TRUNCATED FOR BREVITY  
!  
if_mib:  
  version: 3  
  auth:  
    username: Collector  
    security_level: authPriv  
    password: SUPER_AUTH  
    auth_protocol: SHA  
    priv_protocol: AES  
    priv_password: SUPER_PASS  
  walk:  
  - 1.3.6.1.2.1.2  
  - 1.3.6.1.2.1.31.1.1  
!  
! FURTHER OUTPUT IS TRUNCATED FOR BREVITY