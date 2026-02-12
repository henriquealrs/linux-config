#!/usr/bin/env bash
set -euo pipefail

# Detect internal display (eDP or LVDS)
INTERNAL=$(xrandr --query \
  | awk '/ connected/ && ($1 ~ /^eDP/ || $1 ~ /^LVDS/) { print $1; exit }')

# Detect first connected external display
EXTERNAL=$(xrandr --query \
  | awk '/ connected/ && !($1 ~ /^eDP/ || $1 ~ /^LVDS/) { print $1; exit }')

echo "Internal: ${INTERNAL:-none}"
echo "External: ${EXTERNAL:-none}"

if [[ -z "${INTERNAL:-}" ]]; then
  echo "No internal display found." >&2
  exit 0
fi

if [[ -n "${EXTERNAL:-}" ]]; then
  echo "External monitor detected → switching to external only."
  xrandr --output "$INTERNAL" --off
  xrandr --output "$EXTERNAL" --auto --primary
else
  echo "No external monitor → switching to internal only."
  xrandr --output "$INTERNAL" --auto --primary
fi

