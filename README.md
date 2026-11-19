# dotfiles

Personal setup for two machines, fully declarative and managed with **Nix**:

- **MacBook Pro**: [nix-darwin](https://github.com/nix-darwin/nix-darwin)
- **Laptop (NixOS)**: Hyprland + Waybar + Fuzzel, tuigreet login, LUKS full-disk encryption

The same flake also describes the **agent factory**, a headless homelab VM that
runs coding agents in per-task containers: `nix/nixos/factory.nix`, and its
task image and dev container template in [`factory/`](factory/).

Both share the same [home-manager](https://github.com/nix-community/home-manager)
config: one command rebuilds the whole system, from CLI packages and GUI apps to
system settings, fonts and dotfiles. Same minimalist philosophy everywhere, Moonfly theme
everywhere.

## What's included

### Shared (Mac + laptop)

| Package     | Description                                  |
| ----------- | -------------------------------------------- |
| `nix/`      | The flake: system + user config, devshell templates |
| `alacritty` | Terminal emulator (Moonfly theme)            |
| `theme`     | `theme [dark\|light]` toggles Alacritty, tmux and nvim (herdr follows Alacritty) between Moonfly and GitHub Light |
| `zsh`       | Zsh + zinit + Pure prompt                    |
| `nvim`      | Neovim config (based on kickstart)           |
| `tmux`      | Tmux + sessionizer script                    |
| `herdr`     | Agent multiplexer, with the tmux bindings    |
| `git`       | Git configuration (delta, Moonfly theme)     |
| `lazygit`   | Git TUI                                      |
| `lazydocker`| Docker TUI                                   |
| `claude`    | Global Claude Code rules (`CLAUDE.md`), shared with the factory's images |

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

See [`nix/README.md`](nix/README.md) for day-to-day usage and per-project devshells.

## Layout

```
nix/        flake.nix, darwin/ (macOS system), nixos/ (laptop system),
            home/ (user: common + per-OS), templates/ (devshells)
configs/    dotfiles, symlinked into $HOME by home-manager (editable without rebuild)
factory/    the agent factory: task image, LifeOS image, launcher, dev container template
```
