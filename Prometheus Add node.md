# README — Добавление нового узла в мониторинг/алертинг (standalone и cluster1/cluster2)

Поддерживаются два сценария:

* **standalone** — одиночные узлы вне кластеров (полезно для временных/особых серверов)
* **cluster1/cluster2** — основные кластерные группы

> Принципы: единый `job: node_exporter`, обязательные метки `cluster` и `hostname` в `file_sd`, минимальная ручная работа, воспроизводимость через Ansible.

---

## 0) Предпосылки (один раз в репозитории)

### ansible.cfg

```ini
[defaults]
inventory = ./inventory/hosts.ini
host_key_checking = False
interpreter_python = auto_silent
forks = 20
```

### Структура проекта (минимум)

```
opt/ansible-node_exporter/
├─ ansible.cfg
├─ inventory/
│  └─ hosts.ini
├─ group_vars/
│  ├─ cluster1.yml        # (опционально)
│  ├─ cluster2.yml        # (опционально)
│  └─ standalone.yml      # настройки доступа и метки кластера
├─ host_vars/
│  └─ ex8.yml             # (опционально: hostname и др.)
├─ roles/
│  ├─ node_exporter/
│  │  ├─ defaults/main.yml
│  │  ├─ files/
│  │  │  └─ node_exporter-1.9.1.linux-amd64.tar.gz
│  │  ├─ handlers/main.yml
│  │  └─ tasks/main.yml   # установка из локального архива
│  └─ prometheus/
│     └─ templates/node_exporter_targets.yml.j2
├─ site.yml
├─ bootstrap_standalone.yml
└─ quick_node_exporter_apt.yml
```

### site.yml (четыре плея)

```yaml
---
- name: Deploy node_exporter to cluster1
  hosts: cluster1
  become: true
  roles:
    - node_exporter

- name: Deploy node_exporter to cluster2
  hosts: cluster2
  become: true
  roles:
    - node_exporter

- name: Deploy node_exporter to standalone nodes
  hosts: standalone
  become: true
  roles:
    - node_exporter

- name: Configure Prometheus
  hosts: prometheus
  gather_facts: false
  become: false
  roles:
    - { role: prometheus, tags: ['prometheus'] }
```

### inventory/hosts.ini (пример)

```ini
[test]
# test-clientansible ansible_host=10.38.16.23 ansible_user=ksb ansible_ssh_private_key_file=~/.ssh/id_ansible

[cluster1]
ex3  ansible_host=10.38.16.9
ex20 ansible_host=10.38.16.8
ex22 ansible_host=10.38.16.7
ex15 ansible_host=10.38.16.10

[cluster2]
ex21 ansible_host=10.38.16.15
ex24 ansible_host=10.38.16.3
ex25 ansible_host=10.38.16.2
ex4  ansible_host=10.38.16.11
ex6  ansible_host=10.38.16.12

[prometheus]
prometheus01 ansible_connection=local

[grafana]
grafana01 ansible_host=10.38.16.20

[node_exporter]
# (опционально — если нужен агрегирующий паттерн)

[standalone]
ex8 ansible_host=10.38.16.16
```

### group\_vars/standalone.yml (рекомендуется)

> Важно: используйте **абсолютный** путь к ключу, без `~`.

```yaml
ansible_user: ansible
ansible_ssh_private_key_file: /home/ksb/.ssh/id_ansible_standalone
ansible_become: true

cluster_label: "standalone"
node_exporter_port: 9100
node_exporter_version: "1.9.1"
```

### roles/prometheus/templates/node\_exporter\_targets.yml.j2

```jinja2
{# Генерируем file_sd из заданных групп #}
{% set groups_to_use = ['cluster1','cluster2','standalone'] %}
{% for g in groups_to_use if g in groups %}
{%   for h in groups[g] | sort %}
- targets:
    - {{ hostvars[h].ansible_host | default(h) }}:{{ hostvars[h].node_exporter_port | default(9100) }}
  labels:
    cluster: "{{ hostvars[h].cluster_label | default(g) }}"
    hostname: "{{ hostvars[h].hostname | default(h) }}"
{%   endfor %}
{% endfor %}
```

### roles/node\_exporter/defaults/main.yml

```yaml
node_exporter_version: "1.9.1"
node_exporter_port: 9100
node_exporter_listen: "0.0.0.0:{{ node_exporter_port }}"
use_iptables: false
allow_scrapers: []  # пример: ["10.38.16.17"]
```

