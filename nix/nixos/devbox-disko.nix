# Applied by disko during the nixos-anywhere install. No LUKS, unlike the
# laptop: a headless guest that asks for a passphrase never comes back from a
# reboot on its own.
{
  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/vda"; # virtio0 on the Proxmox side
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
