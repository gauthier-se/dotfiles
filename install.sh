#!/bin/bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log() { echo -e "${CYAN}==>${NC} $1"; }
ok()  { echo -e "  ${GREEN}✓${NC} $1"; }

log "Bootstrapping system with Ansible..."

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
  IS_MACOS=true
else
  IS_MACOS=false
fi

if $IS_MACOS; then
  if ! command -v brew &>/dev/null; then
    log "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  
  if ! command -v pipx &>/dev/null; then
    log "Installing pipx..."
    brew install pipx
  fi
  
  if ! command -v ansible &>/dev/null && [ ! -f "$HOME/.local/bin/ansible" ]; then
    log "Installing Ansible via pipx..."
    pipx install --include-deps ansible
  fi
else
  if ! command -v pacman &>/dev/null; then
    echo "pacman not found — is this really Arch Linux?"
    exit 1
  fi
  
  log "Updating system and installing base dependencies..."
  sudo pacman -Syu --noconfirm --needed git python-pipx base-devel

  if ! command -v yay &>/dev/null; then
    log "Installing yay (AUR helper)..."
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay
    makepkg -si --noconfirm
    cd "$DOTFILES_DIR"
    rm -rf /tmp/yay
  fi

  if ! command -v ansible &>/dev/null && [ ! -f "$HOME/.local/bin/ansible" ]; then
    log "Installing Ansible via pipx..."
    pipx install --include-deps ansible
  fi
fi

# Ensure ~/.local/bin is in PATH for the rest of the script
export PATH="$HOME/.local/bin:$PATH"

# Install Ansible requirements (collections/roles)
ansible-galaxy install -r "$DOTFILES_DIR/requirements.yml"

log "Running Ansible playbook..."
ansible-playbook "$DOTFILES_DIR/local.yml" -K

ok "Done! System setup complete."
