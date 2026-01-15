#!/usr/bin/env bash
set -euo pipefail

if command -v maim >/dev/null 2>&1; then
  maim -s | xclip -selection clipboard -t image/png
elif command -v import >/dev/null 2>&1; then
  import png:- | xclip -selection clipboard -t image/png
else
  notify-send "Screenshot" "Install maim or imagemagick for screenshots."
  exit 1
fi

notify-send "Screenshot" "Selection copied to clipboard."
