# Repository Guidelines

## Project Structure & Platform Split
This repo manages two desktop targets:

- Arch Linux + Hyprland through [`scripts/install.sh`](/home/henriquesilva/linux-config/scripts/install.sh) and [`scripts/update.sh`](/home/henriquesilva/linux-config/scripts/update.sh)
- Ubuntu + i3 through [`scripts/install_ubuntu.sh`](/home/henriquesilva/linux-config/scripts/install_ubuntu.sh) and [`scripts/update_ubuntu.sh`](/home/henriquesilva/linux-config/scripts/update_ubuntu.sh)

Primary config areas:

- [`.config/hypr`](/home/henriquesilva/linux-config/.config/hypr), [`.config/waybar`](/home/henriquesilva/linux-config/.config/waybar), [`.config/wofi`](/home/henriquesilva/linux-config/.config/wofi), and [`.config/swaync`](/home/henriquesilva/linux-config/.config/swaync) are Arch/Hyprland-specific
- [`.config/i3`](/home/henriquesilva/linux-config/.config/i3), [`.config/polybar`](/home/henriquesilva/linux-config/.config/polybar), and [`.config/dunst`](/home/henriquesilva/linux-config/.config/dunst) are Ubuntu/i3-specific
- [`.config/tmux`](/home/henriquesilva/linux-config/.config/tmux), [`.config/systemd/user`](/home/henriquesilva/linux-config/.config/systemd/user), [`.zshrc`](/home/henriquesilva/linux-config/.zshrc), [`wallpapers/`](/home/henriquesilva/linux-config/wallpapers), and [`.local/share/applications/`](/home/henriquesilva/linux-config/.local/share/applications) are shared or cross-cutting

When changing behavior, keep the platform split explicit. Do not assume Hyprland-only anymore.

## Key Commands
There is no build step. The important entrypoints are:

- `bash scripts/install.sh`: full Arch + Hyprland machine bootstrap
- `bash scripts/update.sh`: sync Arch configs into `$HOME` and reapply shared tmux/zsh state
- `bash scripts/install_ubuntu.sh`: full Ubuntu + i3 machine bootstrap
- `bash scripts/update_ubuntu.sh`: sync Ubuntu configs into `$HOME`
- `bash scripts/setup_random_wallpaper.sh`: Hyprland wallpaper helper
- `bash maintenance/fix.sh`: maintenance script; inspect before running

## Editing Guidance
- Shell scripts use `bash`. Keep shebangs and existing style.
- Prefer small named functions for new script logic. The newer update scripts already follow this pattern.
- Use `snake_case` for new script names and helpers.
- Keep Arch and Ubuntu behaviors parallel when the concern is shared, especially for tmux and zsh.
- If a change affects tmux startup, check all of:
  [`.config/tmux/tmux.conf`](/home/henriquesilva/linux-config/.config/tmux/tmux.conf),
  [`scripts/install.sh`](/home/henriquesilva/linux-config/scripts/install.sh),
  [`scripts/update.sh`](/home/henriquesilva/linux-config/scripts/update.sh),
  [`scripts/install_ubuntu.sh`](/home/henriquesilva/linux-config/scripts/install_ubuntu.sh),
  [`scripts/update_ubuntu.sh`](/home/henriquesilva/linux-config/scripts/update_ubuntu.sh),
  and [`.config/systemd/user`](/home/henriquesilva/linux-config/.config/systemd/user).
- If a change affects notifications or bars, remember the stacks differ:
  Arch uses Waybar + SwayNC, Ubuntu uses Polybar + Dunst.
- If a change affects wallpapers, remember Ubuntu uses [`.config/i3/random_wallpaper.sh`](/home/henriquesilva/linux-config/.config/i3/random_wallpaper.sh) via [`.config/systemd/user/random-wallpaper.service`](/home/henriquesilva/linux-config/.config/systemd/user/random-wallpaper.service), while Arch wallpaper behavior lives under [`.config/hypr`](/home/henriquesilva/linux-config/.config/hypr) and related helper scripts.

## Testing Expectations
There is no automated test suite. Minimum validation is:

- run `bash -n` on every script you change
- if install/update logic changes, run the relevant install or update script in a safe environment
- if WM config changes, verify the target desktop session starts and the affected shortcut or component works
- if tmux or zsh changes, verify tmux starts, TPM installs plugins, and new panes open in zsh

## Commit & PR Notes
- Commit messages are short, imperative, and capitalized
- PRs should say which target was changed: Arch/Hyprland, Ubuntu/i3, or shared
- Include the scripts or validations you ran
- Include screenshots for visible bar, notification, or launcher changes

## Security & Safety
- Install scripts invoke `sudo`, `pacman`, `yay`, `apt`, `git clone`, and `systemctl --user`
- Review any package or service changes carefully before running them on a live machine
- Avoid destructive changes to users' existing dotfiles unless the script is explicitly meant to replace them
