#!/usr/bin/env bash
set -euo pipefail

LOG_DIR="$HOME/wifi_logs"
PING_TARGET="8.8.8.8"
INTERVAL=5           # seconds between checks
FAIL_THRESHOLD=3      # consecutive ping failures
IFACE="${1:-wlan0}"   # allow override: ./wifi_monitor_v2.sh wlp2s0

mkdir -p "$LOG_DIR"
echo "[$(date)] Starting Wi-Fi monitor on $IFACE; logs -> $LOG_DIR"
fail_count=0

while true; do
  if ping -I "$IFACE" -c 1 -W 2 "$PING_TARGET" &>/dev/null; then
    echo "[$(date '+%H:%M:%S')] ✅ Online"
    fail_count=0
  else
    ((fail_count++))
    echo "[$(date '+%H:%M:%S')] ⚠️  Ping failed ($fail_count/$FAIL_THRESHOLD)"
    if (( fail_count >= FAIL_THRESHOLD )); then
      ts="$(date +'%Y%m%d_%H%M%S')"
      out="$LOG_DIR/wifi_fail_${ts}.log"
      echo "[$(date)] ❌ Drop detected — collecting logs to $out"

      {
        echo "===== WIFI FAILURE DETECTED ====="
        date
        echo "===== interface summary ====="
        ip addr show "$IFACE" || true
        iw dev "$IFACE" link || true
        echo "===== rfkill ====="
        rfkill list || true
        echo "===== nmcli dev/status ====="
        nmcli dev status || true
        nmcli -f GENERAL,IP4,IP6 device show "$IFACE" || true
        echo "===== NetworkManager (last 2 min) ====="
        journalctl -u NetworkManager --since "-2 minutes" --no-pager || true
        echo "===== kernel (last 2 min) ====="
        journalctl -k --since "-2 minutes" --no-pager || true
      } >> "$out"

      echo "Saved: $out"
      fail_count=0
    fi
  fi
  sleep "$INTERVAL"
done

