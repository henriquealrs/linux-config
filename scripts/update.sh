#!/usr/bin/env bash
#
# Sync tracked configs from the repository into the live $HOME tree.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log() {
  printf '[update] %s\n' "$*"
}

setup_tmux() {
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

  install -Dm644 "$ROOT_DIR/../.config/systemd/user/tmux.service" \
    "$HOME/.config/systemd/user/tmux.service"
  install -Dm644 "$ROOT_DIR/../.config/systemd/user/tmux-dev.service" \
    "$HOME/.config/systemd/user/tmux-dev.service"

  if ! command -v systemctl >/dev/null 2>&1; then
    log "Skipping tmux user units (systemctl not found)"
    return
  fi

  systemctl --user daemon-reload
  if [[ -x "$HOME/.local/bin/tmux-dev.sh" ]]; then
    systemctl --user enable --now tmux-dev.service
  else
    systemctl --user enable --now tmux.service
  fi
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
  rsync -a --delete "$src"/ "$dest"/
  log "Synced $rel -> $dest"
}

copy_file() {
  local rel="$1"
  local mode="${2:-644}"
  local src="$ROOT_DIR/../$rel"
  local dest="$HOME/$rel"

  if [[ ! -f "$src" ]]; then
    log "Skipping $rel (not found in repo)"
    return
  fi

  install -Dm"$mode" "$src" "$dest"
  log "Copied $rel -> $dest"
}

require_tool rsync
require_tool install
require_tool git

sync_tree ".config/hypr"
sync_tree ".config/ghostty"
sync_tree ".config/waybar"
sync_tree ".config/wofi"
sync_tree ".config/swaync"
sync_tree ".config/tmux"
sync_tree ".local/share/applications"
sync_tree "wallpapers"

copy_file "toggle_nightlight.sh" 755
copy_file ".zshrc" 644

if [[ -d "$HOME/.oh-my-zsh/.git" ]]; then
  git -C "$HOME/.oh-my-zsh" pull --ff-only
else
  git clone https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
fi

setup_tmux

log "All tracked configs applied."
