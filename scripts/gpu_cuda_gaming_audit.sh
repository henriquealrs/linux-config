#!/usr/bin/env bash
# GPU / CUDA / Gaming / Python-C++ audit (read-only)
set -u
LOG="$HOME/arch_gpu_cuda_gaming_audit_$(date +%Y%m%d_%H%M%S).txt"

section() { printf "\n==== %s ====\n" "$1"; }
have() { command -v "$1" >/dev/null 2>&1; }

{
  section "System";
  uname -a
  if have lsb_release; then lsb_release -a 2>/dev/null; fi
  [ -r /etc/os-release ] && cat /etc/os-release

  section "Kernel & Headers";
  uname -r
  KVER="$(uname -r)"
  if [ -d "/usr/lib/modules/$KVER/build" ]; then
    echo "Headers: PRESENT for $KVER"
  else
    echo "Headers: MISSING for $KVER"
  fi
  echo
  echo "Installed kernels (dirs in /usr/lib/modules):"
  ls -1 /usr/lib/modules 2>/dev/null || echo "/usr/lib/modules not found"
  echo
  echo "Header presence per kernel:"
  for kv in /usr/lib/modules/*; do
    [ -d "$kv" ] || continue
    printf "  %s: " "$(basename "$kv")"
    [ -e "$kv/build" ] && echo "headers PRESENT" || echo "headers MISSING"
  done

  section "GPU / NVIDIA";
  lspci | grep -E "VGA|3D|Display" || echo "No VGA/3D controllers found?"
  if have nvidia-smi; then nvidia-smi || true; else echo "nvidia-smi: NOT INSTALLED"; fi
  if have modinfo; then
    modinfo nvidia 2>/dev/null | awk -F': *' '/^version:/{print "nvidia.ko version: " $2}'
  fi

  section "DKMS";
  if have dkms; then dkms status || true; else echo "dkms: NOT INSTALLED (fine if using repo nvidia)"; fi

  section "CUDA Toolkit";
  if have nvcc; then nvcc --version; else echo "nvcc: NOT FOUND"; fi
  echo "CUDA libs via ldconfig:"
  if have ldconfig; then
    ldconfig -p 2>/dev/null | grep -E "libcuda\.|libcudart|libcublas|libcusparse|libcudnn" || echo "No CUDA libs visible to ldconfig"
  else
    echo "ldconfig not available"
  fi

  section "OpenCL (optional)";
  if have clinfo; then clinfo | sed -n '1,80p'; else echo "clinfo: NOT INSTALLED"; fi

  section "Python";
  if have python; then
    python -V
    python -c 'import sys; print("python exe:", sys.executable)' 2>/dev/null || true
    python -c "import torch, platform; print('torch:', getattr(torch,'__version__',None), 'cuda:', getattr(torch.version,'cuda',None), 'is_available:', getattr(torch.cuda,'is_available',lambda:None)())" 2>/dev/null || echo "PyTorch: NOT INSTALLED or import failed"
    python -c "import tensorflow as tf; print('tensorflow:', tf.__version__, 'gpus:', tf.config.list_physical_devices('GPU'))" 2>/dev/null || echo "TensorFlow: NOT INSTALLED or import failed"
  else
    echo "python: NOT INSTALLED"
  fi
  if have uv; then uv --version; else echo "uv: NOT INSTALLED"; fi
  if have pip; then pip --version; fi

  section "C/C++ Toolchain";
  have gcc   && gcc --version   | head -n1 || echo "gcc: NOT INSTALLED"
  have g++   && g++ --version   | head -n1 || echo "g++: NOT INSTALLED"
  have clang && clang --version | head -n1 || echo "clang: NOT INSTALLED"
  have cmake && cmake --version | head -n1 || echo "cmake: NOT INSTALLED"
  have make  && make --version  | head -n1 || echo "make: NOT INSTALLED"
  have ninja && ninja --version || echo "ninja: NOT INSTALLED"

  section "Graphics APIs (may require packages & a running session)";
  if have glxinfo; then timeout 5 glxinfo -B 2>/dev/null | sed -n '1,60p' || echo "glxinfo timed out / no X"; else echo "glxinfo: NOT INSTALLED"; fi
  if have vulkaninfo; then timeout 8 vulkaninfo --summary 2>/dev/null || echo "vulkaninfo failed (no ICD?)"; else echo "vulkaninfo: NOT INSTALLED"; fi

  section "Session / Compositor";
  echo "XDG_SESSION_TYPE=${XDG_SESSION_TYPE:-unset}"
  ps -e | grep -E "Xorg|wayland|Hyprland|gnome-shell|kwin|sway|wlroots" || echo "No common compositor processes found (OK in TTY)"

  section "Kernel cmdline & modeset";
  [ -r /proc/cmdline ] && cat /proc/cmdline || echo "/proc/cmdline not readable"
  printf "nvidia_drm.modeset parameter: "
  [ -r /sys/module/nvidia_drm/parameters/modeset ] && cat /sys/module/nvidia_drm/parameters/modeset || echo "unavailable"

  section "Pacman multilib";
  if [ -r /etc/pacman.conf ]; then
    awk '
      /^\[multilib\]/ {flag=1; print; next}
      flag==1 {print; exit}
    ' /etc/pacman.conf
    echo
    if grep -q "^\[multilib\]" /etc/pacman.conf && ! grep -q "^\s*#\s*\[multilib\]" /etc/pacman.conf; then
      echo "multilib: SECTION PRESENT (ensure Include = /etc/pacman.d/mirrorlist under it)"
    else
      echo "multilib: NOT ENABLED (or commented)"
    fi
  else
    echo "/etc/pacman.conf not found"
  fi

  section "Gaming / GPU packages (pacman)";
  if have pacman; then
    pacman -Q | grep -E '^(nvidia(-dkms)?|nvidia-utils|nvidia-settings|opencl-nvidia|lib32-nvidia-utils|cuda|cudnn|cublas|cudnn|vulkan-icd-loader|lib32-vulkan-icd-loader|vulkan-tools|mesa|egl-wayland|steam|gamemode|mangohud|wine|lutris|dxvk|vkd3d|vkd3d-proton)\b' || echo "No matching packages found"
  else
    echo "pacman not found"
  fi

  section "Display outputs (quick probe)";
  if have xrandr; then xrandr --listmonitors 2>/dev/null || echo "xrandr failed (no X?)"; else echo "xrandr: NOT INSTALLED"; fi
  if have hyprctl; then hyprctl monitors 2>/dev/null || true; fi

} | tee "$LOG"

echo
echo "Report written to: $LOG"
EOF

chmod +x gpu_cuda_gaming_audit.sh
echo "Saved gpu_cuda_gaming_audit.sh. Run it with: ./gpu_cuda_gaming_audit.sh"

