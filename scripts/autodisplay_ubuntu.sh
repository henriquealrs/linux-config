#!/usr/bin/env bash
set -euo pipefail

# Get internal display (prefer eDP, fallback to LVDS)
# INTERNAL=$(xrandr --query \
#   | awk '/ connected/ && ($1 ~ /^eDP/ || $1 ~ /^LVDS/) { print $1; exit }')
INTERNAL=eDP

# Get first connected HDMI output
HDMI=$(xrandr --query \
  | awk '/ connected/ && $1 ~ /^HDMI/ { print $1; exit }')

# Safety checks (because xrandr can lie at login)
if [[ -z "${INTERNAL:-}" ]]; then
  echo "No internal display found" >&2
  exit 0
fi

if [[ -n "${HDMI:-}" ]]; then
  # HDMI connected → external only
  xrandr \
    --output "$INTERNAL" --off
  xrandr --output "$HDMI" --auto 
else
  # No HDMI → internal only
  xrandr \
    --output "$INTERNAL" --auto 
fi