### roles/node\_exporter/handlers/main.yml

```yaml
---
- name: Restart node_exporter
  ansible.builtin.systemd:
    name: node_exporter
    state: restarted
    daemon_reload: true
```

### roles/node\_exporter/tasks/main.yml (установка из локального архива)

```yaml
---
- name: Create node_exporter user
  ansible.builtin.user:
    name: nodeexp
    system: true
    shell: /usr/sbin/nologin
    create_home: false

- name: Ensure install dir exists
  ansible.builtin.file:
    path: "/opt/node_exporter-{{ node_exporter_version }}"
    state: directory
    mode: "0755"

- name: Unpack local tarball to versioned dir
  ansible.builtin.unarchive:
    src: "node_exporter-{{ node_exporter_version }}.linux-amd64.tar.gz"  # из roles/node_exporter/files/
    dest: "/opt/node_exporter-{{ node_exporter_version }}"
    remote_src: false
    extra_opts: ["--strip-components=1"]
  args:
    creates: "/opt/node_exporter-{{ node_exporter_version }}/node_exporter"

- name: Symlink /opt/node_exporter -> /opt/node_exporter-{{ node_exporter_version }}
  ansible.builtin.file:
    src: "/opt/node_exporter-{{ node_exporter_version }}"
    dest: "/opt/node_exporter"
    state: link
    force: true

- name: Install binary to /usr/local/bin
  ansible.builtin.copy:
    src: "/opt/node_exporter/node_exporter"
    dest: /usr/local/bin/node_exporter
    mode: "0755"
    owner: root
    group: root
    remote_src: true

- name: Create systemd unit
  ansible.builtin.copy:
    dest: /etc/systemd/system/node_exporter.service
    mode: "0644"
    content: |
      [Unit]
      Description=Prometheus Node Exporter
      After=network-online.target
      Wants=network-online.target

      [Service]
      User=nodeexp
      ExecStart=/usr/local/bin/node_exporter --web.listen-address={{ node_exporter_listen }}
      Restart=on-failure
      RestartSec=3s
      NoNewPrivileges=yes
      ProtectSystem=full
      ProtectHome=yes

      [Install]
      WantedBy=multi-user.target
  notify: Restart node_exporter

# (опционально) открыть порт только для Prometheus
- name: Allow 9100/tcp from Prometheus (iptables, idempotent)
  when:
    - (use_iptables | default(false)) | bool
    - (allow_scrapers | default([])) | length > 0
  ansible.builtin.shell: >
    iptables -C INPUT -p tcp -s {{ item }} --dport {{ node_exporter_port | default(9100) }} -j ACCEPT
    || iptables -I INPUT -p tcp -s {{ item }} --dport {{ node_exporter_port | default(9100) }} -j ACCEPT
  args: { warn: false }
  loop: "{{ allow_scrapers | default([]) }}"

- name: Persist iptables rules (Debian-like)
  when:
    - (use_iptables | default(false)) | bool
    - ansible_facts['os_family'] == 'Debian'
  ansible.builtin.shell: |
    mkdir -p /etc/iptables
    iptables-save > /etc/iptables/rules.v4

- name: Enable & start node_exporter
  ansible.builtin.systemd:
    name: node_exporter
    enabled: true
    state: started
    daemon_reload: true
```

### bootstrap\_standalone.yml (заведение пользователя/ключа/sudoers)

> Используется один раз на **новый standalone‑хост**, вход временно как root/админ (`-u root -k`). Плейбук устойчив к отсутствию `visudo` и даже `/etc/sudoers`.

