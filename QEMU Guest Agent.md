#vmmanager  #qemu

# Восстанавливаем работу QEMU в Guest Agent — Инструкция ISPsystem

---

QEMU Guest Agent — это программа-демон, которая устанавливается на ВМ. QEMU Guest Agent обеспечивает выполнение команд на ВМ и обмен информацией между ВМ и узлом кластера.

VMmanager использует QEMU Guest Agent чтобы изменять сетевые настройки ВМ без перезагрузки. Если QEMU Guest Agent недоступен для платформы в течение пяти минут, VMmanager перезагрузит ВМ для применения настроек.

Чтобы управлять ВМ с ОС CentOS, в QEMU Guest Agent должна быть включена функция guest-exec.

Чтобы избежать незапланированного перезапуска ВМ, вы можете проверить статус QEMU Guest Agent перед изменением настроек. Это можно сделать на ВМ или узле кластера.

## Диагностика на ВМ
1. Подключитесь к ВМ по SSH.
2. Определите статус QEMU Guest Agent:
    
    ```
    systemctl status qemu-guest-agent
    ```
    
    Примеры ответов:
    
    QEMU Guest Agent запущен
    
    ```
    ● qemu-guest-agent.service - QEMU Guest Agent
       Loaded: loaded (/usr/lib/systemd/system/qemu-guest-agent.service; enabled; vendor preset: enabled)
       Active: active (running) since Вт 2021-08-10 05:25:54 UTC; 1 weeks 3 days ago
    ```
    
    QEMU Guest Agent остановлен
    
    ```
    ● qemu-guest-agent.service - QEMU Guest Agent
       Loaded: loaded (/usr/lib/systemd/system/qemu-guest-agent.service; enabled; vendor preset: enabled)
       Active: inactive (dead) since Пт 2021-08-20 06:27:16 UTC; 2s ag
    ```
    
    QEMU Guest Agent не установлен
    
    ```
    Unit qemu-guest-agent.service could not be found.
    ```
    

## Диагностика на узле кластера

1. Подключитесь к узлу кластера по SSH.
2. Определите статус QEMU Guest Agent:
    
    ```
    virsh qemu-agent-command <vm_id>_<vm_name> '{"execute": "guest-info", "arguments": {}}'
    ```
    
    Если QEMU Guest Agent запущен, вы получите ответ вида:
    
    Фрагмент ответа в JSON
    
    ```
    {"return":{"version":"2.12.0","supported_commands":[{"enabled":true,"name":"guest-get-osinfo","success-response":true}
    ```
    
    Если QEMU Guest Agent не запущен или остановлен, вы получите ответ вида:
    
    ```
    ошибка: Guest agent is not responding: QEMU guest agent is not connected
    ```
    
3. Для ВМ с ОС CentOS определите статус функции guest-exec: 
    
    ```
    virsh qemu-agent-command <vm_id>_<vm_name> '{"execute":"guest-info"}' --pretty | grep -B1 "guest-exec"
    ```
    
    Фрагмент ответа, если функция включена
    
    ```
    "enabled": true,
    "name": "guest-exec",
    ```
    
    Фрагмент ответа, если функция выключена
    
    ```
    "enabled": false,
    "name": "guest-exec",
    ```
    

## Восстановление работы
### Если QEMU Guest Agent не установлен

1. Подключитесь к ВМ по SSH.
2. Установите QEMU Guest Agent:
    
    ОС CentOS
    
    ```
    yum install qemu-guest-agent
    ```
    
    ОС Debian, Ubuntu
    
    ```
    apt install qemu-guest-agent
    ```
    
3. Добавьте QEMU Guest Agent в автозагрузку:
    
    ```
    systemctl enable --now qemu-guest-agent
    ```
    
4. Проверьте статус QEMU Guest Agent:
    
    ```
    systemctl status qemu-guest-agent
    ```
    
5. Проверьте статус службы SELinux:
    
    Если статус отличается от disable:
    
    1. Отключите SELinux. Для этого замените в файле **/etc/selinux/config** строку
        
        на
        
    2. Перезагрузите ВМ.
