#!/usr/bin/env bash
set -euo pipefail

WALLPAPER_DIR="$HOME/.config/hypr/wallpapers"

start_daemon() {
    if command -v awww >/dev/null 2>&1; then
        if ! pgrep -x awww-daemon >/dev/null; then
            awww-daemon >/dev/null 2>&1 &
            sleep 1
        fi
        printf 'awww\n'
        return 0
    fi

    if command -v swww >/dev/null 2>&1; then
        if ! pgrep -x swww-daemon >/dev/null; then
            swww init >/dev/null 2>&1 || swww-daemon >/dev/null 2>&1 &
            sleep 1
        fi
        printf 'swww\n'
        return 0
    fi

    printf 'No supported wallpaper daemon found. Install awww or swww.\n' >&2
    return 1
}

if [[ ! -d "$WALLPAPER_DIR" ]]; then
    printf 'Wallpaper directory not found: %s\n' "$WALLPAPER_DIR" >&2
    exit 0
fi

wallpaper_cmd="$(start_daemon)" || exit 0
random_wallpaper="$(
    find "$WALLPAPER_DIR" -type f \( \
        -iname '*.jpg' -o \
        -iname '*.jpeg' -o \
        -iname '*.png' -o \
        -iname '*.webp' \
    \) | shuf -n 1
)"

if [[ -n "$random_wallpaper" ]]; then
    "$wallpaper_cmd" img "$random_wallpaper" --transition-type any --transition-duration 2 || {
        printf 'Failed to set wallpaper with %s: %s\n' "$wallpaper_cmd" "$random_wallpaper" >&2
        exit 0
    }
fi
