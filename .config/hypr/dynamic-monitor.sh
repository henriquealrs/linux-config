#!/usr/bin/env bash

sleep 3

INT="eDP-1"
EXT="HDMI-A-1"

# Read lid and HDMI
lid_state=$(awk '{print $2}' /proc/acpi/button/lid/*/state)
hdmi_status=$(cat /sys/class/drm/card0-${EXT}/status)

# Helper: move all workspaces to a monitor
move_to() {
  local mon="$1"
  hyprctl workspaces \
    | awk '/^workspace/ {print $3}' \
    | xargs -r -I{} hyprctl dispatch moveworkspacetomonitor {} "$mon"
}

if [[ "$hdmi_status" == "connected" ]]; then
  if [[ "$lid_state" == "closed" ]]; then
    # Clamshell mode: external only
    hyprctl keyword monitor "${INT},disable"            # turn off internal :contentReference[oaicite:3]{index=3}
    hyprctl keyword monitor "${EXT},preferred,0x0,1"    # enable external
    move_to "$EXT"
  else
    # Dual‐monitor mode when lid open
    hyprctl keyword monitor "${INT},1920x1080,0x0,1"    # restore internal layout :contentReference[oaicite:4]{index=4}
    hyprctl keyword monitor "${EXT},1920x1080,-1920x0,1" # restore external layout
    # (optional) you could `move_to` each workspace to its default monitor here
  fi
else
  # HDMI unplugged: only internal
  hyprctl keyword monitor "${EXT},disable"
  hyprctl keyword monitor "${INT},preferred,0x0,1"
  move_to "$INT"
fi
