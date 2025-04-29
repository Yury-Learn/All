## Работа с Tmux

```sh
apt install tmux
```
### Старт
```sh
tmux 
```
без параметров будет создана сессия 0
 ```sh
tmux new -s session1
``` 
новая сессия **session1**. Название отображается снизу-слева в квадратных скобках в статус строке. Далее идет перечисление окон. Текущее окно помечается звездочкой.

1. 
```bash
apt install tmux && touch ~/.tmux.conf && echo "set -g mouse on" >> ~/.tmux.conf && echo "setw -g mouse on" >> ~/.tmux.conf && echo "set -g terminal-overrides 'xterm*:smcup@:rmcup@'" >> ~/.tmux.conf && source ~/.bashrc && tmux source ~/.tmux.conf
```

### Мышь

- управление мышкой edit .conf
/etc/tmux.conf`
OR
~/.tmux.conf

Вставляем
>set -g mouse on
>setw -g mouse on
>set -g terminal-overrides 'xterm*:smcup@:rmcup@'

```sh
tmux source-file ~/.tmux.conf
```

`source ~/.bashrc`
- правая кнопка  -> контекстное меню
-  выделяем текст -> средняя кнопка вставка

### CLI
- Префикс (с него начинаются команды)
> C-b (CTRL + b)
- Новое окно (нажать CTRL+b, затем нажать с)
> C-b c
- Список окон
> C-b w  переключиться курсором вверх-вниз
- Переключение
>C-b n следующее окно
>C-b p // предыдущее окно
>C-b 0 // переключиться на номер окна

- Окна можно делить на панели (Panes) как в тайловых (мозаичных) оконных менеджерах.
- Деление окна горизонтально
>C-b "
>либо команда
>`tmux split-window -h`
- Деление окна вертикально
>C-b %
>либо команда
>`tmux split-window -v`

- Переход между панелей
>C-b стрелки курсора> // либо режим мыши
- Изменение размеров панелей
>C-b c-стрелки // либо режим мыши
- Закрытие окон
>C-b x // нужно подтвердить y
либо
`exit`

4. Сессии
- Отключение от сессии
>C-b d
либо
`tmux detach`
- Список сессий
 `tmux ls`
- Подключиться к работающей сессии
 `tmux attach` //подключение к сессии, либо к единственной, либо последней созданной
 `tmux attach -t session1` // подключение к сессии session1
- Выбрать сессию
>C-b s
- Завершение сессии
 `tmux kill-session -t session1`
- Завершить все сессии
 `tmux kill-server`

5. Список поддерживаемых комманд
`tmux list-commands`
- Дополнительная информация
 `man tmux`