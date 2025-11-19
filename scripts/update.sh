#!/usr/bin/env bash
#
# Sync tracked configs from the repository into the live $HOME tree.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log() {
  printf '[update] %s\n' "$*"
}

require_tool() {
  if ! command -v "$1" >/dev/null 2>&1; then
    log "Missing required tool: $1"
    exit 1
  fi
}

sync_tree() {
  local rel="$1"
  local src="$ROOT_DIR/$rel"
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
  local src="$ROOT_DIR/$rel"
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

sync_tree ".config/hypr"
sync_tree ".config/ghostty"
sync_tree ".config/waybar"
sync_tree ".config/wofi"
sync_tree ".config/swaync"
sync_tree ".local/share/applications"
sync_tree "wallpapers"

copy_file "toggle_nightlight.sh" 755

log "All tracked configs applied."
