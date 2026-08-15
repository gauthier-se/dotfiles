{ config, pkgs, user, ... }:

# Homelab dev box — Proxmox VM 220 on the Servers VLAN (10.10.20.20), declared
# in the homelab repo (`opentofu/locals.tf`) and installed with nixos-anywhere.
# Headless on purpose: it is reached over SSH from the Mac's terminal and from
# Termius on the phone, and it runs the same shell, editor and tooling as the
# two desktop machines because it imports the same home-manager config.
let
  # The only credential that opens this machine: password authentication is off
  # everywhere below, and no account has a password to begin with. Add the
  # phone's key here (Termius → Keychain → generate, then paste the public half)
  # and rebuild; there is no other way in, by design.
  authorizedKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILuL65N5OYZw+yJcghWu7aIsocUjcNuYbedgDsUZu3eI gauthier"
  ];
in
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true; # claude-code

  system.stateVersion = "25.05";

  # --- Boot & virtual hardware ---
  #
  # No hardware-configuration.nix: disko declares the filesystems, and a guest
  # has no hardware to detect beyond the virtio devices Proxmox gives it.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.availableKernelModules = [ "virtio_pci" "virtio_blk" "virtio_scsi" "ahci" "sd_mod" "sr_mod" ];

  # Lets the hypervisor report the guest's address and shut it down cleanly
  # instead of pulling the power (Proxmox waits on this agent).
  services.qemuGuest.enable = true;

  # Compressed swap in RAM: a Nix build that overshoots the VM's memory slows
  # down instead of being killed, and the guest needs no swap disk for it.
  zramSwap.enable = true;

  time.timeZone = "Europe/Paris";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "fr"; # only ever seen through the Proxmox console

  # --- Network ---
  #
  # Static, and declared here rather than taken from cloud-init: NixOS never
  # reads the cloud-init drive Proxmox attaches, so the address in the OpenTofu
  # catalogue and the one below have to say the same thing (10.10.20.20/24,
  # docs/network/addressing.md in the homelab repo).
  #
  # Matched on `en*` instead of a fixed name because the interface a guest gets
  # depends on the emulated bus (ens18, enp0s18…): pinning the wrong one leaves
  # the machine unreachable with no console error.
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
    # Tailscale's own port, and its interface treated as trusted — the tailnet
    # is how the phone reaches this box from outside the house.
    allowedUDPPorts = [ config.services.tailscale.port ];
    trustedInterfaces = [ "tailscale0" ];
    # Strict reverse-path filtering drops the tailnet's own return traffic.
    checkReversePath = "loose";
  };

  # `tailscale up` once, by hand, after the install: the box then answers on its
  # tailnet name from anywhere, without depending on the OPNsense subnet router
  # staying up. The Servers VLAN is advertised there too, so this is a second
  # path to the same machine rather than the only one.
  services.tailscale.enable = true;

  # --- Access ---

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      # Keeps `nixos-anywhere` and `nixos-rebuild --target-host root@devbox`
      # working; with password auth off it means "key only", never a password.
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

  # No account here has a password, so sudo cannot ask for one — it would lock
  # the only user out of `wheel` on a machine whose sole credential is a key.
  security.sudo.wheelNeedsPassword = false;

  # --- Dev environment ---

  # `lazydocker` comes with the shared home config, and a dev box is where
  # containers get built and thrown away.
  virtualisation.docker = {
    enable = true;
    autoPrune = {
      enable = true;
      dates = "weekly";
    };
  };

  # home-manager points nvim/tmux/zsh at ~/dotfiles through out-of-store
  # symlinks, so they stay editable without a rebuild — which means every one of
  # them dangles until that repo exists. On a machine installed from scratch it
  # does not, so clone it once, before the first login rather than after the
  # first confused one. Switch the remote to SSH after `gh auth login` to push.
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

  # Building the system on the box itself (`nixos-rebuild` over SSH, or
  # nixos-anywhere's `--build-on remote`) needs the user to be trusted by the
  # daemon — a Mac on aarch64 cannot produce these x86_64 closures anyway.
  nix.settings.trusted-users = [ "root" user ];

  # Every rebuild keeps the generation it replaced. Left alone on a 64 GB disk
  # that fills up quietly; the collection window is long enough to still roll
  # back to a build from last week.
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
