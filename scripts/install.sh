#!/bin/bash

# If problems refer to https://github.com/elifouts/Dotfiles.git
sudo pacman -Syu

sudo pacman -Sy --noconfirm --needed hyprland neovim waybar swaync ghostty fish zsh networkmanager
sudo pacman -Sy --noconfirm --needed git git-lfs
sudo pacman -Sy --noconfirm --needed python python-pip python-pywalfox nodejs npm
sudo pacman -Sy --noconfirm --needed grim slurp pulsemixer wlsunset ripgrep less i3lock imagemagick
sudo pacman -Sy --noconfirm --needed cmake ninja make
sudo pacman -Sy --noconfirm --needed tmux

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
cp -r $dir/../.config/tmux ~/.config
cp -r $dir/../wallpapers ~/
cp -r $dir/../toggle_nightlight.sh ~
install -m 644 "$dir/../.zshrc" ~/.zshrc
install -m 644 "$dir/../.zshenv" ~/.zshenv

mkdir -p ~/.local/bin
install -m 755 "$dir/lock_screen.sh" ~/.local/bin/lock_screen.sh

if [[ -d ~/.oh-my-zsh/.git ]]; then
  git -C ~/.oh-my-zsh pull --ff-only
else
  git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh
fi

mkdir -p ~/.config/tmux/plugins
if [[ -d ~/.config/tmux/plugins/tpm/.git ]]; then
  git -C ~/.config/tmux/plugins/tpm pull --ff-only
else
  git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
fi

# Install tmux plugins from ~/.config/tmux/tmux.conf non-interactively.
if [[ -x ~/.config/tmux/plugins/tpm/bin/install_plugins ]]; then
  TMUX_PLUGIN_MANAGER_PATH=~/.config/tmux/plugins \
    ~/.config/tmux/plugins/tpm/bin/install_plugins ~/.config/tmux/tmux.conf
fi

mkdir -p ~/.config/systemd/user
cp -r $dir/../.config/systemd/user/tmux.service ~/.config/systemd/user/
cp -r $dir/../.config/systemd/user/tmux-dev.service ~/.config/systemd/user/
systemctl --user daemon-reload
if [[ -x ~/.local/bin/tmux-dev.sh ]]; then
  systemctl --user enable --now tmux-dev.service
else
  systemctl --user enable --now tmux.service
fi

mkdir -p ~/.local/share/applications
cp $dir/../.local/share/applications/* ~/.local/share/applications/ 

$dir/swayncinstall.sh
$dir/waybarinstall.sh
$dir/wofiinstall.sh
