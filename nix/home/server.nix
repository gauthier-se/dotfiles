{ pkgs, ... }:

# Home config for the headless homelab box. Everything that makes the shell feel
# like the other two machines — zsh, nvim, tmux, git, lazygit, fzf/fd/rg, direnv
# and the devshell workflow — comes from common.nix; there is nothing graphical
# to add here, because this machine is only ever reached over SSH.
{
  imports = [ ./common.nix ];

  home.packages = with pkgs; [
    # The reason the box exists: an agent with a terminal, running next to the
    # code rather than on the laptop that closes at the end of the day.
    claude-code
  ];
}
