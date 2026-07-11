#!/bin/sh
# Link the shared Obsidian look (Minimal theme, true black, Style Settings)
# into a vault. Usage: obsidian-vault-setup <vault-path>
set -eu

VAULT="${1:?usage: obsidian-vault-setup <vault-path>}"
SRC="$HOME/dotfiles/configs/obsidian"
OB="$VAULT/.obsidian"

[ -d "$VAULT" ] || { echo "no such vault: $VAULT" >&2; exit 1; }
mkdir -p "$OB/plugins"

# Backup anything real that would be replaced by a symlink, then link
link() { # link <src> <dest>
  if [ -e "$2" ] && [ ! -L "$2" ]; then mv "$2" "$2.bak"; fi
  ln -sfn "$1" "$2"
}

link "$SRC/themes" "$OB/themes"
link "$SRC/appearance.json" "$OB/appearance.json"
for p in obsidian-minimal-settings obsidian-style-settings; do
  link "$SRC/plugins/$p" "$OB/plugins/$p"
done

# Make sure both plugins are enabled in this vault
CP="$OB/community-plugins.json"
if [ -f "$CP" ]; then
  jq '. + ["obsidian-minimal-settings", "obsidian-style-settings"] | unique' "$CP" > "$CP.tmp" && mv "$CP.tmp" "$CP"
else
  printf '["obsidian-minimal-settings", "obsidian-style-settings"]\n' > "$CP"
fi

echo "vault ready: $VAULT"
