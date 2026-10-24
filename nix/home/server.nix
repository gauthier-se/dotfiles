{ pkgs, ... }:

# Headless homelab box: the shell, editor and tooling all come from common.nix,
# and there is nothing graphical to add.
{
  imports = [ ./common.nix ];

  # No display here, so Claude gets its own headless Chromium. The nixpkgs build
  # points Playwright at a Nix-built browser: the ones Playwright downloads
  # itself don't run on NixOS. Screenshots and snapshots go to /tmp, or every
  # repo Claude browses from grows an untracked .playwright-mcp/.
  programs.claude-code = {
    enable = true;
    mcpServers.playwright = {
      command = "${pkgs.playwright-mcp}/bin/playwright-mcp";
      args = [ "--headless" "--output-dir" "/tmp/playwright-mcp" ];
    };
  };

  # The sessionizer (prefix + f) lists this directory, so it has to exist even empty.
  home.file."repos/.keep".text = "";
}
