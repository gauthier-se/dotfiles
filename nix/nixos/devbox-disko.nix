# Disk layout for the homelab dev box, applied by disko during the
# nixos-anywhere install. This file is what makes the install reproducible:
# there is no partitioning step to remember, and re-running the installer
# rebuilds the machine exactly the same way.
#
# No LUKS, unlike the laptop. A headless guest that asks for a passphrase never
# comes back from a reboot on its own, and the disk it would protect is a file
# on the hypervisor — encrypting it here defends against nothing the node's own
# access controls do not already cover.
{
  disko.devices.disk.main = {
    type = "disk";
    # virtio0 on the Proxmox side (see the OpenTofu `nixos-vm` module).
    device = "/dev/vda";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          size = "512M";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            # Keeps the boot partition unreadable to everyone but root: it is
            # world-readable by default, and vfat carries no permissions of its own.
            mountOptions = [ "umask=0077" ];
          };
        };
        root = {
          size = "100%";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
          };
        };
      };
    };
  };
}
