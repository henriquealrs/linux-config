#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log() {
  printf '[update-ubuntu] %s\n' "$*"
}

sync_tree() {
  local rel="$1"
  local src="$ROOT_DIR/../$rel"
  local dest="$HOME/$rel"

  if [[ ! -d "$src" ]]; then
    log "Skipping $rel (not found in repo)"
    return
  fi

  mkdir -p "$dest"
  rsync -a --delete "$src/" "$dest/"
  log "Synced $rel -> $dest"
}

sync_tree ".config/i3"
sync_tree ".config/dunst"
sync_tree ".config/polybar"
sync_tree ".config/tmux"

mkdir -p "$HOME/.config/i3/wallpapers"
rsync -a --delete "$ROOT_DIR/../wallpapers/" "$HOME/.config/i3/wallpapers/"
log "Synced wallpapers -> $HOME/.config/i3/wallpapers"

chmod +x "$HOME/.config/i3/random_wallpaper.sh"
chmod +x "$HOME/.config/i3/dynamic-monitor.sh"
chmod +x "$HOME/.config/i3/screenshot.sh"
chmod +x "$HOME/.config/polybar/launch.sh"

install -Dm644 "$ROOT_DIR/../.zshrc" "$HOME/.zshrc"
install -Dm644 "$ROOT_DIR/../.zshenv" "$HOME/.zshenv"
if [[ -d "$HOME/.oh-my-zsh/.git" ]]; then
  git -C "$HOME/.oh-my-zsh" pull --ff-only
else
  git clone https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
fi

log "Ubuntu i3 configs applied."
