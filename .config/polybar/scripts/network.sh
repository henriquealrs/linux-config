#!/usr/bin/env bash
set -euo pipefail

icon_wifi=""
icon_eth=""
icon_down=""

if command -v nmcli >/dev/null 2>&1; then
  if nmcli -t -f TYPE,STATE device | grep -q "^wifi:connected"; then
    printf "%s" "$icon_wifi"
    exit 0
  fi
  if nmcli -t -f TYPE,STATE device | grep -q "^ethernet:connected"; then
    printf "%s" "$icon_eth"
    exit 0
  fi
fi

printf "%s" "$icon_down"
