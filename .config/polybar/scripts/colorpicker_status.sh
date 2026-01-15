#!/usr/bin/env bash
set -euo pipefail

icon=""
colors_file="$HOME/.cache/colorpicker/colors"

color=""
if [ -f "$colors_file" ]; then
  color="$(head -n 1 "$colors_file" | tr -d '\n')"
fi

if [ -n "$color" ]; then
  printf "%%{F%s}%s%%{F-}" "$color" "$icon"
else
  printf "%s" "$icon"
fi
