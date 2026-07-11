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
      # Effectively disable the Dock: auto-hide with a huge reveal delay
      autohide = true;
      autohide-delay = 1000.0;
      autohide-time-modifier = 0.0;
      show-recents = false;
      persistent-apps = [ ];
    };
    finder = {
      AppleShowAllExtensions = true;
      ShowPathbar = true;
      FXPreferredViewStyle = "Nlsv";
      CreateDesktop = false; # no icons/folders on the desktop
    };
    NSGlobalDomain = {
      KeyRepeat = 2;
      InitialKeyRepeat = 15;
      NSAutomaticSpellingCorrectionEnabled = false;
      NSAutomaticCapitalizationEnabled = false;
      _HIHideMenuBar = true; # auto-hide the menu bar (reveal by pushing the cursor to the top)
    };
  };

  # Apply the wallpaper from the repo on every rebuild
  system.activationScripts.postActivation.text = ''
    sudo -u gauthierseyzeriat /usr/bin/osascript -e 'tell application "System Events" to tell every desktop to set picture to "/Users/gauthierseyzeriat/dotfiles/wallpapers/wallpaper.jpg"' || true
  '';

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
    brews = [ "mas" ];
    casks = [
      # Desktop
      "nikitabobko/tap/aerospace"
      "alacritty"
      "raycast"
      # Apps
      "brave-browser"
      "obsidian"
      "orbstack"
      "discord"
      "tailscale-app"
      "claude"
      "figma"
      "linear"
      "protonvpn"
      "bruno"
      "termius"
      "microsoft-teams"
      "microsoft-word"
      # "microsoft-excel" "microsoft-powerpoint" "microsoft-outlook"
      # Gaming & music
      "openemu"
      "dolphin"
      "steam"
      "battle-net"
      "native-access" # installs Guitar Rig 7 and other NI products
    ];
    # Mac App Store (needs to be signed in)
    masApps = {
      "Dashlane" = 517914548;
    };
  };
}
