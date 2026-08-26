# dotfiles

Personal setup for three machines, fully declarative and managed with **Nix**:

- **MacBook Pro**: [nix-darwin](https://github.com/nix-darwin/nix-darwin)
- **Laptop (NixOS)**: Hyprland + Waybar + Fuzzel, tuigreet login, LUKS full-disk encryption
- **Dev box (NixOS)**: headless VM in the homelab, reached over SSH from the
  terminal and from the phone; installed remotely with nixos-anywhere + disko

All three share the same [home-manager](https://github.com/nix-community/home-manager)
config: one command rebuilds the whole system, from CLI packages and GUI apps to
system settings, fonts and dotfiles. Same minimalist philosophy everywhere, Moonfly theme
everywhere.

## What's included

### Shared (Mac + laptop)

| Package     | Description                                  |
| ----------- | -------------------------------------------- |
| `nix/`      | The flake: system + user config, devshell templates |
| `alacritty` | Terminal emulator (Moonfly theme)            |
| `zsh`       | Zsh + zinit + Pure prompt                    |
| `nvim`      | Neovim config (based on kickstart)           |
| `tmux`      | Tmux + sessionizer script                    |
| `git`       | Git configuration (delta, Moonfly theme)     |
| `lazygit`   | Git TUI                                      |
| `lazydocker`| Docker TUI                                   |
| `atuin`     | Shell history in SQLite, `ctrl-r` search (local only, no sync) |
| `navi`      | Interactive cheatsheets on `ctrl-g`, the cheats live in `configs/navi/cheats/` |

Packages without a config of their own: `ccusage` (token usage analysis) and
`antigravity-cli` (`agy`, unfree, hence `nixpkgs.config.allowUnfree` in every
system config).

### macOS only

| Package     | Description                                  |
| ----------- | -------------------------------------------- |
| `aerospace` | Tiling window manager (i3-inspired) + JankyBorders |

### NixOS only

| Package     | Description                                  |
| ----------- | -------------------------------------------- |
| `hypr`      | Hyprland (tiling Wayland compositor), bindings mirror aerospace |
| `waybar`    | Minimal status bar (workspaces / clock / system) |
| `fuzzel`    | Application launcher (`Super+Space`)         |
| `mako`      | Notification daemon                          |

## Installation

**macOS:**

```bash
xcode-select --install
git clone https://github.com/gauthier-se/dotfiles.git ~/dotfiles
curl -fsSL https://install.determinate.systems/nix | sh -s -- install --determinate
sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake ~/dotfiles/nix
```

**NixOS (laptop):** boot the minimal ISO and follow the install procedure in
[`nix/README.md`](nix/README.md): partitioning + LUKS, hardware config,
then `nixos-install --flake ~/dotfiles/nix#laptop`.

**NixOS (dev box):** no ISO. The VM is created by OpenTofu in the homelab repo,
then installed over SSH with `nixos-anywhere --flake ~/dotfiles/nix#devbox`.

See [`nix/README.md`](nix/README.md) for day-to-day usage and per-project devshells.

## Layout

```
nix/        flake.nix, darwin/ (macOS system), nixos/ (laptop + devbox systems),
            home/ (user: common + per-OS + server), templates/ (devshells)
configs/    dotfiles, symlinked into $HOME by home-manager (editable without rebuild)
```
