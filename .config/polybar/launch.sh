#!/usr/bin/env bash
set -euo pipefail

if pgrep -x polybar >/dev/null; then
  pkill -x polybar
fi

while pgrep -x polybar >/dev/null; do
  sleep 0.2
done

polybar main &
