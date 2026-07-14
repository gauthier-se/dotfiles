{ config, pkgs, ... }:

let
  dotfiles = "${config.home.homeDirectory}/dotfiles";
  link = path: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${path}";
in
{
  imports = [ ./common.nix ];

  home.packages = with pkgs; [
    # Terminal (a Homebrew cask on darwin, a package here)
    alacritty
    # Desktop (Hyprland session — started by exec-once in hyprland.conf)
    waybar
    fuzzel
    mako # notifications
    swaybg # wallpaper
    # Wayland utilities
    wl-clipboard
    grim # screenshot
    slurp # region selection for grim
    brightnessctl
    playerctl
    pamixer
    # GUI apps
    brave
    obsidian
    proton-vpn
  ];

  # System-wide dark mode: modern apps (Electron, GTK4) read it through the
  # settings portal, legacy GTK3 apps through the theme.
  dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
    gtk4.theme = null; # GTK4/libadwaita follows color-scheme, no forced theme
  };

  # The HM module handles the plumbing (systemd session, env vars, portals wiring);
  # the real config stays a hot-reloadable symlink into the repo via `source =`.
  wayland.windowManager.hyprland = {
    enable = true;
    # hyprland itself comes from the NixOS module (programs.hyprland.enable)
    package = null;
    portalPackage = null;
    configType = "hyprlang"; # classic hyprland.conf syntax, not the new Lua config
    extraConfig = ''
      source = ${dotfiles}/configs/hypr/.config/hypr/hyprland.conf
    '';
  };

  xdg.configFile = {
    "alacritty/alacritty.toml".source = link "configs/alacritty/.config/alacritty/linux.toml";
    "waybar".source = link "configs/waybar/.config/waybar";
    "fuzzel".source = link "configs/fuzzel/.config/fuzzel";
    "mako".source = link "configs/mako/.config/mako";
  };
}
