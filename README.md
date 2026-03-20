# linux-config

Dotfiles and setup scripts for two desktop targets:

- Arch Linux + Hyprland
- Ubuntu + i3

The repository keeps shared terminal tooling such as tmux and zsh in one place, while window-manager and notification-bar configs stay platform-specific.

## Targets

### Arch Linux

The Arch path is driven by Hyprland and Wayland-oriented tooling:

- Hyprland in [`.config/hypr`](/home/henriquesilva/linux-config/.config/hypr)
- Waybar in [`.config/waybar`](/home/henriquesilva/linux-config/.config/waybar)
- Wofi in [`.config/wofi`](/home/henriquesilva/linux-config/.config/wofi)
- Sway Notification Center in [`.config/swaync`](/home/henriquesilva/linux-config/.config/swaync)

Use:

```bash
bash scripts/install.sh
```

This install script:

- installs core packages with `pacman` and `yay`
- copies Hyprland, Waybar, Wofi, Ghostty, SwayNC, tmux, wallpapers, and desktop entries into `$HOME`
- installs oh-my-zsh and copies the tracked [`.zshrc`](/home/henriquesilva/linux-config/.zshrc)
- installs tmux TPM plus the configured tmux plugins
- installs tmux user units from [`.config/systemd/user`](/home/henriquesilva/linux-config/.config/systemd/user)
- runs the Waybar, Wofi, and SwayNC theme/bootstrap helper scripts

To re-sync an existing Arch machine:

```bash
bash scripts/update.sh
```

`update.sh` reapplies tracked configs, wallpapers, desktop entries, `.zshrc`, oh-my-zsh, tmux plugins, and tmux user units.

### Ubuntu

The Ubuntu path is driven by i3 and X11-oriented tooling:

- i3 in [`.config/i3`](/home/henriquesilva/linux-config/.config/i3)
- Polybar in [`.config/polybar`](/home/henriquesilva/linux-config/.config/polybar)
- Dunst in [`.config/dunst`](/home/henriquesilva/linux-config/.config/dunst)

Use:

```bash
bash scripts/install_ubuntu.sh
```

This install script:

- installs the i3 desktop stack and supporting tools with `apt`
- installs `zsh` and `fonts-powerline` for the default shell and agnoster prompt
- syncs i3, Polybar, Dunst, tmux, and wallpaper assets into `$HOME`
- installs oh-my-zsh and copies the tracked [`.zshrc`](/home/henriquesilva/linux-config/.zshrc)
- installs tmux TPM plus the configured tmux plugins
- installs user units for auto-display, wallpaper rotation, and tmux

To re-sync an existing Ubuntu machine:

```bash
bash scripts/update_ubuntu.sh
```

`update_ubuntu.sh` reapplies tracked i3, Dunst, Polybar, tmux, wallpaper, and zsh config into `$HOME`, and updates or clones oh-my-zsh.

## Shared Terminal Setup

tmux and zsh are shared across both targets.

- tmux config lives in [`.config/tmux/tmux.conf`](/home/henriquesilva/linux-config/.config/tmux/tmux.conf)
- tmux defaults to `/usr/bin/zsh`
- zsh config lives in [`.zshrc`](/home/henriquesilva/linux-config/.zshrc)
- oh-my-zsh is configured with the `agnoster` theme
- enabled oh-my-zsh plugins are `git`, `bundler`, `dotenv`, `macos`, `rake`, and `rbenv`
- tmux plugin management uses TPM plus `tmux-resurrect`, `tmux-continuum`, `tmux-sensible`, and `tmux-yank`

The repository also ships user units for persistent tmux sessions:

- [`.config/systemd/user/tmux.service`](/home/henriquesilva/linux-config/.config/systemd/user/tmux.service)
- [`.config/systemd/user/tmux-dev.service`](/home/henriquesilva/linux-config/.config/systemd/user/tmux-dev.service)

## Notifications and Bars

The notification stack differs by platform:

- Arch Hyprland uses Waybar + SwayNC
- Ubuntu i3 uses Polybar + Dunst

Current notification shortcut behavior:

- Arch Hyprland uses `Super+Shift+N` to open the SwayNC control center
- Ubuntu i3 uses `Super+Shift+N` to pop Dunst notification history

## Repository Layout

- [`.config/`](/home/henriquesilva/linux-config/.config): application, WM, and user systemd config
- [`.local/share/applications/`](/home/henriquesilva/linux-config/.local/share/applications): desktop entry overrides copied into `$HOME`
- [`scripts/`](/home/henriquesilva/linux-config/scripts): install and update entrypoints plus helper bootstrap scripts
- [`maintenance/`](/home/henriquesilva/linux-config/maintenance): one-off maintenance and diagnostics
- [`wallpapers/`](/home/henriquesilva/linux-config/wallpapers): wallpaper assets used by both targets
- [`images/`](/home/henriquesilva/linux-config/images): additional static assets

## Validation

There is no automated test suite. For shell changes, validate syntax before running:

```bash
bash -n scripts/install.sh
bash -n scripts/update.sh
bash -n scripts/install_ubuntu.sh
bash -n scripts/update_ubuntu.sh
```

For runtime validation:

- run the relevant install or update script in a safe environment
- log into the target session and confirm bar, notifications, wallpaper, and lock-screen behavior
- start tmux and confirm TPM, resurrect, continuum, and zsh startup behave correctly
