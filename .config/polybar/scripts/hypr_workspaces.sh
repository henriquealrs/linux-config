#!/usr/bin/env bash
set -euo pipefail

total=5

color_active="#5f87af"
color_default="#d0d0d0"
color_empty="#6b6b6b"

if [ -f "$HOME/.cache/wal/colors.sh" ]; then
  # shellcheck source=/dev/null
  source "$HOME/.cache/wal/colors.sh"
  color_active="${color9:-$color_active}"
  color_default="${color7:-$color_default}"
  color_empty="${color8:-$color_empty}"
fi

if ! command -v hyprctl >/dev/null 2>&1; then
  printf "%s" "    "
  exit 0
fi

if ! command -v jq >/dev/null 2>&1; then
  printf "%s" "    "
  exit 0
fi

active_id="$(hyprctl -j activeworkspace | jq -r '.id' 2>/dev/null || true)"
mapfile -t existing_ids < <(hyprctl -j workspaces | jq -r '.[].id' 2>/dev/null || true)

has_workspace() {
  local id="$1"
  for existing in "${existing_ids[@]}"; do
    if [ "$existing" = "$id" ]; then
      return 0
    fi
  done
  return 1
}

output=""
for i in $(seq 1 "$total"); do
  if [ "$i" = "${active_id:-}" ]; then
    color="$color_active"
  elif has_workspace "$i"; then
    color="$color_default"
  else
    color="$color_empty"
  fi

  output+="%{A1:hyprctl dispatch workspace $i:}%{F$color}%{F-}%{A}"
  if [ "$i" -lt "$total" ]; then
    output+=" "
  fi
done

printf "%s" "$output"
