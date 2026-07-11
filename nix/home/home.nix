{ config, pkgs, ... }:

let
  dotfiles = "${config.home.homeDirectory}/dotfiles";
  # Symlinks into the repo (editable without rebuild, shared with Ansible/Arch)
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
    yazi
    zoxide
    # Git & TUIs
    git
    gh
    delta
    lazygit
    lazydocker
    # Editors & multiplexer
    neovim
    tmux
    tmuxinator
    # Baseline runtime — projects use their own version via devshells
    nodejs_22
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  home.file = {
    ".zshrc".source = link "configs/zsh/.zshrc";
    ".zsh_aliases".source = link "configs/zsh/.zsh_aliases";
    ".zsh_functions".source = link "configs/zsh/.zsh_functions";
    ".gitconfig".source = link "configs/git/.gitconfig";
    "moonfly.gitconfig".source = link "configs/git/moonfly.gitconfig";
    ".vimrc".source = link "configs/vim/.vimrc";
    ".local/bin/tmux-sessionizer.sh".source = link "configs/tmux/.local/bin/tmux-sessionizer.sh";
  };

  xdg.configFile = {
    "aerospace".source = link "configs/aerospace/.config/aerospace";
    "alacritty".source = link "configs/alacritty/.config/alacritty";
    "nvim".source = link "configs/nvim/.config/nvim";
    "tmux".source = link "configs/tmux/.config/tmux";
    "tmuxinator".source = link "configs/tmux/.config/tmuxinator";
    "lazygit".source = link "configs/lazygit/.config/lazygit";
    "lazydocker".source = link "configs/lazydocker/.config/lazydocker";
    "yazi".source = link "configs/yazi/.config/yazi";
  };
}
