{ pkgs, user, ... }:

{
  # Nix itself is managed by the Determinate installer, not by nix-darwin.
  nix.enable = false;

  system.stateVersion = 6;
  system.primaryUser = user;
  nixpkgs.hostPlatform = "aarch64-darwin";

  users.users.${user}.home = "/Users/${user}";

  # Adds Nix paths to zsh's PATH
  programs.zsh.enable = true;

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
  ];

  # JankyBorders is started by aerospace (after-startup-command) — the launchd
  # service kept dying with EX_CONFIG on this machine.

  system.defaults = {
    CustomUserPreferences = {
      # Raycast on Cmd+Space (49 = space keycode)
      "com.raycast.macos".raycastGlobalHotkey = "Command-49";
      # Disable Spotlight's Cmd+Space (symbolic hotkey 64) so Raycast owns it
      "com.apple.symbolichotkeys".AppleSymbolicHotKeys."64".enabled = false;
    };
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
      AppleShowAllFiles = true; # show hidden files (dotfiles)
      ShowPathbar = true;
      FXPreferredViewStyle = "Nlsv";
      CreateDesktop = false; # no icons/folders on the desktop
    };
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      KeyRepeat = 2;
      InitialKeyRepeat = 15;
      NSAutomaticSpellingCorrectionEnabled = false;
      NSAutomaticCapitalizationEnabled = false;
    };
  };

  # Apply the wallpaper from the repo on every rebuild
  system.activationScripts.postActivation.text = ''
    sudo -u ${user} /usr/bin/osascript -e 'tell application "System Events" to tell every desktop to set picture to "/Users/${user}/dotfiles/wallpapers/wallpaper.jpg"' || true
  '';

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = false;
      # Fresh install: brew only ever contains what is declared here.
      cleanup = "zap";
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
      "firefox"
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
      "logi-options+" # Logitech keyboard & mouse (Logi Options+)
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
