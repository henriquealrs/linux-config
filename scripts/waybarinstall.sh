#!/bin/bash

temp=$( realpath "$0"  )
dirname "$temp"

# yay -S waybar hyprpicker otf-codenewroman-nerd pywal
wal -i $dirname/../wallpapers/pywallpaper.jpg
# yay -S blueman bluez 

systemctl enable bluetooth
sudo cp -a $dirname/../.config/waybar ~/.config/