```yaml
---
- name: Bootstrap standalone hosts and deploy node_exporter
  hosts: standalone
  gather_facts: false

  vars:
    ansible_boot_user: ansible
    ansible_boot_pubkey: "{{ lookup('file', lookup('env','HOME') + '/.ssh/id_ansible_standalone.pub') }}"
    visudo_candidates:
      - /usr/sbin/visudo
      - /sbin/visudo
      - /usr/bin/visudo
      - /bin/visudo
    sudoers_file: /etc/sudoers
    sudoers_d_dir: /etc/sudoers.d
    sudoers_minimal: |
      # Managed by Ansible
      Defaults        env_reset
      Defaults        mail_badpass
      Defaults        secure_path="/usr/sbin:/usr/bin:/sbin:/bin"
      root    ALL=(ALL:ALL) ALL
      %sudo   ALL=(ALL:ALL) ALL
      #includedir /etc/sudoers.d

  pre_tasks:
    - name: Ensure python3 exists (Debian/Ubuntu/Astra)
      raw: |
        test -e /usr/bin/python3 || (apt-get update -y && apt-get install -y python3)
      changed_when: false
      failed_when: false

    - name: Ensure sudo exists
      raw: |
        (command -v sudo >/dev/null 2>&1) || (apt-get update -y && apt-get install -y sudo)
      changed_when: false
      failed_when: false

    - name: Detect visudo path
      stat:
        path: "{{ item }}"
      register: visudo_stats
      loop: "{{ visudo_candidates }}"

    - name: Set visudo_path fact
      set_fact:
        visudo_path: "{{ (visudo_stats.results | selectattr('stat.exists') | map(attribute='stat.path') | list | first) | default('') }}"

  tasks:
    - name: Create ansible user
      user:
        name: "{{ ansible_boot_user }}"
        shell: /bin/bash
        create_home: yes

    - name: Add authorized key for ansible
      authorized_key:
        user: "{{ ansible_boot_user }}"
        key: "{{ ansible_boot_pubkey }}"
        state: present
        manage_dir: yes

    - name: Ensure /etc/sudoers.d directory exists
      file:
        path: "{{ sudoers_d_dir }}"
        state: directory
        owner: root
        group: root
        mode: "0750"

    - name: Check if /etc/sudoers exists
      stat:
        path: "{{ sudoers_file }}"
      register: sudoers_stat

    - name: Create minimal /etc/sudoers if missing (with includedir)
      copy:
        dest: "{{ sudoers_file }}"
        content: "{{ sudoers_minimal }}"
        owner: root
        group: root
        mode: "0440"
        validate: "{{ visudo_path if visudo_path else '/bin/true' }} -csf %s"
      when: not sudoers_stat.stat.exists

    - name: Ensure /etc/sudoers includes /etc/sudoers.d  (safe edit)
      lineinfile:
        path: "{{ sudoers_file }}"
        state: present
        regexp: '^#includedir /etc/sudoers.d$'
        line: '#includedir /etc/sudoers.d'
        backup: yes
        validate: "{{ visudo_path if visudo_path else '/bin/true' }} -csf %s"

    - name: Allow passwordless sudo for ansible (validated if visudo found)
      copy:
        dest: "{{ sudoers_d_dir }}/99-ansible"
        content: "{{ ansible_boot_user }} ALL=(ALL) NOPASSWD: ALL\n"
        owner: root
        group: root
        mode: "0440"
        validate: "{{ visudo_path if visudo_path else '/bin/true' }} -csf %s"

    - name: Validate sudoers syntax (explicit check)
      command: "{{ visudo_path }} -c"
      when: visudo_path != ''
      changed_when: false

    - name: Gather facts after python appears
      setup:

    # (опционально) можно сразу вызвать роль node_exporter
    # - import_role:
    #     name: node_exporter
```

### quick\_node\_exporter\_apt.yml (быстрая установка из apt на Debian/Proxmox)

```yaml
---
- name: Install node_exporter from Debian repo (fallback)
  hosts: ex8
  become: true
  vars:
    svc: prometheus-node-exporter
  tasks:
    - name: Update apt cache
      apt:
        update_cache: yes
        cache_valid_time: 3600

    - name: Install node_exporter package
      apt:
        name: prometheus-node-exporter
        state: present

    - name: Enable & start service
      systemd:
        name: "{{ svc }}"
        enabled: yes
        state: started

    - name: Wait for 9100
      wait_for:
        port: 9100
        timeout: 20

    - name: Probe /metrics locally
      uri:
        url: http://127.0.0.1:9100/metrics
        return_content: no
```

---

## 1) Сценарий: добавить **standalone**

1. **Инвентори**:

   ```ini
   [standalone]
   exNEW ansible_host=10.38.16.ZZ
   ```
2. **Bootstrap** (один раз на новый хост, вход как root/админ):

   ```bash
   ssh-keygen -t ed25519 -f ~/.ssh/id_ansible_standalone -C "ansible-standalone-$(date +%F)"
   ansible-playbook -i inventory/hosts.ini bootstrap_standalone.yml --limit exNEW -u root -k
   ```
