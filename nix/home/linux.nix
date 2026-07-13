{ config, pkgs, ... }:

let
  dotfiles = "${config.home.homeDirectory}/dotfiles";
  link = path: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${path}";
in
{
  imports = [ ./common.nix ];

  home.packages = with pkgs; [
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
  ];

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
    "waybar".source = link "configs/waybar/.config/waybar";
    "fuzzel".source = link "configs/fuzzel/.config/fuzzel";
    "mako".source = link "configs/mako/.config/mako";
  };
}
