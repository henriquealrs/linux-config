#!/bin/bash

temp=$( realpath "$0"  )
dir=$(dirname "$temp")

yay -S --noconfirm --needed hyprpicker otf-codenewroman-nerd pywal
wal -i $dirname/../wallpapers/
yay -S blueman bluez 

systemctl enable bluetooth
sudo cp -a $dir/../.config/waybar ~/.config/
