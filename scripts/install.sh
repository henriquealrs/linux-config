#!/bin/bash

temp=$( realpath "$0"  )
dir=$(dirname "$temp")
ROOT_DIR="$dir"
source "$ROOT_DIR/lib/shared_terminal.sh"

log() {
  printf '[install] %s\n' "$*"
}

install_codex_cli() {
  if ! command -v npm >/dev/null 2>&1; then
    log "Skipping Codex CLI install (npm not found)"
    return
  fi

  sudo npm install -g @openai/codex
  log "Installed Codex CLI"
}

# If problems refer to https://github.com/elifouts/Dotfiles.git
sudo pacman -Syu --noconfirm --needed

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

install_codex_cli


cp -r $dir/../.config/hypr ~/.config
cp -r $dir/../.config/waybar ~/.config
cp -r $dir/../.config/wofi ~/.config
cp -r $dir/../.config/ghostty ~/.config
cp -r $dir/../.config/swaync ~/.config
install -Dm644 "$dir/../.config/tmux/tmux.conf" "$HOME/.config/tmux/tmux.conf"
cp -r $dir/../wallpapers ~/
cp -r $dir/../toggle_nightlight.sh ~
install -m 644 "$dir/../.zshrc" ~/.zshrc
install -m 644 "$dir/../.zshenv" ~/.zshenv

mkdir -p ~/.local/bin
install -m 755 "$dir/lock_screen.sh" ~/.local/bin/lock_screen.sh

setup_oh_my_zsh
setup_tmux

mkdir -p ~/.local/share/applications
cp $dir/../.local/share/applications/* ~/.local/share/applications/ 

$dir/swayncinstall.sh
$dir/waybarinstall.sh
$dir/wofiinstall.sh
