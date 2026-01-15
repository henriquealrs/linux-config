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

curl -fsSL https://github.com/zen-browser/updates-server/raw/refs/heads/main/install.sh | sh
