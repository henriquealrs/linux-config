#!/usr/bin/env bash
set -euo pipefail

sudo apt update
sudo apt install -y \
  i3 \
  polybar \
  dunst \
  fonts-powerline \
  rofi \
  feh \
  picom \
  rsync \
  maim \
  i3lock \
  imagemagick \
  xclip \
  playerctl \
  brightnessctl \
  pulseaudio-utils \
  alacritty \
  rustup \
  tmux \
  zsh \
  curl \
  x11-xserver-utils \
  xsel \
  git \
  lldb 

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

rsync -a --delete "$ROOT_DIR/../.config/i3/" "$HOME/.config/i3/"
rsync -a --delete "$ROOT_DIR/../.config/dunst/" "$HOME/.config/dunst/"
rsync -a --delete "$ROOT_DIR/../.config/polybar/" "$HOME/.config/polybar/"
rsync -a --delete "$ROOT_DIR/../.config/tmux/" "$HOME/.config/tmux/"

mkdir -p "$HOME/.config/i3/wallpapers"
rsync -a --delete "$ROOT_DIR/../wallpapers/" "$HOME/.config/i3/wallpapers/"

chmod +x "$HOME/.config/i3/random_wallpaper.sh"
chmod +x "$HOME/.config/i3/dynamic-monitor.sh"
chmod +x "$HOME/.config/i3/screenshot.sh"
chmod +x "$HOME/.config/polybar/launch.sh"

mkdir -p "$HOME/.local/bin"
install -m 755 "$ROOT_DIR/lock_screen.sh" "$HOME/.local/bin/lock_screen.sh"
install -m 644 "$ROOT_DIR/../.zshrc" "$HOME/.zshrc"
# curl -fsSL https://github.com/zen-browser/updates-server/raw/refs/heads/main/install.sh | sh

if [[ -d "$HOME/.oh-my-zsh/.git" ]]; then
  git -C "$HOME/.oh-my-zsh" pull --ff-only
else
  git clone https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
fi

mkdir -p "$HOME/.config/tmux/plugins"
if [[ -d "$HOME/.config/tmux/plugins/tpm/.git" ]]; then
  git -C "$HOME/.config/tmux/plugins/tpm" pull --ff-only
else
  git clone https://github.com/tmux-plugins/tpm "$HOME/.config/tmux/plugins/tpm"
fi

if [[ -x "$HOME/.config/tmux/plugins/tpm/bin/install_plugins" ]]; then
  TMUX_PLUGIN_MANAGER_PATH="$HOME/.config/tmux/plugins" \
    "$HOME/.config/tmux/plugins/tpm/bin/install_plugins" "$HOME/.config/tmux/tmux.conf"
fi


# Configure auto-display
cp "$ROOT_DIR/autodisplay_ubuntu.sh" "$HOME/.local/bin/"
mkdir -p "$HOME/.config/systemd/user"
cp -r "$ROOT_DIR/../.config/systemd/user/auto-display.service" "$HOME/.config/systemd/user/"
cp -r "$ROOT_DIR/../.config/systemd/user/auto-display.timer" "$HOME/.config/systemd/user/"
cp -r "$ROOT_DIR/../.config/systemd/user/random-wallpaper.service" "$HOME/.config/systemd/user/"
cp -r "$ROOT_DIR/../.config/systemd/user/random-wallpaper.timer" "$HOME/.config/systemd/user/"
cp -r "$ROOT_DIR/../.config/systemd/user/tmux.service" "$HOME/.config/systemd/user/"
cp -r "$ROOT_DIR/../.config/systemd/user/tmux-dev.service" "$HOME/.config/systemd/user/"
# Enable and Start
systemctl --user daemon-reexec
systemctl --user daemon-reload
systemctl --user enable --now auto-display.timer
systemctl --user enable --now random-wallpaper.timer
if [[ -x "$HOME/.local/bin/tmux-dev.sh" ]]; then
  systemctl --user enable --now tmux-dev.service
else
  systemctl --user enable --now tmux.service
fi
