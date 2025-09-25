#!/bin/bash

temp=$( realpath "$0"  )
dir=$(dirname "$temp")
echo $dir
yay -S --noconfirm --needed gvfs pywal
wal -i $dir/../wallpapers/pywallpaper.jpg
sudo cp -a $dir/../.config/swaync ~/.config/
