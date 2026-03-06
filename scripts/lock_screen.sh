#!/usr/bin/env bash
set -euo pipefail

lock_image="/tmp/lockscreen-${USER}.png"

cleanup() {
  rm -f "$lock_image"
}

trap cleanup EXIT

if command -v grim >/dev/null 2>&1 && [[ "${XDG_SESSION_TYPE:-}" == "wayland" ]]; then
  grim "$lock_image"
elif command -v maim >/dev/null 2>&1; then
  maim "$lock_image"
elif command -v scrot >/dev/null 2>&1; then
  scrot "$lock_image"
else
  echo "No screenshot tool available (grim/maim/scrot)." >&2
  exit 1
fi

if command -v magick >/dev/null 2>&1; then
  magick "$lock_image" -filter Gaussian -resize 20% -resize 500% "$lock_image"
elif command -v convert >/dev/null 2>&1; then
  convert "$lock_image" -filter Gaussian -resize 20% -resize 500% "$lock_image"
fi

i3lock -n -i "$lock_image"
