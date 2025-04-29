---
tags:
  - ZSH_THEME
  - "#zsh"
---
## ZSH
1. Проверка версии
`zsh --version`
Смена оболочки
`chsh -s $(which zsh)`

## Oh-My-Zsh
1. Установка Oh-my-zsh
`sh -c "$(wget -O-https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"'
OR
`sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"`
2. Тема Powerlevel10k
`git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k`
- Подсветка синтаксиса
`git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting`
- Автодополнение
`git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions`

3. Редактирование оболочки
`nvim ~/.zshrc`
Добавляем тему+плагины
>#ZSH_THEME="robbyrussell"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git zsh-syntax-highlighting zsh-autosuggestions)

4. Переключение на оболочку
`source ~/.zshrc`
