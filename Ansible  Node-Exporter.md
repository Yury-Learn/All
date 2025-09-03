#ansible #prometheus 

# Методичка: плейбук Ansible для установки и сопровождения node_exporter

> Документ уровня “best practices”. С нуля создаём и поддерживаем плейбук для установки **Prometheus node_exporter** на Linux-хостах. Включены структура проекта, все файлы/директории, готовые сниппеты, и подробные пояснения по каждому компоненту.

---

## 0. Структура проекта

```text
/opt/ansible-node_exporter/
├── ansible.cfg
├── inventory/
│   └── hosts.ini
├── group_vars/
│   ├── all.yml
│   ├── cluster1/
│   │   └── vault.yml      # (зашифровано Ansible Vault)
│   └── cluster2/
│       └── vault.yml      # (зашифровано Ansible Vault)
├── roles/
│   └── node_exporter/
│       ├── defaults/
│       │   └── main.yml
│       ├── tasks/
│       │   └── main.yml
│       └── handlers/
│           └── main.yml
└── site.yml
```

---

## 1) Что такое `ansible.cfg` и ключевые параметры

`ansible.cfg` — главный конфигурационный файл Ansible для проекта. Позволяет задать поведение Ansible по умолчанию (инвентарь, вывод, механизм ssh, доступ к Vault и т.д.).

**Рекомендуемый пример:**

```ini
[defaults]
inventory = ./inventory/hosts.ini       # путь к инвентарю по умолчанию
stdout_callback = yaml                   # удобочитаемый вывод
host_key_checking = True                 # проверка SSH host key
retry_files_enabled = False              # не создавать *.retry
forks = 20                               # параллелизм задач
vault_password_file = /home/ksb/.vault.txt  # файл с паролем для Ansible Vault

[ssh_connection]
pipelining = True                        # уменьшает накладные расходы ssh
timeout = 30                             # таймаут ожидания SSH
```

**Пояснения параметров:**

- `inventory` — файл/директория с описанием хостов и групп.
    
- `stdout_callback` — формат вывода (yaml/linear/json и др.).
    
- `host_key_checking` — если `False`, Ansible не будет спрашивать подтверждение host key (менее безопасно).
    
- `retry_files_enabled` — отключает создание “повторных” списков на провалившиеся хосты.
    
- `forks` — число параллельных потоков выполнения задач.
    
- `vault_password_file` — путь к файлу с _паролем_ для расшифровки **зашифрованных переменных** (Vault).
    
- `pipelining` — уменьшает количество ssh-вызовов за счёт конвейеров.
    
- `timeout` — сетевой таймаут ssh-подключения.
    

---

## 2) Что такое `inventory/hosts.ini`

`hosts.ini` — инвентарь: перечисляет **группы** и **хосты**, их адреса и переменные подключения.

**Пример:**

```ini
[cluster1]
ex3  ansible_host=10.38.16.9
ex20 ansible_host=10.38.16.8
ex22 ansible_host=10.38.16.7
ex15 ansible_host=10.38.16.10

[cluster2]
ex21 ansible_host=10.38.16.15

[prometheus]
prometheus01 ansible_host=10.38.16.55
```

**Пояснения:**

- `[]` — имя группы (логическое объединение хостов).
    
- `ansible_host` — реальный IP/имя хоста для SSH.
    
- Можно задавать per-host/per-group переменные: `ansible_user`, `ansible_port`, `ansible_connection=local` (для локального выполнения на самом хосте), и т.п.
    
- Запуск по группам/хостам: `--limit cluster1`, `--limit ex3`.
    

---

## 3) Что такое `group_vars/all.yml` и его параметры

`group_vars/all.yml` — **общие** (нечувствительные) переменные для всех хостов инвентаря. Здесь удобно держать версию node_exporter, порт, списки доступа, выбор типа firewall.

**Рекомендуемый пример:**

