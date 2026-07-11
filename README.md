# dotfiles

Personal macOS setup, fully declarative and managed with **Nix**
([nix-darwin](https://github.com/nix-darwin/nix-darwin) +
[home-manager](https://github.com/nix-community/home-manager)).

One command rebuilds the whole system: CLI packages, GUI apps (Homebrew casks),
macOS settings, fonts, launchd services and dotfiles.

## What's included

| Package     | Description                                  |
| ----------- | -------------------------------------------- |
| `nix/`      | The flake: system + user config, devshell templates |
| `aerospace` | Tiling window manager (i3-inspired) + JankyBorders |
| `alacritty` | Terminal emulator (Moonfly theme)            |
| `zsh`       | Zsh + zinit + Pure prompt                    |
| `nvim`      | Neovim config (based on kickstart)           |
| `tmux`      | Tmux + sessionizer script                    |
| `git`       | Git configuration (delta, Moonfly theme)     |
| `yazi`      | Terminal file manager                        |
| `lazygit`   | Git TUI                                      |
| `lazydocker`| Docker TUI                                   |

## Installation

```bash
xcode-select --install
git clone https://github.com/gauthier-se/dotfiles.git ~/dotfiles
curl -fsSL https://install.determinate.systems/nix | sh -s -- install --determinate
sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake ~/dotfiles/nix
```

See [`nix/README.md`](nix/README.md) for day-to-day usage and per-project devshells.

## Layout

```
nix/        flake.nix, darwin/ (system), home/ (user), templates/ (devshells)
configs/    dotfiles, symlinked into $HOME by home-manager (editable without rebuild)
```
