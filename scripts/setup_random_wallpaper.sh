#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
echo $SCRIPT_DIR

set -e

echo "🔧 Setting up random wallpaper rotation for Hyprland..."

# Install swww if not present
if ! command -v swww &> /dev/null; then
    echo "📦 Installing swww..."
    if command -v yay &> /dev/null; then
        yay -S --noconfirm --needed swww
    elif command -v paru &> /dev/null; then
        paru -S --noconfirm --neededswww
    else
        echo "❌ AUR helper (yay or paru) not found. Install swww manually."
        exit 1
    fi
fi

# Wallpaper directory
WALLPAPER_DIR="$HOME/.config/hypr/wallpapers"
mkdir -p $WALLPAPER_DIR
cp -r $SCRIPT_DIR/../wallpapers $WALLPAPER_DIR

# Script directory
SCRIPT_DIR="$HOME/.config/hypr"
mkdir -p "$SCRIPT_DIR"

# Random wallpaper script
RANDOM_SCRIPT="$SCRIPT_DIR/random_wallpaper.sh"
cat > "$RANDOM_SCRIPT" <<'EOF'
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
EOF

chmod +x "$RANDOM_SCRIPT"

# Create systemd service
mkdir -p "$HOME/.config/systemd/user"

SERVICE_FILE="$HOME/.config/systemd/user/hypr_wallpaper.service"
TIMER_FILE="$HOME/.config/systemd/user/hypr_wallpaper.timer"

cat > "$SERVICE_FILE" <<EOF
[Unit]
Description=Change Hyprland wallpaper

[Service]
ExecStart=$RANDOM_SCRIPT
EOF

cat > "$TIMER_FILE" <<EOF
[Unit]
Description=Change wallpaper every 30 minutes

[Timer]
OnBootSec=2min
OnUnitActiveSec=10min
Persistent=true

[Install]
WantedBy=default.target
EOF

# Enable and start timer
systemctl --user daemon-reexec
systemctl --user enable --now hypr_wallpaper.timer

# Update Hyprland config
HYPR_CONFIG="$HOME/.config/hypr/hyprland.conf"
if ! grep -q "$RANDOM_SCRIPT" "$HYPR_CONFIG"; then
    echo "exec-once = $RANDOM_SCRIPT" >> "$HYPR_CONFIG"
fi

echo "✅ Done. Place some wallpapers in: $WALLPAPER_DIR"
echo "🖼 Wallpaper will change every 30 minutes."
