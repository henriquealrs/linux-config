#!/bin/bash

# If problems refer to https://github.com/elifouts/Dotfiles.git
sudo pacman -Syu

sudo pacman -Sy --noconfirm --needed hyprland neovim waybar swaync ghostty fish networkmanager
sudo pacman -Sy --noconfirm --needed git git-lfs
sudo pacman -Sy --noconfirm --needed python python-pip python-pywalfox nodejs npm
sudo pacman -Sy --noconfirm --needed grim slurp pulsemixer wlsunset ripgrep less 
sudo pacman -Sy --noconfirm --needed cmake ninja make

# Install yay
if command -v yay &> /dev/null; then
    echo "yay is installed and available."
    # Further actions if yay exists
else
	sudo pacman -S --needed --noconfirm git base-devel
	git clone https://aur.archlinux.org/yay.git
	cd yay
	makepkg -si

	cd -
	yay -Y --gendb
	yay -Syu --devel
	yay -Y --devel --save
fi

yay -S --noconfirm --needed wl-clipboard otf-codenewroman-nerd hyprpicker blueman bluez pywal
yay -S --noconfirm --needed zen-browser

temp=$( realpath "$0"  )
dir=$(dirname "$temp")


cp -r $dir/../.config/hypr ~/.config
cp -r $dir/../.config/waybar ~/.config
cp -r $dir/../.config/wofi ~/.config
cp -r $dir/../.config/ghostty ~/.config
cp -r $dir/../.config/swaync ~/.config
cp -r $dir/../wallpapers ~/
cp -r $dir/../toggle_nightlight.sh ~

mkdir -p ~/.local/share/applications
cp $dir/../.local/share/applications/* ~/.local/share/applications/ 

$dir/swayncinstall.sh
$dir/waybarinstall.sh
$dir/wofiinstall.sh
