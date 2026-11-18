{ pkgs, user, ... }:

# Agent factory: Proxmox VM 270 on the Agents VLAN (70), provisioned by OpenTofu
# in the homelab repo and installed with nixos-anywhere. ADR-0019 in the private
# docs makes it an untrusted zone: it reaches the Internet and nothing else in
# the lab, holds no lab credential, and is not an operator station.
#
# Nothing runs Claude on this host. Two unprivileged users each run their own
# rootless Podman: `agents` (per-task dev containers, driven by herdr from the
# Mac) and `lifeos` (one long-lived container). Neither sees the other's
# containers, and there is no docker group to make either of them root.
let
  # The Mac. No account has a password, so this list is the only way in.
  authorizedKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILuL65N5OYZw+yJcghWu7aIsocUjcNuYbedgDsUZu3eI gauthier"
  ];

  # linger keeps the user's systemd instance, and with it the containers, alive
  # when no session is open: rootless Podman stops them otherwise.
  containerUser = description: {
    isNormalUser = true;
    inherit description;
    linger = true;
    autoSubUidGidRange = true;
    openssh.authorizedKeys.keys = authorizedKeys;
  };
in
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "26.11";

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
  # interface name depends on the emulated bus.
  networking.hostName = "factory";
  networking.useDHCP = false;
  networking.useNetworkd = true;
  networking.nameservers = [ "10.10.70.1" ];

  systemd.network.networks."10-lan" = {
    matchConfig.Name = "en*";
    address = [ "10.10.70.10/24" ];
    routes = [ { Gateway = "10.10.70.1"; } ];
    linkConfig.RequiredForOnline = "routable";
  };

  # No Tailscale client on purpose: on the tailnet this machine would see the
  # Mac and the phone. The Mac reaches it through the route OPNsense announces.
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
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

  # The admin account: rebuilds and maintenance, no containers of its own.
  users.users.${user} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = authorizedKeys;
  };
  users.users.agents = containerUser "Coding agents, one dev container per task";
  users.users.lifeos = containerUser "LifeOS, one long-lived container";

  programs.zsh.enable = true;

  # There is no password to type, so sudo must not ask for one.
  security.sudo.wheelNeedsPassword = false;

  # Rootless Podman. dockerCompat gives the devcontainer CLI the `docker` it
  # looks for: a wrapper around podman, not a daemon, and no group behind it.
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
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
    gh
    jq
    tmux
    herdr # the Mac's herdr drives panes here over SSH
    devcontainer # @devcontainers/cli, run against rootless Podman
  ];
}
