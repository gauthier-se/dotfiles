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

  xdg.configFile = {
    "hypr".source = link "configs/hypr/.config/hypr";
    "waybar".source = link "configs/waybar/.config/waybar";
    "fuzzel".source = link "configs/fuzzel/.config/fuzzel";
    "mako".source = link "configs/mako/.config/mako";
  };
}
