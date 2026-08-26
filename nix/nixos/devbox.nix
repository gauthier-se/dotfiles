{ config, pkgs, user, ... }:

# Homelab dev box: Proxmox VM 220 on the Servers VLAN, provisioned by OpenTofu
# in the homelab repo and installed with nixos-anywhere. Headless: reached over
# SSH from the terminal and from Termius on the phone.
let
  # Add the phone's Termius key here: no account has a password, so this list
  # is the only way in.
  authorizedKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILuL65N5OYZw+yJcghWu7aIsocUjcNuYbedgDsUZu3eI gauthier"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGvZTl4Y0ruWDeL6osQwdFOcjXqxPvenM6HkAwnhs57c termius-iphone"
  ];
in
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true; # claude-code

  system.stateVersion = "25.05";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.availableKernelModules = [ "virtio_pci" "virtio_blk" "virtio_scsi" "ahci" "sd_mod" "sr_mod" ];

  services.qemuGuest.enable = true;
  zramSwap.enable = true;

  time.timeZone = "Europe/Paris";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "fr";

  # NixOS never reads the cloud-init drive Proxmox attaches, so this address has
  # to stay in step with the OpenTofu catalogue. Matched on `en*` because the
  # interface name depends on the emulated bus, so pinning `ens18` is what leaves
  # the machine unreachable with nothing in the logs.
  networking.hostName = "devbox";
  networking.useDHCP = false;
  networking.useNetworkd = true;
  networking.nameservers = [ "10.10.20.1" ];

  systemd.network.networks."10-lan" = {
    matchConfig.Name = "en*";
    address = [ "10.10.20.20/24" ];
    routes = [ { Gateway = "10.10.20.1"; } ];
    linkConfig.RequiredForOnline = "routable";
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
    allowedUDPPorts = [ config.services.tailscale.port ];
    trustedInterfaces = [ "tailscale0" ];
    checkReversePath = "loose"; # strict filtering drops the tailnet's return traffic
  };

  services.tailscale.enable = true;

  # Tailscale accepts advertised routes, including the subnet this machine is
  # already on. Table 52 is consulted before main, so local traffic would leave
  # through the tunnel and inbound sessions get answered on the wrong path.
  # Keep the local subnet on the main table.
  systemd.services.tailscale-local-subnet = {
    description = "Keep the local subnet out of the Tailscale route table";
    after = [ "tailscaled.service" ];
    wants = [ "tailscaled.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStartPre = "-${pkgs.iproute2}/bin/ip rule del to 10.10.20.0/24 lookup main priority 5260";
      ExecStart = "${pkgs.iproute2}/bin/ip rule add to 10.10.20.0/24 lookup main priority 5260";
      ExecStop = "-${pkgs.iproute2}/bin/ip rule del to 10.10.20.0/24 lookup main priority 5260";
    };
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      # nixos-anywhere and `nixos-rebuild --target-host` both need root; with
      # password auth off this means "key only".
      PermitRootLogin = "prohibit-password";
    };
  };

  users.mutableUsers = false;
  users.users.root.openssh.authorizedKeys.keys = authorizedKeys;

  users.users.${user} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = authorizedKeys;
  };

  programs.zsh.enable = true;

  # There is no password to type, so sudo must not ask for one.
  security.sudo.wheelNeedsPassword = false;

  virtualisation.docker = {
    enable = true;
    autoPrune = {
      enable = true;
      dates = "weekly";
    };
  };

  # home-manager symlinks nvim/tmux/zsh *into* ~/dotfiles, so every one of those
  # links dangles until the repo exists.
  systemd.services.dotfiles-clone = {
    description = "Clone the dotfiles repo the home-manager symlinks point into";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    unitConfig.ConditionPathExists = "!/home/${user}/dotfiles";
    serviceConfig = {
      Type = "oneshot";
      User = user;
      ExecStart = "${pkgs.git}/bin/git clone https://github.com/gauthier-se/dotfiles.git /home/${user}/dotfiles";
    };
  };

  # Without tpm the shared tmux.conf still loads, it just silently lacks its plugins.
  systemd.services.tmux-tpm-clone = {
    description = "Clone tmux's plugin manager, which the shared tmux.conf runs";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" "dotfiles-clone.service" ];
    wants = [ "network-online.target" ];
    unitConfig.ConditionPathExists = "!/home/${user}/.tmux/plugins/tpm";
    serviceConfig = {
      Type = "oneshot";
      User = user;
      ExecStart = "${pkgs.git}/bin/git clone https://github.com/tmux-plugins/tpm /home/${user}/.tmux/plugins/tpm";
      # Best effort: `prefix + I` does the same, so a failure must not fail the unit.
      ExecStartPost = "-${pkgs.writeShellScript "tpm-install-plugins" ''
        export PATH=${pkgs.tmux}/bin:${pkgs.git}/bin:$PATH
        tmux -f /home/${user}/.config/tmux/tmux.conf new-session -d -s tpm-install
        /home/${user}/.tmux/plugins/tpm/scripts/install_plugins.sh
        tmux kill-session -t tpm-install
      ''}";
    };
  };

  nix.settings.trusted-users = [ "root" user ]; # the box builds its own closures

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
  nix.optimise.automatic = true;

  environment.systemPackages = with pkgs; [
    vim
    git
  ];
}
