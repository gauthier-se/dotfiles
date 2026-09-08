{ config, pkgs, ... }:

let
  dotfiles = "${config.home.homeDirectory}/dotfiles";
  link = path: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${path}";
in
{
  imports = [ ./common.nix ];

  home.packages = with pkgs; [
    # Terminal. Not a cask: Homebrew disabled the alacritty cask in 09/2026
    # (it no longer passes the macOS Gatekeeper check), so it stopped being
    # upgradable. The nixpkgs build lands in ~/Applications/Home Manager Apps.
    alacritty
    jankyborders # started by aerospace
  ];

  xdg.configFile = {
    "aerospace".source = link "configs/aerospace/.config/aerospace";
    "alacritty/alacritty.toml".source = link "configs/alacritty/.config/alacritty/alacritty.toml";
  };
}
