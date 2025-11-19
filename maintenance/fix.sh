#!/bin/bash

tee /etc/modprobe.d/iwlwifi.conf >/dev/null <<'EOF'
options iwlwifi power_save=0 disable_11ax=1
EOF
# reload the module (this drops Wi-Fi for a moment)
modprobe -r iwlmvm iwlwifi && sudo modprobe iwlwifi

# disable NM wifi powersave
mkdir -p /etc/NetworkManager/conf.d
tee /etc/NetworkManager/conf.d/wifi-powersave.conf >/dev/null <<'EOF'
[connection]
wifi.powersave = 2
EOF

# disable scan MAC randomization
tee /etc/NetworkManager/conf.d/disable-mac-randomization.conf >/dev/null <<'EOF'
[device]
wifi.scan-rand-mac-address=no
EOF

systemctl restart NetworkManager

# try wpa_supplicant
systemctl disable --now iwd 2>/dev/null
rm -f /etc/NetworkManager/conf.d/10-iwd.conf 2>/dev/null
systemctl restart NetworkManager

