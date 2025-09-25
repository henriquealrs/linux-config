#!/bin/bash

temp=$( realpath "$0"  )
dir=$(dirname "$temp")

yay -S --noconfirm --needed hyprpicker otf-codenewroman-nerd pywal
wal -i $dir/../wallpapers/pywallpaper.jpg
yay -S --noconfirm --needed blueman bluez 

systemctl enable bluetooth
sudo cp -a $dir/../.config/waybar ~/.config/
