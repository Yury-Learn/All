#firewalld 

---

## 1.  Что такое firewalld

**`firewalld`** — это системная служба управления сетевыми фильтрами Linux (iptables или nftables), работающая на основе **зон** и **сервисов**, что делает её более удобной для администраторов, чем ручные правила.

---

## 2.  Основные команды

### Запуск и управление службой

```bash
# Проверить статус
sudo systemctl status firewalld

# Включить автозапуск
sudo systemctl enable firewalld

# Запустить
sudo systemctl start firewalld

# Перезапустить
sudo systemctl restart firewalld
```

---

## 3.  Понимание ЗОН

Зона — это набор правил для интерфейсов. Интерфейс (eth0, enp0s3 и т.д.) может быть привязан к одной из зон.

### Посмотреть активные зоны и интерфейсы:

```bash
sudo firewall-cmd --get-active-zones
```

### Привязать интерфейс к зоне:

```bash
sudo firewall-cmd --zone=public --change-interface=eth0 --permanent
```

---

## 4.  Разрешение сервисов

### Посмотреть разрешённые сервисы:

```bash
sudo firewall-cmd --zone=public --list-services
```

### Добавить сервис (например, Cockpit или SSH):

```bash
sudo firewall-cmd --zone=public --add-service=cockpit --permanent
sudo firewall-cmd --reload
```

### Удалить сервис:

```bash
sudo firewall-cmd --zone=public --remove-service=cockpit --permanent
sudo firewall-cmd --reload
```

- Полный список встроенных сервисов:

```bash
sudo firewall-cmd --get-services
```

---

## 5.  Открытие и закрытие портов

### Открыть конкретный порт (например, 8080/tcp):

```bash
sudo firewall-cmd --zone=public --add-port=8080/tcp --permanent
sudo firewall-cmd --reload
```

### Удалить порт:

```bash
sudo firewall-cmd --zone=public --remove-port=8080/tcp --permanent
sudo firewall-cmd --reload
```

---

## 6.  Проверка текущих правил

```bash
sudo firewall-cmd --list-all
```

Вывод покажет:

- Зону
    
- Интерфейсы
    
- Разрешённые сервисы
    
- Открытые порты
    
- Модули
    

---

## 7.  Временные и постоянные изменения

- **По умолчанию все изменения временные**, если не указано `--permanent`.
    
- Чтобы сделать изменение постоянным, **всегда добавляй `--permanent`**, а затем **перезагружай**:
    

```bash
sudo firewall-cmd --reload
```

---

## 8.  Проверка доступа

С клиента (например, другого сервера или ПК):

```bash
nc -vz <ip-адрес-сервера> <порт>
# или
telnet <ip> <порт>
```

---

## 9.  Сброс правил к состоянию "по умолчанию"

Полностью сбросить все зоны, порты, интерфейсы:

```bash
sudo firewall-cmd --complete-reload
```

Или удалить все пользовательские изменения:

```bash
sudo firewall-cmd --permanent --delete-all-services
sudo firewall-cmd --permanent --delete-all-ports
sudo firewall-cmd --reload
```

---

## 10. Продвинутые возможности

### Блокировка IP-адреса:

```bash
sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="192.168.1.100" reject'
sudo firewall-cmd --reload
```

### Ограничение только на TCP/UDP:

```bash
sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="192.168.1.0/24" port port="22" protocol="tcp" accept'
```

---

## 11.  Частые ошибки

|Ошибка|Причина|Решение|
|---|---|---|
|❌ Порт открыт, но соединение не идёт|Изменения не применены|`sudo firewall-cmd --reload`|
|❌ Сервис не работает после перезапуска|Правило временное|Добавить `--permanent`|
|❌ Зона не активна|Интерфейс не привязан|Использовать `--change-interface=<iface>`|

---

## 12. Пример: Открытие Cockpit и SSH

```bash
sudo firewall-cmd --zone=public --add-service=ssh --permanent
sudo firewall-cmd --zone=public --add-service=cockpit --permanent
sudo firewall-cmd --reload
```

---

## 13.  Полезные команды (шпаргалка)

| Действие                    | Команда                                                          |
| --------------------------- | ---------------------------------------------------------------- |
| Проверка активных зон       | `firewall-cmd --get-active-zones`                                |
| Посмотреть текущие правила  | `firewall-cmd --list-all`                                        |
| Открыть порт                | `firewall-cmd --add-port=80/tcp --permanent`                     |
| Разрешить сервис            | `firewall-cmd --add-service=http --permanent`                    |
| Применить изменения         | `firewall-cmd --reload`                                          |
| Установить интерфейс в зону | `firewall-cmd --change-interface=eth0 --zone=public --permanent` |

---

##  Заключение

`firewalld` — это мощный инструмент, который:

- Изолирует службы между интерфейсами,
    
- Упрощает управление правилами через **сервисы** и **зоны**,
    
- Поддерживает **постоянные и временные** настройки,
    
- Подходит для **начинающих** и **опытных** админов.
    

---
