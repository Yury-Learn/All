#nmtui #nmcli
# README.md — сеть KVM/libvirt на хосте с NetworkManager (br0+br1, 5 подсетей /28)

## 1. Цель и схема

- **Хост:** Astra Linux, KVM/libvirt, NetworkManager.
    
- **Мосты:**
    
    - `br0` — менеджмент/интернет (пример: 10.38.22.156/24 → GW 10.38.22.1).
        
    - `br1` — «лабораторный» мост для ВМ. Хост выступает шлюзом для 5 подсетей /28:  
        `172.19.2.1/28`, `172.19.3.1/28`, `172.19.4.1/28`, `172.19.5.1/28`, `172.19.6.1/28`.
        
- **ВМ (статически):**  
    `att-vmal1 172.19.2.2/28 → GW 172.19.2.1`  
    `att-vmal2 172.19.3.2/28 → GW 172.19.3.1`  
    `att-vmal3 172.19.4.2/28 → GW 172.19.4.1`  
    `att-vmal4 172.19.5.2/28 → GW 172.19.5.1`  
    `att-vmal5 172.19.6.2/28 → GW 172.19.6.1`
    

---

## 2. Хост: мосты через NetworkManager

> Замените `eno2`/`eno1` на ваши физические интерфейсы.

```bash
# 2.1 br0 (менеджмент/внешка)
nmcli con add type bridge ifname br0 con-name br0
nmcli con add type bridge-slave ifname eno2 master br0
nmcli con mod br0 ipv4.addresses "10.38.22.156/24" ipv4.gateway "10.38.22.1" \
  ipv4.dns "10.38.22.5,8.8.8.8" ipv4.method manual connection.autoconnect yes
nmcli con up br0

# 2.2 br1 (мост для ВМ; без default route, с несколькими адресами-шлюзами)
nmcli con add type bridge ifname br1 con-name br1
nmcli con add type bridge-slave ifname eno1 master br1
nmcli con mod br1 ipv4.method manual ipv4.never-default yes
nmcli con mod br1 +ipv4.addresses "172.19.2.1/28"
nmcli con mod br1 +ipv4.addresses "172.19.3.1/28"
nmcli con mod br1 +ipv4.addresses "172.19.4.1/28"
nmcli con mod br1 +ipv4.addresses "172.19.5.1/28"
nmcli con mod br1 +ipv4.addresses "172.19.6.1/28"
nmcli con up br1

ip -br a show br0 br1
```

---

## 3. Хост: разрешить libvirt работать с мостами

```bash
sudo install -d -m 0755 /etc/qemu
printf "allow br0\nallow br1\n" | sudo tee /etc/qemu/bridge.conf >/dev/null
sudo chown root:root /etc/qemu/bridge.conf
sudo chmod 0640 /etc/qemu/bridge.conf

# всегда используем системный libvirt:
echo 'export LIBVIRT_DEFAULT_URI=qemu:///system' | sudo tee -a /etc/profile.d/99-libvirt-uri.sh >/dev/null
```

---

## 4. Хост: включить маршрутизацию и NAT (чтобы ВМ выходили в интернет)

```bash
# 4.1 IP forward (постоянно)
echo 'net.ipv4.ip_forward=1' | sudo tee /etc/sysctl.d/99-ip_forward.conf
sudo sysctl -p /etc/sysctl.d/99-ip_forward.conf

# 4.2 NAT через внешний интерфейс/мост (здесь br0)
sudo iptables -t nat -C POSTROUTING -s 172.19.0.0/16 -o br0 -j MASQUERADE 2>/dev/null || \
sudo iptables -t nat -A POSTROUTING -s 172.19.0.0/16 -o br0 -j MASQUERADE
sudo apt -y install iptables-persistent 2>/dev/null || true
sudo sh -c 'iptables-save > /etc/iptables/rules.v4'
```

---

## 5. ВМ: подключение к `br1` и статическая сеть

### 5.1 Привязать ВМ к мосту `br1` (один NIC)

- Через `virsh edit <VM>` убедитесь, что интерфейс:
    

```xml
<interface type='bridge'>
  <source bridge='br1'/>
  <model type='virtio'/>
</interface>
```

- Лишние NIC на `br1` удалите: `virsh detach-interface --domain <VM> --type bridge --mac <MAC> --config --live`.
    

### 5.2 Сеть внутри ВМ (NetworkManager, пример для att-vmal5)

```bash
nmcli c add type ethernet ifname ens3 con-name ens3-static
nmcli c mod ens3-static ipv4.method manual \
  ipv4.addresses "172.19.6.2/28" ipv4.gateway "172.19.6.1" \
  ipv4.dns "10.38.22.5,8.8.8.8" ipv6.method ignore
nmcli c up ens3-static
nmcli c mod ens3-static connection.autoconnect yes
```

> Если используется ifupdown: создайте `/etc/network/interfaces.d/ens3.cfg` с `address`, `gateway`, `dns-nameservers` и установите пакет `resolvconf`.

---

## 6. Проверки

```bash
# хост
ip -br a show br1
virsh domiflist att-vmal1
sudo /usr/sbin/bridge link | egrep 'br1|vnet'

# ВМ
ip -br a
ip r
ping -c1 <свой_шлюз>       # например, 172.19.4.1
ping -c1 8.8.8.8
getent hosts ya.ru
```

---

## 7. Типовые проблемы и быстрые фиксы

- **Ошибка при старте ВМ:** `qemu-bridge-helper ... access denied by acl file`  
    → Проверьте `/etc/qemu/bridge.conf` (должны быть `allow br0` и `allow br1`, права `0640`).
    
- **ВМ не резолвит имена:** пустой `/etc/resolv.conf`  
    → Для NM задайте `ipv4.dns` в профиле; для ifupdown — `dns-nameservers` + пакет `resolvconf`.
    
- **`nmcli` пишет «без управления»:**  
    → Интерфейс описан в `/etc/network/interfaces*`. Удалите/закомментируйте записи и перезапустите NetworkManager, либо используйте ifupdown.
    

---

## 8. Конфигурация ВМ (шпаргалка IP)

```
att-vmal1 172.19.2.2/28  GW 172.19.2.1
att-vmal2 172.19.3.2/28  GW 172.19.3.1
att-vmal3 172.19.4.2/28  GW 172.19.4.1
att-vmal4 172.19.5.2/28  GW 172.19.5.1
att-vmal5 172.19.6.2/28  GW 172.19.6.1
DNS: 10.38.22.5, 8.8.8.8
```

Готово. Такой набор команд воспроизводит вашу рабочую схему на чистом хосте с NetworkManager и позволяет быстро завести новые ВМ в нужные /28.