6. Если в файле **/etc/sysconfig/qemu-ga** есть строка вида
    
    ```
    BLACKLIST_RPC=guest-file-open,guest-file-close,guest-file-read,guest-file-write,guest-file-seek,guest-file-flush,guest-exec,guest-exec-status
    ```
    
    1. Закомментируйте или удалите эту строку.
    2. Перезапустите QEMU Guest Agent:
        
        ```
        systemctl restart qemu-guest-agent
        ```
        

### Если QEMU Guest Agent остановлен

1. Подключитесь к ВМ по SSH.
2. Запустите QEMU Guest Agent:
    
    ```
    systemctl start qemu-guest-agent
    ```
    

### Если функция guest-exec отключен

1. Подключитесь к ВМ по SSH.
2. Выполните команду: 
    
    ```
    sed -i '/BLACKLIST_RPC=/cBLACKLIST_RPC=' /etc/sysconfig/qemu-ga
    ```
    
3. Перезапустите QEMU Guest Agent: 
    
    ```
    systemctl restart qemu-guest-agent
    ```
    

## Работа QEMU Guest Agent в ОС Windows

### Установка[](https://www.ispsystem.ru/docs/vmmanager-admin/voprosy-i-otvety/kak-proverit-i-vosstanovit-rabotu-qemu-guest-agent#id-%D0%9A%D0%B0%D0%BA%D0%BF%D1%80%D0%BE%D0%B2%D0%B5%D1%80%D0%B8%D1%82%D1%8C%D0%B8%D0%B2%D0%BE%D1%81%D1%81%D1%82%D0%B0%D0%BD%D0%BE%D0%B2%D0%B8%D1%82%D1%8C%D1%80%D0%B0%D0%B1%D0%BE%D1%82%D1%83QEMUGuestAgent?-%D0%A3%D1%81%D1%82%D0%B0%D0%BD%D0%BE%D0%B2%D0%BA%D0%B0)

1. Чтобы подготовить ВМ к установке драйверов virtio, создайте диск размером 1 ГБ с типом подключения virtio и подключите его к ВМ: раздел **Виртуальные машины** → выберите ВМ → кнопка **Параметры** → раздел **Виртуальные диски** → **Подключить еще диск** → **Создать диск и подключить** → выберите **Размер** 1 ГБ и **Тип подключения** virtio → кнопка **Подключить диск**.
2. Скачайте и установите на ВМ [драйверы Virtio](https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/). 
    
    - Для Windows Server 2012 R2 используйте [virtio-win-guest-tools версии 0.1.189](https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/archive-virtio/virtio-win-0.1.189-1/virtio-win-0.1.189.iso).
    - Для Windows Server 2008 используйте [virtio-win-guest-tools версии 0.1.137](https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/archive-virtio/virtio-win-0.1.137-1/virtio-win-0.1.137.iso).
    
3. Скачайте и установите на ВМ ПО [QEMU Guest Agent](https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/latest-qemu-ga/).

### Диагностика[](https://www.ispsystem.ru/docs/vmmanager-admin/voprosy-i-otvety/kak-proverit-i-vosstanovit-rabotu-qemu-guest-agent#id-%D0%9A%D0%B0%D0%BA%D0%BF%D1%80%D0%BE%D0%B2%D0%B5%D1%80%D0%B8%D1%82%D1%8C%D0%B8%D0%B2%D0%BE%D1%81%D1%81%D1%82%D0%B0%D0%BD%D0%BE%D0%B2%D0%B8%D1%82%D1%8C%D1%80%D0%B0%D0%B1%D0%BE%D1%82%D1%83QEMUGuestAgent?-%D0%94%D0%B8%D0%B0%D0%B3%D0%BD%D0%BE%D1%81%D1%82%D0%B8%D0%BA%D0%B0)

Запустите диспетчер управления службами services.msc и проверьте, что в списке запущенных служб есть QEMU Guest Agent. Если служба остановлена, запустите её. Если такой службы нет в списке, установите ПО QEMU Guest Agent.

[![](https://www.ispsystem.ru/docs/static/109805631/image.png)](https://www.ispsystem.ru/docs/static/109805631/image.png)

Пример отображения статуса QEMU Guest Agent в диспетчере