```yaml
# Где живёт Prometheus (для allowlist firewall)
prometheus_ip: "10.38.16.55"

# Версия и сетевые параметры node_exporter
node_exporter_version: "1.8.2"
node_exporter_port: 9100
node_exporter_listen: "0.0.0.0:{{ node_exporter_port }}"
node_exporter_extra_args: ""   # например: "--collector.textfile.directory=/var/lib/node_exporter/textfile"

# Разрешённые источники опроса (Prometheus-сервер(а))
allow_scrapers:
  - "{{ prometheus_ip }}/32"

# Выбор сетевого стека для открытия порта 9100
use_firewalld: false
use_ufw: false
use_iptables: true
```

**Пояснения:**

- `prometheus_ip` — IP Prometheus, использующий порт 9100. Нужен, чтобы открыть доступ к node_exporter только с этого адреса.
    
- `node_exporter_version` — версия бинарника GitHub-релиза.
    
- `node_exporter_port` — порт прослушивания.
    
- `node_exporter_listen` — адрес+порт (`0.0.0.0:9100`).
    
- `node_exporter_extra_args` — дополнительные флаги (включение/исключение коллекторов, textfile и пр.).
    
- `allow_scrapers` — список подсетей/адресов, которым разрешено подключаться к 9100.
    
- `use_firewalld`/`use_ufw`/`use_iptables` — включите **ровно один** стек, которым управляете в вашей ОС.
    

---

## 4) Что такое `vault.yml` и его параметры

`vault.yml` — **зашифрованный** файл переменных (Ansible Vault). Обычно кладём в `group_vars/<group>/vault.yml` или `host_vars/<host>/vault.yml` и храним **чувствительные** данные: логины/пароли SSH, sudo.

**Пример (group_vars/cluster1/vault.yml):**

```yaml
ansible_user: "ksb"
ansible_password: "SSH_ПАРОЛЬ_ХОСТОВ_CLUSTER1"
ansible_become: true
ansible_become_method: sudo
ansible_become_password: "SUDO_ПАРОЛЬ"
```

**Пояснения:**

- `ansible_user` / `ansible_password` — учётка и пароль SSH.
    
- `ansible_become` — включить sudo для задач.
    
- `ansible_become_method` — обычно `sudo`.
    
- `ansible_become_password` — пароль для sudo (если требуется).
    
- Шифрование/редактирование:  
    `ansible-vault create group_vars/cluster1/vault.yml`  
    `ansible-vault edit group_vars/cluster1/vault.yml`
    
- Расшифrovка на лету: Ansible сам использует пароль из `vault_password_file = /home/ksb/.vault.txt` (см. `ansible.cfg`).
    

---

## 5) Что такое `defaults` и параметры `roles/node_exporter/defaults/main.yml`

`defaults/main.yml` — **значения по умолчанию** переменных роли. Они имеют самый низкий приоритет (могут быть переопределены в `group_vars`, `host_vars`, инвентаре или прямо в плейбуке). Нужны, чтобы роль работала даже без внешних vars.

**Пример:**

```yaml
---
node_exporter_version: "1.8.2"
node_exporter_port: 9100
node_exporter_listen: "0.0.0.0:{{ node_exporter_port }}"
node_exporter_extra_args: ""

# firewall дефолты (безопасно: по умолчанию ничего не трогаем)
use_firewalld: false
use_ufw: false
use_iptables: false

# если allow_scrapers не задан — оставим пусто (таски пропустятся)
allow_scrapers: []
```

**Пояснения:**

- Здесь задаём «разумные» дефолты — роль не упадёт, даже если `group_vars` не созданы.
    
- Логика firewall включается **только** при явном указании соответствующего флага.
    

---

## 6) Что такое `tasks` и параметры `roles/node_exporter/tasks/main.yml`

`tasks/main.yml` — **последовательность задач** роли: установка бинарника, systemd-юнит, открытие порта, запуск сервиса. Это «ядро» роли.

**Рекомендуемый пример (кросс-дистрибутивно):**

