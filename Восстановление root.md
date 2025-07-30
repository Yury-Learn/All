#linux #root
Слепое восстановление root-доступа: когда осталась только консоль или IPMI

Заблокировался root, слетел пароль, SSH не пускает, а у тебя только IPMI или прямой доступ к консоли? 

Без паники — вот три проверенных сценария.

## Способ 1: init=/bin/bash

Если можешь перезапустить сервер и попасть в GRUB:
1️⃣На экране GRUB выбери нужное ядро и нажми e для редактирования.
2️⃣Найди строку, начинающуюся с linux, и добавь в конец:

>init=/bin/bash

3️⃣Нажми Ctrl + X или F10 — система загрузится в bash без пароля.
4️⃣Подмонтируй root в rw:

mount -o remount,rw /

5️⃣Сбрось пароль:

```sh
passwd
```

6️⃣Перезагрузи: exec /sbin/init или просто reboot -f

Способ 2: chroot из Live-ISO или rescue-системы

1️⃣Подключи ISO через IPMI, загрузись в LiveCD.
2️⃣Определи диск: lsblk, fdisk -l
3️⃣Подмонтируй систему:

```sh 
mount /dev/sdaX /mnt
mount --bind /dev /mnt/dev
mount --bind /proc /mnt/proc
mount --bind /sys /mnt/sys
chroot /mnt
```

4️⃣Сбрось пароль: 
```sh
passwd
```

5️⃣Перезагрузи.

Способ 3: Rescue mode от хостера (если есть)
1️⃣Активируй rescue в панели (Hetzner, OVH, etc.)
2️⃣Подключись по SSH к rescue-системе.
3️⃣Повтори chroot-метод выше.