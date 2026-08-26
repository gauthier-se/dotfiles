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
    atuin # shell history: ctrl-r search, sqlite-backed
    bat
    btop
    fastfetch
    fd
    fzf
    httpie
    jq
    navi # interactive cheatsheets, ctrl-g
    ripgrep
    tlrc
    wget
    zoxide
    # CLI tools & fun
    ccusage # token usage analysis
    # Git & TUIs
    git
    gh
    delta
    lazygit
    lazydocker
    glow
    devenv
    # Editors & multiplexer
    neovim
    tmux
    tmuxinator
    # Editor tooling that isn't project-specific (project LSPs live in devshells)
    lua-language-server # nvim config
    stylua
    nixd # nix files
    # Baseline runtime: projects use their own version via devshells
    nodejs_24
    # Agent CLI (unfree: the system configs set nixpkgs.config.allowUnfree)
    antigravity-cli
    # Learning
    (bootdev-cli.overrideAttrs (_: rec {
      version = "1.32.1";
      src = fetchFromGitHub {
        owner = "bootdotdev";
        repo = "bootdev";
        tag = "v${version}";
        hash = "sha256-DScpeUQdkzJy+RVkA8ZmGzp5Z9YzkvZViCoov64WAJk=";
      };
      vendorHash = "sha256-ZDioEU5uPCkd+kC83cLlpgzyOsnpj2S7N+lQgsQb8uY=";
      # That test shells out to /bin/sleep: present in the darwin build sandbox,
      # absent from the Linux one, so the package fails to build on NixOS.
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
    "atuin/config.toml".source = link "configs/atuin/.config/atuin/config.toml";
    "navi".source = link "configs/navi/.config/navi";
  };
}
