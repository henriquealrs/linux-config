#!/bin/bash

temp=$( realpath "$0"  )
dir=$(dirname "$temp")

yay -S wofi pywal --noconfirm --needed
wal -i $dir/../wallpapers/pywallpaper.jpg
sudo cp -a $dir/../.config/wofi ~/.config/
