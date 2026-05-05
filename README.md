# dotfiles

Personal cross-platform dotfiles, managed with [GNU Stow](https://www.gnu.org/software/stow/).

Targets **macOS** (Homebrew) and **Arch Linux + Hyprland** (Wayland) from a single source of truth. The install script auto-detects the OS and installs the right packages.

## What's included

### Common (both platforms)

| Package | Description                              |
| ------- | ---------------------------------------- |
| `git`   | Git configuration                        |
| `nvim`  | Neovim config (based on kickstart)       |
| `tmux`  | Tmux + Catppuccin theme                  |
| `vim`   | Minimal Vim fallback                     |
| `zsh`   | Zsh + Oh My Zsh + Pure prompt            |
| `yazi`  | Terminal file manager                    |
| `lazygit`   | Git TUI (delta integration + Catppuccin) |
| `lazydocker`| Docker TUI (Catppuccin theme)            |

### macOS only

| Package     | Description                          |
| ----------- | ------------------------------------ |
| `ghostty`   | Terminal emulator                    |
| `aerospace` | Tiling window manager (i3-inspired)  |

### Arch Linux only

| Package     | Description                                          |
| ----------- | ---------------------------------------------------- |
| `alacritty` | Terminal emulator (Catppuccin Mocha)                 |
| `hypr`      | Hyprland compositor (AZERTY keybinds)                |
| `waybar`    | Top bar                                              |
| `wofi`      | App launcher                                         |
| `dunst`     | Notifications                                        |
| `gtk`       | GTK dark mode                                        |
| `qt`        | Kvantum + qt5ct/qt6ct → Catppuccin Mocha Blue        |
| `sddm`      | SDDM display manager theme (copied to `/etc/`)       |
| `brave`     | Brave dark mode flags                                |

## Installation

```bash
git clone https://github.com/gauthier-se/dotfiles.git ~/dotfiles
cd ~/dotfiles
chmod +x install.sh
./install.sh
```

The script:
- Detects the OS and installs all dependencies (`brew` on macOS, `pacman` + `yay` on Arch).
- Installs Oh My Zsh, plugins, Pure prompt, Catppuccin syntax highlighting, TPM.
- Stows all relevant packages into `$HOME`.
- On Arch: also configures SDDM with the Catppuccin theme.

## Theme

Catppuccin Mocha across the board: terminal, editor, prompt, bar, launcher, login screen, GTK + Qt apps.

## How it works

Each top-level directory is a Stow package. Running `stow <package>` from the dotfiles directory creates symlinks in `$HOME` mirroring its structure.

For example, `stow zsh` creates `~/.zshrc → ~/dotfiles/zsh/.zshrc`.

To uninstall a single package:

```bash
stow -D <package>
```
