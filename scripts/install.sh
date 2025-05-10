#!/bin/bash

sudo pacman -Syu --noconfirm neovim hyprland waybar swaync

# Install yay
sudo pacman -S --needed --noconfirm git base-devel
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si

cd -
yay -Y --gendb
yay -Syu --devel
yay -Y --devel --save
