#!/usr/bin/env bash

setup_oh_my_zsh() {
  if [[ -d "$HOME/.oh-my-zsh/.git" ]]; then
    git -C "$HOME/.oh-my-zsh" pull --ff-only
  else
    git clone https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
  fi
}

setup_tmux() {
  local tmux_dir="$HOME/.config/tmux"
  local tpm_dir="$tmux_dir/plugins/tpm"
  local resurrect_dir="$HOME/.local/state/tmux/resurrect"

  mkdir -p "$tmux_dir/plugins" "$resurrect_dir"

  if [[ -d "$tpm_dir/.git" ]]; then
    git -C "$tpm_dir" pull --ff-only
  else
    git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
  fi

  if [[ ! -f "$tmux_dir/tmux.conf" ]]; then
    log "Skipping tmux plugin install (tmux.conf not found)"
  elif [[ -x "$tpm_dir/bin/install_plugins" ]]; then
    TMUX_PLUGIN_MANAGER_PATH="$tmux_dir/plugins" \
      "$tpm_dir/bin/install_plugins" "$tmux_dir/tmux.conf"
  fi

  install -Dm644 "$ROOT_DIR/../.config/systemd/user/tmux.service" \
    "$HOME/.config/systemd/user/tmux.service"
  install -Dm644 "$ROOT_DIR/../.config/systemd/user/tmux-dev.service" \
    "$HOME/.config/systemd/user/tmux-dev.service"

  if ! command -v systemctl >/dev/null 2>&1; then
    log "Skipping tmux user units (systemctl not found)"
    return
  fi

  systemctl --user daemon-reload
  systemctl --user reset-failed tmux.service tmux-dev.service >/dev/null 2>&1 || true
  if [[ -x "$HOME/.local/bin/tmux-dev.sh" ]]; then
    systemctl --user disable --now tmux.service >/dev/null 2>&1 || true
    systemctl --user enable --now tmux-dev.service
  else
    systemctl --user disable --now tmux-dev.service >/dev/null 2>&1 || true
    systemctl --user enable --now tmux.service
  fi
}
