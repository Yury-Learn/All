Сейчас в большинстве популярных дистрибутивов на базе Linux в качестве файрвола по умолчанию используется nftables. Конкретно в Debian начиная с Debian 10 Buster. Я обычно делаю вот так в нём:

# apt remove --auto-remove nftables
# apt purge nftables
# apt update
# apt install iptables

Но это не может продолжаться вечно. Для какого-нибудь одиночного сервера эти действия просто не нужны. Проще сразу настроить nftables. К тому же у него есть и явные преимущества, про которые я знаю:

◽️ единый конфиг для ipv4 и ipv6;
◽️ более короткий и наглядный синтаксис;
◽️ nftables умеет быстро работать с огромными списками, не нужен ipset;
◽️ экспорт правил в json, удобно для мониторинга.

Я точно помню, что когда-то писал набор стандартных правил для nftables, но благополучно его потерял. Пришлось заново составлять, поэтому и пишу сразу заметку, чтобы не потерять ещё раз. Правила будут для условного веб сервера, где разрешены на вход все соединения на 80 и 443 порты, на порт 10050 zabbix агента разрешены только с zabbix сервера, а на 22-й порт SSH только для списка IP адресов. Всё остальное закрыто на вход. Исходящие соединения сервера разрешены.

Начну с базы, нужной для управления правилами. Смотрим существующий список правил и таблиц:

# nft -a list ruleset
# nft list tables

Очистка правил:

# nft flush ruleset

Дальше сразу привожу готовый набор правил. Отдельно отмечу, что в nftables привычные таблицы и цепочки нужно создать отдельно. В iptables они были по умолчанию. 

nft add table inet filter
nft add chain inet filter input { type filter hook input priority 0\; }
nft add rule inet filter input ct state related,established counter accept
nft add rule inet filter input iifname "lo" counter accept
nft add rule inet filter input ip protocol icmp counter accept
nft add rule inet filter input tcp dport {80, 443} counter accept
nft add rule inet filter input ip saddr { 192.168.100.0/24, 172.20.0.0/24, 1.1.1.1/32 } tcp dport 22 counter accept
nft add rule inet filter input ip saddr 2.2.2.2/32 tcp dport 10050 counter accept
nft chain inet filter input { policy drop \; }

Вот и всё. Мы создали таблицу filter, добавили цепочку input, закинули туда нужные нам разрешающие правила и в конце изменили политику по умолчанию на drop. Так как никаких других правил нам сейчас не надо, остальные таблицы и цепочки можно не создавать. Осталось только сохранить эти правила и применить их после загрузки сервера. 

У nftables есть служба, которая при запуске читает файл конфигурации /etc/nftables.conf. Запишем туда наш набор правил. Так как мы перезапишем существующую конфигурацию, где в начале стоит очистка всех правил, нам надо отдельно добавить её туда:

# echo "flush ruleset" > /etc/nftables.conf
# nft -s list ruleset >> /etc/nftables.conf
# systemctl enable nftables.service

Можно перезагружаться и проверять автозагрузку правил. Ещё полезная команда, которая пригодится в процессе настройки. Удаление правила по номеру:

# nft delete rule inet filter input handle 9

Добавление правила в конкретное место с номером в списке:

# nft add rule inet filter input position 8 tcp dport 22 counter accept

В целом, ничего сложного. Подобным образом настраиваются остальные цепочки output или forward, если нужно. Синтаксис удобнее, чем у iptables. Как-то более наглядно и логично, особенно со списками ip адресов и портов, если они небольшие. 

Единственное, что не нашёл пока как делать - как подгружать очень большие списки с ip адресами. Вываливать их в список правил - плохая идея. Надо как-то подключать извне. По идее это описано в sets (https://wiki.nftables.org/wiki-nftables/index.php/Sets), но я пока не разбирался.
