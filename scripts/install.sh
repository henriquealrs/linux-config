#!/bin/bash

# If problems refer to https://github.com/elifouts/Dotfiles.git

sudo pacman -Sy --noconfirm hyprland neovim waybar swaync fish
sudo pacman -Sy --noconfirm --needed git
sudo pacman -Sy --noconfirm --needed python python-pip python-pywalfox
sudo pacman -Sy --noconfirm --needed grim slurp pulsemixer

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


temp=$( realpath "$0"  )
dirname "$temp"

cp -r $dirname/../.config/hypr ~/.config
cp -r $dirname/../.config/waybar ~/.config
cp -r $dirname/../.config/wofi ~/.config
cp -r $dirname/../.config/ghostty ~/.config
cp -r $dirname/../.config/swaync ~/.config
cp -r $dirname/../wallpapers ~/


$dirname/swayncinstall.sh
$dirname/waybarinstall.sh
$dirname/wofiinstall.sh
