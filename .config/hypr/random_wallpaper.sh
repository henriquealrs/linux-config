#!/bin/bash

WALLPAPER_DIR="$HOME/.config/hypr/wallpapers"

if ! pgrep -x swww-daemon > /dev/null; then
    swww init
    sleep 1
fi

random_wallpaper=$(find "$WALLPAPER_DIR" -type f \( -iname '*.jpg' -o -iname '*.png' \) | shuf -n 1)

if [[ -n "$random_wallpaper" ]]; then
    swww img "$random_wallpaper" --transition-type any --transition-duration 2
fi
