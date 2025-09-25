#!/bin/bash

temp=$( realpath "$0"  )
dir=$(dirname "$temp")

yay -S wofi pywal --noconfirm --needed
wal -i $dirname/wallpapers/
sudo cp -a $dir/../.config/wofi ~/.config/