```yaml
---
- name: Ensure node_exporter user exists
  ansible.builtin.user:
    name: nodeexp
    system: true
    shell: /usr/sbin/nologin
    create_home: false

- name: Download node_exporter tarball
  ansible.builtin.get_url:
    url: "https://github.com/prometheus/node_exporter/releases/download/v{{ node_exporter_version }}/node_exporter-{{ node_exporter_version }}.linux-amd64.tar.gz"
    dest: "/tmp/node_exporter-{{ node_exporter_version }}.tar.gz"
    mode: "0644"
  register: dl
  until: dl is succeeded
  retries: 3
  delay: 5

- name: Unpack node_exporter to /opt/node_exporter-<ver>
  ansible.builtin.unarchive:
    src: "/tmp/node_exporter-{{ node_exporter_version }}.tar.gz"
    dest: "/opt"
    remote_src: true
    extra_opts: ["--strip-components=1"]
  args:
    creates: "/opt/node_exporter"

- name: Install binary to /usr/local/bin
  ansible.builtin.copy:
    src: /opt/node_exporter
    dest: /usr/local/bin/node_exporter
    mode: "0755"
    owner: root
    group: root
    remote_src: true
  notify: Restart node_exporter

- name: Create systemd unit
  ansible.builtin.copy:
    dest: /etc/systemd/system/node_exporter.service
    mode: "0644"
    content: |
      [Unit]
      Description=Prometheus Node Exporter
      After=network-online.target
      Wants=network-online.target
      Documentation=https://github.com/prometheus/node_exporter

      [Service]
      User=nodeexp
      ExecStart=/usr/local/bin/node_exporter \
        --web.listen-address={{ node_exporter_listen | default('0.0.0.0:' ~ (node_exporter_port | default(9100))) }} \
        {{ node_exporter_extra_args | default('') }}
      NoNewPrivileges=yes
      ProtectSystem=full
      ProtectHome=yes
      PrivateTmp=yes
      Restart=always
      RestartSec=3s
      StandardOutput=journal
      StandardError=journal

      [Install]
      WantedBy=multi-user.target
  notify: Restart node_exporter

# --- Firewall options (включаются по флагам и списку allow_scrapers) ---

- name: Open port 9100/tcp for Prometheus (firewalld)
  when:
    - (use_firewalld | default(false)) | bool
    - (allow_scrapers | default([])) | length > 0
  ansible.posix.firewalld:
    port: "{{ node_exporter_port }}/tcp"
    source: "{{ item }}"
    permanent: true
    immediate: true
    state: enabled
  loop: "{{ allow_scrapers | default([]) }}"

- name: Open port 9100/tcp for Prometheus (ufw)
  when:
    - (use_ufw | default(false)) | bool
    - (allow_scrapers | default([])) | length > 0
  community.general.ufw:
    rule: allow
    port: "{{ node_exporter_port }}"
    proto: tcp
    src: "{{ item | regex_replace('/32$','') }}"
  loop: "{{ allow_scrapers | default([]) }}"

- name: Open port 9100/tcp for Prometheus (iptables, idempotent)
  when:
    - (use_iptables | default(false)) | bool
    - (allow_scrapers | default([])) | length > 0
  ansible.builtin.shell: >
    iptables -C INPUT -p tcp -s {{ item }} --dport {{ node_exporter_port }} -j ACCEPT
    || iptables -I INPUT -p tcp -s {{ item }} --dport {{ node_exporter_port }} -j ACCEPT
  args: { warn: false }
  loop: "{{ allow_scrapers | default([]) }}"

- name: Persist iptables rules (Debian-like)
  when:
    - (use_iptables | default(false)) | bool
    - ansible_facts['os_family'] == 'Debian'
  ansible.builtin.shell: |
    if command -v netfilter-persistent >/dev/null 2>&1; then
      netfilter-persistent save;
    else
      mkdir -p /etc/iptables && iptables-save > /etc/iptables/rules.v4;
    fi

- name: Start and enable service
  ansible.builtin.systemd:
    name: node_exporter
    state: started
    enabled: true
    daemon_reload: true
```

**Ключевые моменты:**

- `user` — отдельный системный пользователь без shell.
    
- `get_url` + `unarchive` — скачивание и распаковка релиза.
    
- `copy` — установка бинарника в стандартный путь.
    
- `systemd unit` — безопасные флаги (NoNewPrivileges, ProtectSystem, ProtectHome, PrivateTmp).
    
