#!/bin/bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}Installing dotfiles from $DOTFILES_DIR${NC}"

# Check dependencies
if ! command -v stow &>/dev/null; then
    echo "GNU Stow is required. Install it with: brew install stow"
    exit 1
fi

# Stow each package
packages=(git nvim tmux vim zsh)

for pkg in "${packages[@]}"; do
    echo -e "  Stowing ${GREEN}$pkg${NC}..."
    stow -d "$DOTFILES_DIR" -t "$HOME" "$pkg"
done

echo ""
echo -e "${GREEN}Dotfiles installed successfully!${NC}"
echo "You may need to restart your shell for changes to take effect."
