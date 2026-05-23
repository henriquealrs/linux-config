#!/usr/bin/env bash
#
# Sync tracked Arch + Hyprland configs from the repository into the live $HOME tree.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$ROOT_DIR/lib/shared_terminal.sh"

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

sync_tmux_tree() {
  local rel=".config/tmux"
  local src="$ROOT_DIR/../$rel"
  local dest="$HOME/$rel"

  if [[ ! -d "$src" ]]; then
    log "Skipping $rel (not found in repo)"
    return
  fi

  mkdir -p "$dest"
  rsync -a --delete --exclude 'plugins/' "$src"/ "$dest"/
  log "Synced $rel -> $dest (preserved plugins/)"
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

copy_script() {
  local src_rel="$1"
  local dest_rel="$2"

  install -Dm755 "$ROOT_DIR/$src_rel" "$HOME/$dest_rel"
  log "Copied scripts/$src_rel -> $HOME/$dest_rel"
}

ensure_script_mode() {
  local rel="$1"
  local dest="$HOME/$rel"

  if [[ -f "$dest" ]]; then
    chmod 755 "$dest"
    log "Marked executable: $dest"
  fi
}

refresh_hyprland_monitors() {
  if [[ -z "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
    log "Skipping live Hyprland refresh (not running inside a Hyprland session)"
    return
  fi

  if ! command -v hyprctl >/dev/null 2>&1; then
    log "Skipping live Hyprland refresh (hyprctl not found)"
    return
  fi

  if [[ ! -x "$HOME/.config/hypr/dynamic-monitor.sh" ]]; then
    log "Skipping live Hyprland refresh (dynamic-monitor.sh is not executable)"
    return
  fi

  "$HOME/.config/hypr/dynamic-monitor.sh" || log "Live Hyprland monitor refresh failed"
}

require_tool rsync
require_tool install
require_tool git

sync_tree ".config/hypr"
sync_tree ".config/ghostty"
sync_tree ".config/waybar"
sync_tree ".config/wofi"
sync_tree ".config/swaync"
sync_tmux_tree
sync_tree ".local/share/applications"
sync_tree "wallpapers"

copy_file "toggle_nightlight.sh" 755
copy_file ".zshrc" 644
copy_file ".zshenv" 644
copy_script "lock_screen.sh" ".local/bin/lock_screen.sh"

ensure_script_mode ".config/hypr/dynamic-monitor.sh"
ensure_script_mode ".config/hypr/random_wallpaper.sh"
ensure_script_mode ".config/hypr/wallpaper.sh"

setup_oh_my_zsh
setup_tmux
refresh_hyprland_monitors

log "All tracked Arch/Hyprland configs applied."
