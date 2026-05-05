#!/bin/bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log() { echo -e "${CYAN}==>${NC} $1"; }
ok()  { echo -e "  ${GREEN}✓${NC} $1"; }

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
  IS_MACOS=true
else
  IS_MACOS=false
fi

echo -e "${YELLOW}Installing dotfiles from $DOTFILES_DIR${NC}"

# ── Dependencies ─────────────────────────────────────────────────────────────

log "Checking dependencies..."

if $IS_MACOS; then
  if ! command -v brew &>/dev/null; then
    echo "Homebrew is required on macOS. Install it from https://brew.sh"
    exit 1
  fi
  brew install stow tmux neovim fzf zoxide bat yazi git-delta lazygit lazydocker
  brew install pure
  brew install --cask nikitabobko/tap/aerospace
else
  if ! command -v pacman &>/dev/null; then
    echo "pacman not found — is this really Arch Linux?"
    exit 1
  fi
  sudo pacman -S --needed --noconfirm stow tmux neovim fzf zoxide bat git-delta lazygit lazydocker grim slurp ttf-jetbrains-mono-nerd brightnessctl awww jq wl-clipboard libnotify imv kvantum qt5ct qt6ct noto-fonts noto-fonts-emoji noto-fonts-cjk

  if ! command -v yay &>/dev/null; then
    echo "yay (AUR helper) is required. Install it first: https://github.com/Jguer/yay"
    exit 1
  fi
  yay -S --needed --noconfirm yazi kvantum-theme-catppuccin-git catppuccin-sddm-theme-mocha
fi

ok "Dependencies ready"

# ── Oh My Zsh ────────────────────────────────────────────────────────────────

if [ ! -d "$HOME/.oh-my-zsh" ]; then
  log "Installing Oh My Zsh..."
  # KEEP_ZSHRC=yes prevents oh-my-zsh from creating ~/.zshrc (stow handles it)
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  ok "Oh My Zsh installed"
else
  ok "Oh My Zsh already installed"
fi

# Remove any .zshrc created by oh-my-zsh so stow can link ours
[ -f "$HOME/.zshrc" ] && [ ! -L "$HOME/.zshrc" ] && rm "$HOME/.zshrc"

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# ── Oh My Zsh plugins ────────────────────────────────────────────────────────

log "Installing Oh My Zsh plugins..."

clone_plugin() {
  local name="$1" url="$2"
  if [ ! -d "$ZSH_CUSTOM/plugins/$name" ]; then
    git clone --depth=1 "$url" "$ZSH_CUSTOM/plugins/$name"
    ok "$name"
  else
    ok "$name (already installed)"
  fi
}

clone_plugin zsh-autosuggestions    https://github.com/zsh-users/zsh-autosuggestions
clone_plugin zsh-syntax-highlighting https://github.com/zsh-users/zsh-syntax-highlighting
clone_plugin you-should-use         https://github.com/MichaelAquilina/zsh-you-should-use
clone_plugin zsh-bat                https://github.com/fdellwing/zsh-bat

# ── Pure prompt ──────────────────────────────────────────────────────────────

if ! $IS_MACOS; then
  if [ ! -d "$HOME/.zsh/pure" ]; then
    log "Installing Pure prompt..."
    mkdir -p "$HOME/.zsh"
    git clone --depth=1 https://github.com/sindresorhus/pure.git "$HOME/.zsh/pure"
    ok "Pure prompt installed"
  else
    ok "Pure prompt already installed"
  fi
fi

# ── Catppuccin Mocha syntax highlighting ─────────────────────────────────────

if [ ! -f "$HOME/.zsh/catppuccin_mocha-zsh-syntax-highlighting.zsh" ]; then
  log "Installing Catppuccin syntax highlighting..."
  mkdir -p "$HOME/.zsh"
  curl -fsSLo "$HOME/.zsh/catppuccin_mocha-zsh-syntax-highlighting.zsh" \
    https://github.com/catppuccin/zsh-syntax-highlighting/raw/main/themes/catppuccin_mocha-zsh-syntax-highlighting.zsh
  ok "Catppuccin syntax highlighting installed"
else
  ok "Catppuccin syntax highlighting already installed"
fi

# ── TPM (Tmux Plugin Manager) ─────────────────────────────────────────────────

if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  log "Installing TPM..."
  git clone --depth=1 https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
  ok "TPM installed"
else
  ok "TPM already installed"
fi

# ── Stow ─────────────────────────────────────────────────────────────────────

log "Stowing dotfiles..."

if ! command -v stow &>/dev/null; then
  echo "stow not found after install — aborting"
  exit 1
fi

# Packages common to both platforms
common_packages=(git nvim tmux vim zsh yazi lazygit lazydocker)

# Platform-specific
if $IS_MACOS; then
  platform_packages=(ghostty aerospace)
else
  platform_packages=(alacritty hypr waybar wofi dunst gtk brave qt)
fi

for pkg in "${common_packages[@]}" "${platform_packages[@]}"; do
  echo -e "  Stowing ${GREEN}$pkg${NC}..."
  stow -d "$DOTFILES_DIR" -t "$HOME" "$pkg"
done

# ── SDDM (Arch only) ─────────────────────────────────────────────────────────

if ! $IS_MACOS; then
  if command -v sddm &>/dev/null; then
    log "Configuring SDDM..."
    sudo mkdir -p /etc/sddm.conf.d
    sudo cp "$DOTFILES_DIR/sddm/sddm.conf" /etc/sddm.conf.d/10-theme.conf
    sudo systemctl enable sddm
    ok "SDDM configured and enabled"
  fi
fi

echo ""
echo -e "${GREEN}Done! Restart your shell or run: source ~/.zshrc${NC}"
