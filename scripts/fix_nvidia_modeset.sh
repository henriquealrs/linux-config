#!/usr/bin/env bash
set -euo pipefail

echo "==> Fixing NVIDIA early KMS (modeset=1) the boring, reliable way…"

# 0) Sanity
command -v mkinitcpio >/dev/null || { echo "mkinitcpio not found"; exit 1; }
[ -r /etc/mkinitcpio.conf ] || { echo "/etc/mkinitcpio.conf missing"; exit 1; }
[ -r /etc/default/grub ] || { echo "/etc/default/grub missing"; exit 1; }

# 1) Blacklist nouveau (so it never races NVIDIA)
sudo install -Dm644 /dev/stdin /etc/modprobe.d/blacklist-nouveau.conf <<'EOF'
blacklist nouveau
options nouveau modeset=0
EOF

# 2) Ensure persistent modprobe option for nvidia-drm
sudo install -Dm644 /dev/stdin /etc/modprobe.d/nvidia-drm.conf <<'EOF'
options nvidia-drm modeset=1
EOF

# 3) Inject NVIDIA modules into initramfs (early load) and add kms hook
conf=/etc/mkinitcpio.conf
# Add/merge MODULES entries
mods="nvidia nvidia_modeset nvidia_uvm nvidia_drm"
current_mods="$(awk -F= '/^MODULES=/{print $2}' "$conf" | tr -d '()' || true)"
for m in $mods; do
  if ! grep -Eq "^\s*MODULES=.*\b${m}\b" "$conf"; then
    sudo sed -i "s/^MODULES=(/MODULES=(${m} /" "$conf"
  fi
done

# Ensure kms hook exists (helps early modeset on mkinitcpio)
if grep -q '^HOOKS=' "$conf"; then
  if ! grep -Eq '^HOOKS=.*\bkms\b' "$conf"; then
    # insert kms right after modconf if present, else prepend
    if grep -Eq '^HOOKS=.*\bmodconf\b' "$conf"; then
      sudo sed -i 's/\(HOOKS=.*modconf\) /\1 kms /' "$conf"
    else
      sudo sed -i 's/^HOOKS=(/HOOKS=(kms /' "$conf"
    fi
  fi
fi

# 4) Make sure kernel cmdline has nvidia-drm.modeset=1 (dedupe if needed)
grub=/etc/default/grub
if ! grep -q 'nvidia-drm.modeset=1' "$grub"; then
  sudo sed -i 's/^\(GRUB_CMDLINE_LINUX_DEFAULT="[^"]*\)"/\1 nvidia-drm.modeset=1"/' "$grub"
else
  # remove accidental duplicates
  sudo sed -i 's/\(nvidia-drm\.modeset=1\)\( \1\)\+/\1/g' "$grub"
fi

# 5) Rebuild initramfs for all installed kernels
echo "==> Rebuilding initramfs (mkinitcpio -P)…"
sudo mkinitcpio -P

# 6) Regenerate GRUB
echo "==> Regenerating GRUB config…"
if [ -d /boot/grub ]; then
  sudo grub-mkconfig -o /boot/grub/grub.cfg
else
  echo "WARN: /boot/grub not found; make sure GRUB is installed properly."
fi

# 7) Show what will be active after reboot
echo "==> Current kernel cmdline:"
cat /proc/cmdline || true

echo "==> NVIDIA module parms (pre-reboot check):"
modinfo nvidia_drm 2>/dev/null | awk -F: '/^parm:/ {print $0}' || echo "modinfo failed (module not loaded yet)"

echo "==> If you want to verify immediately without reboot (TTY only):"
cat <<'EOT'
  1) Switch to TTY and stop display manager:
     sudo systemctl isolate multi-user.target

  2) Reload NVIDIA stack with modeset=1:
     sudo modprobe -r nvidia_drm nvidia_modeset nvidia_uvm nvidia || true
     sudo modprobe nvidia
     sudo modprobe nvidia_uvm
     sudo modprobe nvidia_modeset
     sudo modprobe nvidia_drm modeset=1

  3) Start your DM again:
     sudo systemctl start gdm    # or sddm/ly/lightdm

  4) Then check:
     cat /sys/module/nvidia_drm/parameters/modeset   # should print Y
EOT

echo "==> Done. Reboot now for the clean path. After reboot, run:"
echo "    cat /sys/module/nvidia_drm/parameters/modeset   # expect: Y"

