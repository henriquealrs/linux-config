#!/usr/bin/env bash
set -euo pipefail

sleep 1

INT="${INT:-eDP-1}"
EXT="${EXT:-HDMI-1}"
WALLPAPER_SCRIPT="$HOME/.config/i3/random_wallpaper.sh"

lid_state=$(awk '{print $2}' /proc/acpi/button/lid/*/state 2>/dev/null || echo open)

if xrandr | grep -q "^${EXT} connected"; then
  if [[ "$lid_state" == "closed" ]]; then
    xrandr --output "$INT" --off --output "$EXT" --auto --primary
  else
    xrandr --output "$INT" --auto --primary --output "$EXT" --auto --left-of "$INT"
  fi
else
  xrandr --output "$EXT" --off --output "$INT" --auto --primary
fi

if [[ -x "$WALLPAPER_SCRIPT" ]]; then
  "$WALLPAPER_SCRIPT" >/dev/null 2>&1 || true
fi

# Move all workspaces if jq is available.
if command -v jq >/dev/null 2>&1; then
  target_output="$INT"
  if xrandr | grep -q "^${EXT} connected"; then
    target_output="$EXT"
  fi
  i3-msg -t get_workspaces \
    | jq -r '.[].name' \
    | while read -r ws; do
        i3-msg "workspace ${ws}; move workspace to output ${target_output}" >/dev/null
      done
fi
