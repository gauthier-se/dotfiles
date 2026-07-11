{ pkgs, ... }:

{
  # Nix itself is managed by the Determinate installer, not by nix-darwin.
  nix.enable = false;

  system.stateVersion = 6;
  system.primaryUser = "gauthierseyzeriat";
  nixpkgs.hostPlatform = "aarch64-darwin";

  users.users.gauthierseyzeriat.home = "/Users/gauthierseyzeriat";

  # Adds Nix paths to zsh's PATH
  programs.zsh.enable = true;

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
  ];

  # JankyBorders as a launchd service (replaces the exec-and-forget in aerospace.toml)
  services.jankyborders = {
    enable = true;
    active_color = "0xff626262";
    inactive_color = "0xff262626";
    width = 8.0;
  };

  system.defaults = {
    dock = {
      autohide = true;
      show-recents = false;
    };
    finder = {
      AppleShowAllExtensions = true;
      ShowPathbar = true;
      FXPreferredViewStyle = "Nlsv";
    };
    NSGlobalDomain = {
      KeyRepeat = 2;
      InitialKeyRepeat = 15;
      NSAutomaticSpellingCorrectionEnabled = false;
      NSAutomaticCapitalizationEnabled = false;
    };
  };

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = false;
      # ⚠️ "none" while still on the current system (233 formulae installed).
      # After the clean reinstall, switch to "zap" so brew only contains
      # what is declared here.
      cleanup = "none";
    };
    taps = [ "nikitabobko/tap" ];
    casks = [
      "nikitabobko/tap/aerospace"
      "alacritty"
      "alt-tab"
      "maccy"
      "stats"
      # GUI apps to reinstall as needed after the clean install:
      # "brave-browser" "obsidian" "raycast" "orbstack" "discord"
      # "tailscale" "dashlane" "claude" "figma" "linear-linear"
    ];
  };
}
