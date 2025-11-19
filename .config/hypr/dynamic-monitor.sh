#!/usr/bin/env bash
set -euo pipefail

sleep 1

INT="${INT:-eDP-1}"
EXT="${EXT:-HDMI-A-1}"
WALLPAPER_SCRIPT="$HOME/.config/hypr/random_wallpaper.sh"

# Read lid and HDMI
lid_state=$(awk '{print $2}' /proc/acpi/button/lid/*/state)
if [[ -r /sys/class/drm/card0-${EXT}/status ]]; then
  hdmi_status=$(<"/sys/class/drm/card0-${EXT}/status")
else
  hdmi_status="disconnected"
fi

# Helper: move all workspaces to a monitor
move_to() {
  local mon="$1"
  hyprctl workspaces \
    | awk '/^workspace/ {print $3}' \
    | xargs -r -I{} hyprctl dispatch moveworkspacetomonitor {} "$mon"
}

refresh_wallpaper() {
  if [[ -x "$WALLPAPER_SCRIPT" ]]; then
    "$WALLPAPER_SCRIPT" >/dev/null 2>&1 || true
  fi
}

if [[ "$hdmi_status" == "connected" ]]; then
  if [[ "$lid_state" == "closed" ]]; then
    # Clamshell mode: external only
    hyprctl keyword monitor "${INT},disable"
    hyprctl keyword monitor "${EXT},preferred,0x0,1"
    move_to "$EXT"
    refresh_wallpaper
  else
    # Dual‐monitor mode when lid open
    hyprctl keyword monitor "${INT},1920x1080,0x0,1"
    hyprctl keyword monitor "${EXT},1920x1080,-1920x0,1"
    # (optional) you could `move_to` each workspace to its default monitor here
    refresh_wallpaper
  fi
else
  # HDMI unplugged: only internal
  hyprctl keyword monitor "${EXT},disable"
  hyprctl keyword monitor "${INT},preferred,0x0,1"
  move_to "$INT"
  refresh_wallpaper
fi
