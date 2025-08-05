#ipmi

---

## 1. Установка `ipmitool`

### Для Debian/Ubuntu:

```bash
sudo apt update
sudo apt install ipmitool
```

(утилита входит в стандартные репозитории) ([phoenixNAP | Global IT Services](https://phoenixnap.com/kb/install-ipmitool-ubuntu-centos?utm_source=chatgpt.com "How to Install IPMItool on Ubuntu & Rocky Linux - phoenixNAP"))

### Для CentOS/RHEL/Rocky:

```bash
sudo yum install OpenIPMI ipmitool
sudo systemctl enable ipmi
sudo systemctl start ipmi
```

### Оффлайн

Скачай со стороннего сайта пакет ipmitool дял ILo и закачай по scp, предварительно включив доступ к shh

Установи пакет 

```sh
dpkg -i <*имяпакета*>
```
---

## 2. Сброс пароля без знания старого (через shell ОС)

Если у вас есть **root-доступ** к операционной системе, можно изменить/сбросить пароль **прямо через ОС**, вне зависимости от старого:

1. Определите ID IPMI-контроллера — обычно это `1`:
    
    ```bash
    ipmitool user list 1
    ```
    
2. В списке найдите нужного пользователя (например, `ADMIN`) и его **ID**.
    
3. Сбросьте пароль:
    
    ```bash
    ipmitool user set password <ID> [<new_password>]
    ```
    
    Если `<new_password>` не указан, утилита запросит ввод в безопасном режиме ([help.axcient.com](https://help.axcient.com/en_US/x360recover-faqs-passwords-and-networks/360052039753-x360Recover-How-to-reset-a-lost-IPMI-password-remotely?utm_source=chatgpt.com "How to reset a lost IPMI password remotely - x360Recover - Axcient")).
    

Пример:

```bash
ipmitool user set password 2 
# или с явным паролем:
ipmitool user set password 2 NewSecurePass2025!
```

---

## 3. Создание нового пользователя (если сброс недоступен)

Если восстановление старого пользователя не подходит, можно добавить **нового администратора**:

```bash
# Создание пользователя с ID 3
ipmitool user set name 3 newadmin
ipmitool user set password 3 AnotherPass123
ipmitool user enable 3
ipmitool channel setaccess 1 3 callin=on ipmi=on link=on privilege=4
```

([Intel](https://www.intel.com/content/www/us/en/support/articles/000055688/server-products.html?utm_source=chatgpt.com "How to use IPMI Commands to Reset Password and Username on ..."))

---

## 4. Альтернативный способ: сброс BMC к заводским настройкам

Если ни root-доступа, ни IPMI-пароля нет, и у вас есть **физический доступ к серверу**, можно сбросить BMC:

- Через утилиту **ipmicfg** (Supermicro):
    
    - Бут с FreeDOS → `ipmicfg -fde` (сброс настроек) ([ServeTheHome](https://www.servethehome.com/reset-supermicro-ipmi-password-default-lost-login/?utm_source=chatgpt.com "Reset Supermicro IPMI Password to Default - Physical Access - STH"), [fractionservers.com](https://www.fractionservers.com/knowledge-base/howto-reset-supermicro-ipmi-to-defaults/?utm_source=chatgpt.com "Howto Reset Supermicro IPMI to Defaults - Fraction Servers"))
        
- Или через raw-команду в shell ОС (на некоторых платформах):
    
    ```bash
    ipmitool raw 0x3c 0x40
    ```
    
    Это сбросит BMC на заводские настройки ([TrueNAS Open Enterprise Storage](https://www.truenas.com/community/threads/supermicro-ipmi-password-reset.80010/?utm_source=chatgpt.com "SuperMicro IPMI password reset | TrueNAS Community"))
    

После сброса логин/пароль станут стандартными (например, ADMIN/ADMIN), но уточните документацию платформы.

---

## 5. Проверка

После изменения пароля или создания пользователя:

```bash
ipmitool -I lanplus -H <IP_ILO> -U newadmin -P AnotherPass123 power status
```

Если утилита возвращает статус питания, значит всё работает.

---

## ✅ Итоговая сводка

|Шаг|Что делаем|
|---|---|
|Установить `ipmitool`|apt/yum install + сервис|
|Изменить пароль|Через `ipmitool user set password ID` под root|
|Добавить пользователя|Через серию команд `set name`, `set password`, `enable`, `channel setaccess`|
|Сброс BMC|Через ipmicfg или raw-команду|
|Проверить|Подключиться с новым логином|

---

