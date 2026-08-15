{ pkgs, ... }:

# Headless homelab box: the shell, editor and tooling all come from common.nix,
# and there is nothing graphical to add.
{
  imports = [ ./common.nix ];

  home.packages = with pkgs; [
    claude-code
  ];

  # The sessionizer (prefix + f) lists this directory, so it has to exist even empty.
  home.file."repos/.keep".text = "";
}
