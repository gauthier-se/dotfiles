# Nix config — nix-darwin (Mac) + NixOS (laptop), shared home-manager

One flake, two machines:

- `darwinConfigurations."segaus-MacBook-Pro"` — macOS: CLI packages (nixpkgs),
  GUI apps (Homebrew casks), macOS settings.
- `nixosConfigurations."laptop"` — NixOS: Hyprland + Waybar + Fuzzel,
  greetd/tuigreet login, PipeWire, NetworkManager.

Both import the same `home/common.nix` (CLI tools, nvim, tmux, zsh, alacritty…),
with dotfiles symlinked from `../configs/`. Platform-specific bits live in
`home/darwin.nix` (aerospace, jankyborders) and `home/linux.nix` (hypr, waybar,
fuzzel, mako, GUI apps).

## Bootstrap (fresh Mac)

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

## Bootstrap (laptop — fresh NixOS install)

Boot the [NixOS minimal ISO](https://nixos.org/download/) from a USB stick, then:

```bash
# 0. French keymap first — the LUKS passphrase must be typed the same at boot
loadkeys fr

# 1. Partition the disk (wipes everything) — example for /dev/nvme0n1:
#    - EFI partition (512M, FAT32, mounted on /boot)
#    - LUKS-encrypted root (rest, ext4 inside, mounted on /)
sudo fdisk /dev/nvme0n1                      # g, n (+512M, type 1=EFI), n (rest), w
sudo mkfs.fat -F32 -n boot /dev/nvme0n1p1

# 2. Encrypt & format the root — passphrase asked at every boot
sudo cryptsetup luksFormat --label cryptroot /dev/nvme0n1p2
sudo cryptsetup open /dev/nvme0n1p2 cryptroot
sudo mkfs.ext4 -L nixos /dev/mapper/cryptroot

sudo mount /dev/disk/by-label/nixos /mnt
sudo mkdir -p /mnt/boot && sudo mount /dev/disk/by-label/boot /mnt/boot

# 3. Generate the hardware config for THIS machine
#    (detects the LUKS mapping and fills in boot.initrd.luks.devices)
sudo nixos-generate-config --root /mnt

# 4. Clone the repo and drop the hardware config in
git clone https://github.com/gauthier-se/dotfiles.git /mnt/home/segau/dotfiles
cp /mnt/etc/nixos/hardware-configuration.nix /mnt/home/segau/dotfiles/nix/nixos/
git -C /mnt/home/segau/dotfiles add nix/nixos/hardware-configuration.nix

# 5. Install
sudo nixos-install --flake /mnt/home/segau/dotfiles/nix#laptop
reboot
```

After the first boot, log in via tuigreet, then set your password properly and
commit the `hardware-configuration.nix` you copied into the repo.

## Day-to-day

```bash
# Mac: apply a config change (alias: update)
sudo darwin-rebuild switch --flake ~/dotfiles/nix

# Laptop: same idea
sudo nixos-rebuild switch --flake ~/dotfiles/nix#laptop

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
