#!/bin/bash

temp=$( realpath "$0"  )
dirname "$temp"

# yay -S wofi pywal
wal -i $dirname/wallpapers/pywallpaper.jpg
sudo cp -a $dirname/.config/wofi ~/.config/