- `when` + `loop` — условное применение firewall’а с allowlist.
    
- `systemd` — включение автозапуска и перезапуска.
    

---

## 7) Что такое `handlers` и параметры `roles/node_exporter/handlers/main.yml`

`handlers` — задачи, которые **выполняются только по уведомлению** (`notify`) из tasks. Обычно: рестарт сервисов после изменения конфигурации.

**Пример:**

```yaml
---
- name: Restart node_exporter
  ansible.builtin.systemd:
    name: node_exporter
    state: restarted
    daemon_reload: true
```

**Пояснения:**

- Handler сработает, если изменились бинарник, unit-файл или другие ресурсы, помеченные `notify: Restart node_exporter`.
    
- `daemon_reload: true` — чтобы systemd перечитал юниты, если мы их изменили.
    

---

## 8) Что такое `site.yml` и его параметры

`site.yml` — главный **плейбук**, описывающий последовательность **плеев** (play). Каждый плей — это “набор ролей/задач для группы хостов”.

**Пример:**

```yaml
---
- name: Deploy node_exporter to cluster1
  hosts: cluster1         # к каким хостам применяется плей
  become: true            # выполнять с повышением прав (sudo)
  roles:
    - node_exporter       # список ролей
  # serial: 10            # (опционально) выкатывать партиями
  # any_errors_fatal: true# (опционально) останавливаться при ошибке

- name: Deploy node_exporter to cluster2
  hosts: cluster2
  become: true
  roles:
    - node_exporter
```

**Пояснения параметров:**

- `name` — описание плея (для читаемости).
    
- `hosts` — цель: группа/паттерн хостов.
    
- `become` — нужно ли sudo.
    
- `roles` — какие роли применить (в порядке).
    
- Дополнительно часто используют:
    
    - `vars` — локальные переменные для плея;
        
    - `pre_tasks` / `post_tasks` — задачи до/после ролей;
        
    - `serial` — выкатывать по N хостов одновременно (для безопасных обновлений).
        

---

## Быстрый старт (из предыдущего поста)

1. **Проверка синтаксиса и доступности:**
    

```bash
ansible-inventory --graph
ansible-playbook site.yml --syntax-check
ansible -m ping cluster1
```

2. **Запуск по одному хосту:**
    

```bash
ansible-playbook site.yml --limit ex3 -vv
```

3. **Боевой запуск по группе:**
    

```bash
ansible-playbook site.yml --limit cluster1 -vv
```

4. **Проверки на целевых хостах:**
    

```bash
systemctl status node_exporter --no-pager
ss -lntp | grep ':9100'
curl -s http://127.0.0.1:9100/metrics | head
```

5. **Ограничение доступа к 9100:** включите один из стеков (`use_iptables`/`use_firewalld`/`use_ufw`) и укажите `allow_scrapers` (обычно IP Prometheus). Повторно запустите плейбук.
    

---

## Обновления, откаты и трюки

- **Обновить версию:** смените `node_exporter_version` → `ansible-playbook site.yml`.
    
- **Откат:** верните прежнюю версию в vars → снова запустите плей.
    
- **Батч-выкат:** добавьте `serial: 10` в `site.yml`.
    
- **Textfile collector:**
    
    ```yaml
    node_exporter_extra_args: "--collector.textfile.directory=/var/lib/node_exporter/textfile"
    ```
    
    и отдельная задача на создание каталога.
    

---

## .gitignore (рекомендуется)

```gitignore
# локальный файл с паролем от Vault — НИКОГДА не коммитить!
/home/*/.vault.txt

# служебные файлы
*.retry
.cache/
*.log
```

> `group_vars/**/vault.yml` можно коммитить — это **зашифрованные** файлы (не содержат открытых секретов). Не путайте их с `vault_password_file`.

---

### Итог

По этой “методичке” любой сисадмин сможет:

- организовать проект Ansible для node_exporter по лучшим практикам;
    
- хранить секреты корректно (Vault);
    
- развернуть и обновлять node_exporter идемпотентно и безопасно;
    
- ограничить доступ к порту 9100 только с Prometheus-сервера.