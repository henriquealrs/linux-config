#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$ROOT_DIR/lib/shared_terminal.sh"

log() {
  printf '[update-ubuntu] %s\n' "$*"
}

require_tool() {
  if ! command -v "$1" >/dev/null 2>&1; then
    log "Missing required tool: $1"
    exit 1
  fi
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

sync_tmux_tree() {
  local rel=".config/tmux"
  local src="$ROOT_DIR/../$rel"
  local dest="$HOME/$rel"

  if [[ ! -d "$src" ]]; then
    log "Skipping $rel (not found in repo)"
    return
  fi

  mkdir -p "$dest"
  rsync -a --delete --exclude 'plugins/' "$src/" "$dest/"
  log "Synced $rel -> $dest (preserved plugins/)"
}

copy_script() {
  local src_rel="$1"
  local dest_rel="$2"

  install -Dm755 "$ROOT_DIR/$src_rel" "$HOME/$dest_rel"
  log "Copied scripts/$src_rel -> $HOME/$dest_rel"
}

require_tool rsync
require_tool install
require_tool git

sync_tree ".config/i3"
sync_tree ".config/dunst"
sync_tree ".config/polybar"
sync_tmux_tree

mkdir -p "$HOME/.config/i3/wallpapers"
rsync -a --delete "$ROOT_DIR/../wallpapers/" "$HOME/.config/i3/wallpapers/"
log "Synced wallpapers -> $HOME/.config/i3/wallpapers"

chmod +x "$HOME/.config/i3/random_wallpaper.sh"
chmod +x "$HOME/.config/i3/dynamic-monitor.sh"
chmod +x "$HOME/.config/i3/screenshot.sh"
chmod +x "$HOME/.config/polybar/launch.sh"

copy_script "lock_screen.sh" ".local/bin/lock_screen.sh"
install -Dm644 "$ROOT_DIR/../.zshrc" "$HOME/.zshrc"
install -Dm644 "$ROOT_DIR/../.zshenv" "$HOME/.zshenv"
setup_oh_my_zsh
setup_tmux

log "Ubuntu i3 configs applied."
