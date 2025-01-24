# Sketchybar config
https://github.com/FelixKratz/SketchyBar

![alt text](https://github.com/ychie/sketchybar/blob/main/images/Screenshot%202025-01-24%20at%2001.42.05.png?raw=true)

# Installation

Add files from this repository to $HOME/.config/sketchybar and then install SbarLua with sketchybar itself.

```
# Installing SbarLua
(git clone https://github.com/FelixKratz/SbarLua.git /tmp/SbarLua && cd /tmp/SbarLua/ && make install && rm -rf /tmp/SbarLua/)

# Installing sketchybar
brew tap FelixKratz/formulae
brew install sketchybar
brew services start sketchybar
```

# Font

By default this config uses 'Iosevka Nerd Font'. You can install using brew with the command bellow. Otherwise you can change it to any other you like in resources/settings.lua. Without it you will not have all the icons displayed.

```
brew install --cask font-iosevka-nerd-font
```
