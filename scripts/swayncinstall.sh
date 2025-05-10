#!/bin/bash

temp=$( realpath "$0"  )
dirname "$temp"

yay -S --noconfirm --needed gvfs pywal
wal -i $dirname/wallpapers/pywallpaper.jpg
sudo cp -a $dirname/.config/swaync ~/.config/
