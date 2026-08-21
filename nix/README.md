# Nix config: nix-darwin (Mac) + NixOS (laptop, dev box), shared home-manager

One flake, three machines:

- `darwinConfigurations."segaus-MacBook-Pro"` for macOS: CLI packages (nixpkgs),
  GUI apps (Homebrew casks), macOS settings.
- `nixosConfigurations."laptop"` for NixOS: Hyprland + Waybar + Fuzzel,
  greetd/tuigreet login, PipeWire, NetworkManager.
- `nixosConfigurations."devbox"`, the headless VM in the homelab, reached over SSH
  from the terminal and from the phone. No desktop, no display server: the same
  shell and editor as the other two, on a machine that does not close at night.

All three import the same `home/common.nix` (CLI tools, nvim, tmux, zsh…), with
dotfiles symlinked from `../configs/`. Platform-specific bits live in
`home/darwin.nix` (aerospace, jankyborders), `home/linux.nix` (hypr, waybar,
fuzzel, mako, GUI apps) and `home/server.nix` (common.nix plus the agent CLI,
nothing graphical).

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

## Bootstrap (laptop: fresh NixOS install)

Boot the [NixOS minimal ISO](https://nixos.org/download/) from a USB stick, then:

```bash
# 0. French keymap first: the LUKS passphrase must be typed the same at boot
loadkeys fr

# 1. Partition the disk (wipes everything), example for /dev/nvme0n1:
#    - EFI partition (512M, FAT32, mounted on /boot)
#    - LUKS-encrypted root (rest, ext4 inside, mounted on /)
sudo fdisk /dev/nvme0n1                      # g, n (+512M, type 1=EFI), n (rest), w
sudo mkfs.fat -F32 -n boot /dev/nvme0n1p1

# 2. Encrypt & format the root: passphrase asked at every boot
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

## Bootstrap (dev box: homelab VM)

No ISO and no console: the VM is created by OpenTofu from a Debian cloud image
(guest 220 in the homelab repo), and [nixos-anywhere](https://github.com/nix-community/nixos-anywhere)
then kexecs into the NixOS installer over SSH, partitions with disko
(`nixos/devbox-disko.nix`) and installs on top. The seed image is only there to
answer an SSH connection once.

```bash
# From the Mac, once `tofu apply` has created the VM:
nix run github:nix-community/nixos-anywhere -- \
  --flake ~/dotfiles/nix#devbox \
  --build-on remote \
  root@10.10.20.20

# Then join the tailnet, once (this is what makes it reachable from the phone):
ssh segau@10.10.20.20 -- sudo tailscale up
```

`--build-on remote` is not an optimization: this Mac is aarch64 and cannot
produce the x86_64 closure at all, while the VM has four cores and a Nix daemon
of its own.

Re-running the command reinstalls the machine from scratch. Nothing there is
meant to survive it: projects live in git, the system lives in this flake, and
`~/dotfiles` is cloned back by a one-shot unit on first boot (home-manager
symlinks nvim/tmux/zsh *into* that repo, so they dangle until it exists).

Full rationale, network placement and access notes: `docs/services/devbox.md` in
the homelab repo.

## Day-to-day

```bash
# Mac: apply a config change (alias: update)
sudo darwin-rebuild switch --flake ~/dotfiles/nix

# Laptop / dev box: same idea, the attribute is the hostname
sudo nixos-rebuild switch --flake ~/dotfiles/nix#laptop

# Dev box, without logging into it (the Mac only evaluates; it builds there)
nixos-rebuild switch --flake ~/dotfiles/nix#devbox \
  --target-host root@10.10.20.20 --build-host root@10.10.20.20

# Upgrade everything (alias: upgrade). Bump the lockfile, rebuild, then Homebrew.
# Commit the resulting flake.lock: it is what keeps both machines in sync.
nix flake update --flake ~/dotfiles/nix \
  && sudo darwin-rebuild switch --flake ~/dotfiles/nix \
  && brew update && brew upgrade --cask && mas upgrade

# Roll back a bad rebuild (nixos-rebuild takes the same flags)
darwin-rebuild --list-generations
sudo darwin-rebuild switch --rollback

# Nix itself: installed by Determinate, not managed by nix-darwin (nix.enable = false)
sudo determinate-nixd upgrade

# Reclaim disk space, once the new generation has proven itself
sudo nix-collect-garbage -d && nix-collect-garbage -d && sudo nix store optimise
```

`update` and `upgrade` are defined per-OS in `configs/zsh/.zsh_aliases` (the file is
shared, so it branches on `$OSTYPE`): the NixOS variants skip the Homebrew step and
target `#$HOST`, so the same alias rebuilds the laptop on the laptop and the dev box
on the dev box.

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

- `homebrew.onActivation.cleanup = "zap"`: brew only ever holds what the flake
  declares. Anything removed from `casks`/`brews` is uninstalled on the next rebuild.
- `autoUpdate` and `upgrade` are both off, so a rebuild never changes a cask
  version: it installs what is missing and leaves the rest alone. Cask upgrades
  happen only when you ask for them (the `upgrade` alias). Flip both to `true`
  if you would rather have every rebuild pull the latest, at the cost of slower,
  non-reproducible rebuilds.