3. **Проверка доступа**:

   ```bash
   ansible standalone -m ping
   ansible standalone -m command -a 'sudo -n true'
   ```
4. **Установка node\_exporter**:

   * Через роль (локальный архив): `ansible-playbook -i inventory/hosts.ini site.yml --limit standalone`
   * Либо из apt: `ansible-playbook -i inventory/hosts.ini quick_node_exporter_apt.yml -u ansible -b`
5. **Prometheus (file\_sd) и reload**:

   ```bash
   ansible-playbook -i inventory/hosts.ini site.yml --tags prometheus --limit prometheus
   # если роль не делает reload: sudo systemctl reload prometheus
   ```
6. **Проверка/алерты**: таргет UP в Prometheus; алерты Host down работают для `cluster=standalone`.

## 2) Сценарий: добавить в **cluster1/cluster2**

1. **Инвентори**:

   ```ini
   [cluster1]
   exNEW ansible_host=10.38.16.XX
   ```
2. **(опц.) group\_vars/cluster1.yml**:

   ```yaml
   ansible_user: ksb
   ansible_ssh_private_key_file: /home/ksb/.ssh/id_ansible_cluster
   ansible_become: true
   cluster_label: "cluster1"
   node_exporter_port: 9100
   ```
3. **Установка node\_exporter**:

   ```bash
   ansible-playbook -i inventory/hosts.ini site.yml --limit exNEW
   ```
4. **Prometheus и проверка** — как в standalone.

---

## Команды проверок (шпаргалка)

```bash
# Инвентори и доступ
ansible-inventory --graph
ansible <group|host> -m ping
ansible <group|host> -m command -a 'sudo -n true'

# node_exporter
ansible <group|host> -m wait_for -a "port=9100 timeout=15"
ansible <group|host> -m shell -a "ss -lntp | grep :9100 || true"

# Prometheus target
curl -s "http://127.0.0.1:9090/api/v1/targets?state=active" \
| jq '.data.activeTargets[] | select(.discoveredLabels.__address__=="10.38.16.16:9100")'
```

---

## Троблшутинг (частые случаи)

* **`UNREACHABLE! Permission denied (publickey,password)`** — для `standalone` проверь `group_vars/standalone.yml`:

  * `ansible_user: ansible`
  * `ansible_ssh_private_key_file: /home/ksb/.ssh/id_ansible_standalone` (абсолютный путь)
  * ключ действительно присутствует; `ssh -i ... ansible@IP 'id && sudo -n true'`

* **Нет `visudo` / нет `/etc/sudoers`** — используйте `bootstrap_standalone.yml`, он ставит `sudo`, создаёт минимальный `sudoers` и валидирует при наличии `visudo`.

* **`get_url`/TLS ошибки на хосте** — используйте установку из **локального архива** (см. роль `node_exporter`), не скачивайте с GitHub на целях.

* **Сервис называется по‑разному** — пакетная версия `prometheus-node-exporter` vs юнит `node_exporter`. В роли мы создаём юнит `node_exporter`.

* **`--tags prometheus` трогает все хосты** — запускайте с `--limit prometheus`, либо уберите сбор фактов в нерелевантных плеях.

* **Порт 9100 закрыт** — откройте в фаерволе только для Prometheus (iptables/ufw/firewalld) или настройте `allow_scrapers` в роли.

---

## Примечания по безопасности

* Выделенный пользователь `ansible` с `NOPASSWD:ALL` нужен для автоматизации. При необходимости ограничьте sudo по командам.
* Ограничьте доступ к 9100 только с адреса Prometheus‑сервера.
* Ротуйте/ротуйте ключи (`id_ansible_standalone`) по процедуре ИБ.

---

## Чек‑лист добавления узла (вырезать и пользоваться)

1. `hosts.ini`: добавить хост в `standalone` или в нужный кластер.
2. (standalone) `bootstrap_standalone.yml` → завести `ansible` + ключ + sudoers.
3. Установить node\_exporter (роль из локального архива **или** apt‑плейбук).
4. `site.yml --tags prometheus --limit prometheus` → обновить `file_sd` и перечитать Prometheus.
5. Проверить таргет в Prometheus/Grafana и срабатывание алертов.

---
