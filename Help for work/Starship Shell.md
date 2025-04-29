#shell #bash #help #linux


#   

Starship Shell для Bash/Zsh/Fish

• May 31 at 11:04

Starship — это минималистичный, невероятно быстрый и гибко настраиваемый инструмент подсказок для любой оболочки. Он работает для оболочек Bash, Zsh, Fish и других.

### Установка шрифта Powerline/шрифт FiraCode.

Требуется шрифт Powerline. Установите его с помощью команд:

```
# Debian / Ubuntu
sudo apt update
sudo apt install fonts-powerline

# Fedora
sudo dnf install powerline-fonts

# Any other Linux
git clone https://github.com/powerline/fonts.git --depth=1
cd fonts
./install.sh
cd ..
rm -rf fonts
```

Для шрифта FiraCode установите через:

```
# Debian / Ubuntu
sudo apt install fonts-firacode

# Arch Linux / Manjaro
sudo pacman -S otf-fira-code

# Gentoo
emerge -av media-fonts/fira-code

# Fedora
dnf copr enable evana/fira-code-fonts
dnf install fira-code-fonts
```

### Установка

**Установить из менеджера пакетов:**

```
# macOS
brew install starship

# Arch
yay -S starship

# Nix
nix-env --install starship

# Termux
pkg install starship
```

Для пользователей Arch узнайте, как использовать yay — лучший помощник AUR для Arch Linux/Manjaro.

**Установить из предварительно скомпилированного двоичного файла:**

Для других платформ загрузите предварительно скомпилированный двоичный файл и поместите его в свой PATH.

```
curl -s https://api.github.com/repos/starship/starship/releases/latest \
  | grep browser_download_url \
  | grep x86_64-unknown-linux-gnu \
  | cut -d '"' -f 4 \
  | wget -qi -
```

Извлеките скачанный архив.

```
tar xvf starship-*.tar.gz
```

Переместите двоичный файл _starship_ в каталог _/usr/local/bin_.

```
sudo mv starship /usr/local/bin/
```

Проверьте установленную версию звездолета.

```
$ starship --version
starship 1.4.2
```

### Настройте Zsh/Bash/Fish Shell

Добавьте строки ниже в файл конфигурации оболочки.

```
# Bash
$ vim ~/.bashrc
eval "$(starship init bash)"

# Zsh
$ vim ~/.zshrc
eval "$(starship init zsh)"

# Fish
$ vim ~/.config/fish/config.fish
eval (starship init fish)
```

Используйте конфигурацию оболочки для внесения изменений в обновление.

```
$ source ~/.zshrc
```

Готово. У вас установлена и работает подсказка Starship.