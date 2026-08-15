{ config, pkgs, ... }:

let
  dotfiles = "${config.home.homeDirectory}/dotfiles";
  # Symlinks into the repo (editable without a rebuild)
  link = path: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${path}";
in
{
  home.stateVersion = "25.05";

  home.packages = with pkgs; [
    # Everyday CLI
    bat
    btop
    fastfetch
    fd
    fzf
    httpie
    jq
    ripgrep
    tlrc
    wget
    zoxide
    # Git & TUIs
    git
    gh
    delta
    lazygit
    lazydocker
    devenv
    # Editors & multiplexer
    neovim
    tmux
    tmuxinator
    # Editor tooling that isn't project-specific (project LSPs live in devshells)
    lua-language-server # nvim config
    stylua
    nixd # nix files
    # Baseline runtime — projects use their own version via devshells.
    # Node's *active* LTS: 22 is in maintenance until April 2027, and 26 only
    # becomes an LTS at the end of October 2026.
    nodejs_24
    # Learning
    (bootdev-cli.overrideAttrs (_: rec {
      version = "1.31.1";
      src = fetchFromGitHub {
        owner = "bootdotdev";
        repo = "bootdev";
        tag = "v${version}";
        hash = "sha256-0koZYMQxCHPtB44OYhiD9+nYAyHWXbyQd2xhdqnOqEw=";
      };
      vendorHash = "sha256-ZDioEU5uPCkd+kC83cLlpgzyOsnpj2S7N+lQgsQb8uY=";
      # This one test shells out to /bin/sleep, which exists inside the darwin
      # build sandbox and not inside the Linux one — so the package builds on the
      # Mac and fails on every NixOS machine. Skipping it keeps the other suites.
      checkFlags = [ "-skip" "^TestGetLatestVersionHasOverallTimeout$" ];
    }))
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  home.file = {
    ".zshrc".source = link "configs/zsh/.zshrc";
    ".zsh_aliases".source = link "configs/zsh/.zsh_aliases";
    ".gitconfig".source = link "configs/git/.gitconfig";
    "moonfly.gitconfig".source = link "configs/git/moonfly.gitconfig";
    ".vimrc".source = link "configs/vim/.vimrc";
    ".local/bin/tmux-sessionizer.sh".source = link "configs/tmux/.local/bin/tmux-sessionizer.sh";
    ".local/bin/obsidian-vault-setup".source = link "configs/obsidian/vault-setup.sh";
  };

  # alacritty is linked per-OS (darwin.nix / linux.nix): the laptop overrides
  # the font size for its 1.5 display scale.
  xdg.configFile = {
    "nvim".source = link "configs/nvim/.config/nvim";
    "tmux".source = link "configs/tmux/.config/tmux";
    "tmuxinator".source = link "configs/tmux/.config/tmuxinator";
    "lazygit".source = link "configs/lazygit/.config/lazygit";
    "lazydocker".source = link "configs/lazydocker/.config/lazydocker";
  };
}
