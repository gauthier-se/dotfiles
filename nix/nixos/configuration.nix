{ pkgs, user, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "25.05";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Wifi/bluetooth firmware (Intel & co) — without this, often no wifi at all
  hardware.enableRedistributableFirmware = true;

  # Compressed swap in RAM: no swap partition needed
  zramSwap.enable = true;

  # Must match the attribute name in flake.nix (nixosConfigurations."laptop")
  networking.hostName = "laptop";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Paris";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "fr"; # AZERTY in TTYs and tuigreet

  users.users.${user} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" ];
    shell = pkgs.zsh;
  };
  programs.zsh.enable = true;

  # --- Desktop: Hyprland, no display server, no desktop environment ---

  programs.hyprland.enable = true; # also wires up xdg portals
  programs.dconf.enable = true; # backend for the dark-mode preference (home-manager dconf.settings)

  # Minimal TUI login screen, then straight into Hyprland
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd Hyprland";
      user = "greeter";
    };
  };

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
  ];

  # --- Hardware ---

  # Audio
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };
  security.rtkit.enable = true;

  hardware.bluetooth.enable = true; # pair via bluetoothctl

  # Laptop power management
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;

  # --- Services ---

  services.tailscale.enable = true;

  environment.systemPackages = with pkgs; [
    vim
    git
  ];
}
