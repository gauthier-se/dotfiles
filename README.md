# dotfiles

My personal dotfiles for macOS, managed with [GNU Stow](https://www.gnu.org/software/stow/).

## What's included

| Package    | Description                          |
| ---------- | ------------------------------------ |
| `git`      | Git configuration                    |
| `nvim`     | Neovim config (based on kickstart)   |
| `tmux`     | Tmux config with Catppuccin theme    |
| `vim`      | Minimal Vim config (fallback)        |
| `zsh`      | Zsh config with Oh My Zsh and Pure   |

## Prerequisites

- macOS
- [Homebrew](https://brew.sh)
- [GNU Stow](https://www.gnu.org/software/stow/) (`brew install stow`)
- [Oh My Zsh](https://ohmyz.sh/)
- [Pure prompt](https://github.com/sindresorhus/pure) (`brew install pure`)
- [Neovim](https://neovim.io/) (`brew install neovim`)
- [tmux](https://github.com/tmux/tmux) (`brew install tmux`)
- [TPM](https://github.com/tmux-plugins/tpm) (Tmux Plugin Manager)
- [fzf](https://github.com/junegunn/fzf) (`brew install fzf`)
- [zoxide](https://github.com/ajeetdsouza/zoxide) (`brew install zoxide`)

## Installation

```bash
git clone https://github.com/gauthierseyzeriat/dotfiles.git ~/dotfiles
cd ~/dotfiles
chmod +x install.sh
./install.sh
```

## How it works

Each top-level directory is a Stow package. Running `stow <package>` from the dotfiles directory creates symlinks in `$HOME` that mirror the package's structure.

For example, `stow zsh` creates a symlink `~/.zshrc → ~/dotfiles/zsh/.zshrc`.

To uninstall a single package:

```bash
stow -D <package>
```
