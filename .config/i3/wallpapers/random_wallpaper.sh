#!/usr/bin/env bash
set -euo pipefail

WALLPAPER_DIR="$HOME/.config/i3/wallpapers"

if [[ ! -d "$WALLPAPER_DIR" ]]; then
  mkdir -p "$WALLPAPER_DIR"
fi

wallpaper=$(find "$WALLPAPER_DIR" -type f \( -iname '*.jpg' -o -iname '*.png' \) | shuf -n 1 || true)

if [[ -n "${wallpaper}" ]]; then
  feh --bg-scale "$wallpaper"
fi
