#!/usr/bin/env bash
set -euo pipefail

icon_on="󰂯"
icon_off="󰂲"

if ! command -v bluetoothctl >/dev/null 2>&1; then
  printf "%s" "$icon_off"
  exit 0
fi

if bluetoothctl show 2>/dev/null | grep -q "Powered: yes"; then
  printf "%s" "$icon_on"
  exit 0
fi

printf "%s" "$icon_off"
