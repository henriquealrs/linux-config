#!/bin/bash
set -e

echo "🔧 Updating GRUB kernel parameters for NVIDIA DRM KMS..."

# 1. Update GRUB CMDLINE
sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="/GRUB_CMDLINE_LINUX_DEFAULT="nvidia-drm.modeset=1 /' /etc/default/grub

echo "✅ GRUB_CMDLINE updated."

# 2. Update mkinitcpio to load NVIDIA modules early
echo "🔧 Ensuring mkinitcpio loads NVIDIA modules..."
sudo sed -i 's/^MODULES=.*/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf

echo "✅ mkinitcpio updated."

# 3. Regenerate initramfs and GRUB config
echo "🔄 Rebuilding initramfs and GRUB config..."
sudo mkinitcpio -P
sudo grub-mkconfig -o /boot/grub/grub.cfg

# 4. Inject NVIDIA Wayland env vars
echo "🔧 Setting NVIDIA Wayland environment variables..."
sudo mkdir -p /etc/environment.d/
cat <<EOF | sudo tee /etc/environment.d/90-nvidia-hyprland.conf > /dev/null
GBM_BACKEND=nvidia-drm
__GLX_VENDOR_LIBRARY_NAME=nvidia
__NV_PRIME_RENDER_OFFLOAD=1
LIBVA_DRIVER_NAME=nvidia
WLR_NO_HARDWARE_CURSORS=1
EOF

echo "✅ Environment variables set."

echo "✅ All done! Please reboot your system now."
