#!/bin/bash

# If problems refer to https://github.com/elifouts/Dotfiles.git

sudo pacman -Sy --noconfirm hyprland neovim waybar swaync ghostty fish
sudo pacman -Sy --noconfirm --needed git
sudo pacman -Sy --noconfirm --needed python python-pip python-pywalfox
sudo pacman -Sy --noconfirm --needed grim slurp pulsemixer wlsunset

# Install yay
sudo pacman -S --needed --noconfirm git base-devel
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si

cd -
yay -Y --gendb
yay -Syu --devel
yay -Y --devel --save

yay -S --noconfirm --needed wl-clipboard otf-codenewroman-nerd hyprpicker blueman bluez pywal
yay -S --noconfirm --needed zen-browzer

temp=$( realpath "$0"  )
dir=$(dirname "$temp")


cp -r $dir/../.config/hypr ~/.config
cp -r $dir/../.config/waybar ~/.config
cp -r $dir/../.config/wofi ~/.config
cp -r $dir/../.config/ghostty ~/.config
cp -r $dir/../.config/swaync ~/.config
cp -r $dir/../wallpapers ~/
cp -r $dir/../toggle_nightlight.sh ~


$dir/swayncinstall.sh
$dir/waybarinstall.sh
$dir/wofiinstall.sh
