# macOS config — nix-darwin + home-manager

Fully declarative macOS system: CLI packages (nixpkgs), GUI apps (Homebrew casks
managed by nix-darwin), macOS settings, fonts, and dotfiles symlinked from `../configs/`.

## Bootstrap (fresh machine)

```bash
# 1. Command Line Tools (git)
xcode-select --install

# 2. Clone the repo
git clone https://github.com/gauthier-se/dotfiles.git ~/dotfiles

# 3. Install Nix (Determinate Systems)
curl -fsSL https://install.determinate.systems/nix | sh -s -- install --determinate

# 4. Apply the config (also installs Homebrew via nix-homebrew)
sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake ~/dotfiles/nix
```

## Day-to-day

```bash
# Apply a config change (alias: update)
sudo darwin-rebuild switch --flake ~/dotfiles/nix

# Upgrade packages (bump the lockfile, then rebuild)
nix flake update --flake ~/dotfiles/nix && sudo darwin-rebuild switch --flake ~/dotfiles/nix
```

Configs (`nvim`, `tmux`, `aerospace`…) are symlinked outside the Nix store:
they stay editable without a rebuild.

## Per-project devshells

```bash
cd my-project
nix flake init -t ~/dotfiles/nix#python   # or #node, #go, #java
direnv allow
```

The environment activates automatically when entering the directory (direnv + nix-direnv).
No runtime is installed globally, except a Node LTS for `npx` and agent CLIs.

## Notes

- `homebrew.onActivation.cleanup` is set to `"none"` during the migration;
  switch it to `"zap"` after the clean reinstall.
