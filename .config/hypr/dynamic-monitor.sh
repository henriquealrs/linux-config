#!/usr/bin/env bash
set -euo pipefail

sleep 1

WALLPAPER_SCRIPT="$HOME/.config/hypr/random_wallpaper.sh"

log() {
  printf '[dynamic-monitor] %s\n' "$*"
}

read_lid_state() {
  awk '{print $2}' /proc/acpi/button/lid/*/state 2>/dev/null | head -n1 || true
}

find_monitor_path() {
  local name="$1"
  local path

  for path in /sys/class/drm/*-"${name}"; do
    [[ -e "$path" ]] || continue
    printf '%s\n' "$path"
    return 0
  done

  return 1
}

detect_internal_monitor() {
  local path

  if [[ -n "${INT:-}" ]] && path="$(find_monitor_path "$INT")"; then
    basename "$path" | sed 's/^card[0-9]\+-//'
    return 0
  fi

  for path in /sys/class/drm/*-eDP-* /sys/class/drm/*-LVDS-* /sys/class/drm/*-DSI-*; do
    [[ -e "$path" ]] || continue
    basename "$path" | sed 's/^card[0-9]\+-//'
    return 0
  done

  return 1
}

detect_external_monitor() {
  local path connector

  if [[ -n "${EXT:-}" ]] && path="$(find_monitor_path "$EXT")"; then
    basename "$path" | sed 's/^card[0-9]\+-//'
    return 0
  fi

  for path in /sys/class/drm/card*-*; do
    [[ -e "$path/status" ]] || continue
    connector="$(basename "$path" | sed 's/^card[0-9]\+-//')"

    case "$connector" in
      eDP-*|LVDS-*|DSI-*)
        continue
        ;;
    esac

    if [[ "$(cat "$path/status")" == "connected" ]]; then
      printf '%s\n' "$connector"
      return 0
    fi
  done

  for path in /sys/class/drm/card*-*; do
    [[ -e "$path/status" ]] || continue
    connector="$(basename "$path" | sed 's/^card[0-9]\+-//')"

    case "$connector" in
      eDP-*|LVDS-*|DSI-*)
        continue
        ;;
    esac

    printf '%s\n' "$connector"
    return 0
  done

  return 1
}

read_monitor_status() {
  local monitor="$1"
  local path

  if ! path="$(find_monitor_path "$monitor")"; then
    printf 'missing\n'
    return 1
  fi

  <"$path/status" tr -d '\n'
  printf '\n'
}

apply_monitor() {
  local monitor="$1"
  local state="$2"

  hyprctl keyword monitor "${monitor},${state}" >/dev/null
}

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

if ! command -v hyprctl >/dev/null 2>&1; then
  log "hyprctl not found; skipping monitor reconfiguration"
  exit 0
fi

lid_state="$(read_lid_state)"
lid_state="${lid_state:-open}"

INT_MONITOR="$(detect_internal_monitor || true)"
EXT_MONITOR="$(detect_external_monitor || true)"

if [[ -z "$INT_MONITOR" ]]; then
  log "Could not detect the internal monitor"
  exit 1
fi

hdmi_status="disconnected"
if [[ -n "$EXT_MONITOR" ]]; then
  hdmi_status="$(read_monitor_status "$EXT_MONITOR" || printf 'disconnected\n')"
fi

if [[ "$hdmi_status" == "connected" ]]; then
  if [[ "$lid_state" == "closed" ]]; then
    # Clamshell mode: external only
    apply_monitor "$INT_MONITOR" "disable"
    apply_monitor "$EXT_MONITOR" "preferred,auto,1"
    move_to "$EXT_MONITOR"
    refresh_wallpaper
  else
    # Dual‐monitor mode when lid open
    apply_monitor "$INT_MONITOR" "preferred,auto,1"
    apply_monitor "$EXT_MONITOR" "preferred,auto,1"
    # (optional) you could `move_to` each workspace to its default monitor here
    refresh_wallpaper
  fi
else
  # HDMI unplugged: only internal
  if [[ -n "$EXT_MONITOR" ]]; then
    apply_monitor "$EXT_MONITOR" "disable"
  fi
  apply_monitor "$INT_MONITOR" "preferred,auto,1"
  move_to "$INT_MONITOR"
  refresh_wallpaper
fi
