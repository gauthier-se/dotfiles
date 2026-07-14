{ config, pkgs, ... }:

let
  dotfiles = "${config.home.homeDirectory}/dotfiles";
  link = path: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${path}";
in
{
  imports = [ ./common.nix ];

  home.packages = with pkgs; [
    jankyborders # started by aerospace
  ];

  xdg.configFile = {
    "aerospace".source = link "configs/aerospace/.config/aerospace";
    "alacritty/alacritty.toml".source = link "configs/alacritty/.config/alacritty/alacritty.toml";
  };
}
