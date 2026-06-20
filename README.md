# dotfiles

Personal cross-platform dotfiles, fully automated and managed with **Ansible**.

Targets **macOS** (Homebrew) and **Arch Linux** (Hyprland / Wayland) from a single source of truth. The install script auto-detects the OS, sets up an isolated Ansible environment using `pipx`, and provisions everything automatically.

## What's included

### Common (both platforms)

| Package     | Description                              |
| ----------- | ---------------------------------------- |
| `ghostty`   | Fast, native terminal emulator           |
| `git`       | Git configuration                        |
| `nvim`      | Neovim config (based on kickstart)       |
| `tmux`      | Tmux + Catppuccin theme                  |
| `vim`       | Minimal Vim fallback                     |
| `zsh`       | Zsh + Oh My Zsh + Pure prompt            |
| `yazi`      | Terminal file manager                    |
| `lazygit`   | Git TUI (delta integration + Catppuccin) |
| `lazydocker`| Docker TUI (Catppuccin theme)            |
| `bat`       | Cat clone with syntax highlighting       |

### macOS only

| Package     | Description                          |
| ----------- | ------------------------------------ |
| `aerospace` | Tiling window manager (i3-inspired)  |

### Arch Linux only

| Package     | Description                                          |
| ----------- | ---------------------------------------------------- |
| `hypr`      | Hyprland compositor (AZERTY keybinds)                |
| `waybar`    | Top bar                                              |
| `wofi`      | App launcher                                         |
| `dunst`     | Notifications                                        |
| `gtk`       | GTK dark mode                                        |
| `qt`        | Kvantum + qt5ct/qt6ct → Catppuccin Mocha Blue        |
| `sddm`      | SDDM display manager theme (copied to `/etc/`)       |

## Installation

```bash
git clone https://github.com/gauthier-se/dotfiles.git ~/dotfiles
cd ~/dotfiles
chmod +x install.sh
./install.sh
```

The script:
1. Detects the OS and installs base dependencies (`brew` on macOS, `pacman` on Arch).
2. Installs `pipx` to cleanly install `ansible` in an isolated environment.
3. Automatically fetches necessary Ansible collections.
4. Executes the playbook (`local.yml`), which handles package installation, oh-my-zsh setup, and dotfiles symlinking.

## Theme

Catppuccin Mocha across the board: terminal, editor, prompt, bar, launcher, login screen, GTK + Qt apps.
