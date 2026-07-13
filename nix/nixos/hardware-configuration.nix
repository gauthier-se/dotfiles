# Placeholder — machine-specific, replaced at install time.
#
# During the NixOS install, run:
#   nixos-generate-config --root /mnt
# then replace this file with the generated one:
#   cp /mnt/etc/nixos/hardware-configuration.nix ~/dotfiles/nix/nixos/
# and commit it. The values below only exist so the flake evaluates before
# the install; they do NOT describe real hardware.
{ ... }:

{
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
  };
}
