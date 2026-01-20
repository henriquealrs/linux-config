#!/usr/bin/env bash
set -euo pipefail

sudo apt update
sudo apt install -y \
  i3 \
  polybar \
  dunst \
  rofi \
  feh \
  picom \
  rsync \
  maim \
  xclip \
  playerctl \
  brightnessctl \
  pulseaudio-utils \
  alacritty \
  rustup \
  tmux \
  curl \
  x11-xserver-utils 

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

rsync -a --delete "$ROOT_DIR/../.config/i3/" "$HOME/.config/i3/"
rsync -a --delete "$ROOT_DIR/../.config/dunst/" "$HOME/.config/dunst/"
rsync -a --delete "$ROOT_DIR/../.config/polybar/" "$HOME/.config/polybar/"

mkdir -p "$HOME/.config/i3/wallpapers"
rsync -a --delete "$ROOT_DIR/../wallpapers/" "$HOME/.config/i3/wallpapers/"

chmod +x "$HOME/.config/i3/random_wallpaper.sh"
chmod +x "$HOME/.config/i3/dynamic-monitor.sh"
chmod +x "$HOME/.config/i3/screenshot.sh"
chmod +x "$HOME/.config/polybar/launch.sh"

mv "$HOME/.config/i3/random_wallpaper.sh" "$HOME/.local/bin/"
# curl -fsSL https://github.com/zen-browser/updates-server/raw/refs/heads/main/install.sh | sh


# Configure auto-display
mkdir -p "$HOME/.local/bin"
cp "$ROOT_DIR/autodisplay_ubuntu.sh" "$HOME/.local/bin/"
mkdir -p "$HOME/.config/systemd/user"
cp -r "$ROOT_DIR/../.config/systemd/user/auto-display.service" "$HOME/.config/systemd/user/"
cp -r "$ROOT_DIR/../.config/systemd/user/auto-display.timer" "$HOME/.config/systemd/user/"
cp -r "$ROOT_DIR/../.config/systemd/user/random-wallpaper.service" "$HOME/.config/systemd/user/"
cp -r "$ROOT_DIR/../.config/systemd/user/random-wallpaper.timer" "$HOME/.config/systemd/user/"
cp -r "$ROOT_DIR/../.config/systemd/user/tmux*" "$HOME/.config/systemd/user/"
# Enable and Start
systemctl --user daemon-reexec
systemctl --user daemon-reload
systemctl --user enable --now auto-display.timer
systemctl --user enable --now random-wallpaper.timer
systemctl --user enable --now tmux-dev.service

