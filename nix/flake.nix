{
  description = "Declarative macOS configuration — nix-darwin + home-manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager, nix-homebrew }:
  let
    user = "segau";
  in {
    # Name matches LocalHostName: darwin-rebuild picks it up automatically.
    darwinConfigurations."segaus-MacBook-Pro" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      specialArgs = { inherit inputs user; };
      modules = [
        ./darwin/configuration.nix

        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            enable = true;
            inherit user;
          };
        }

        home-manager.darwinModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "before-nix";
            users.${user} = import ./home/home.nix;
          };
        }
      ];
    };

    # Per-project devshells: nix flake init -t ~/dotfiles/nix#python
    templates = {
      python = {
        path = ./templates/python;
        description = "Python devshell (uv + venv)";
      };
      node = {
        path = ./templates/node;
        description = "Node.js + pnpm devshell";
      };
      go = {
        path = ./templates/go;
        description = "Go devshell";
      };
      java = {
        path = ./templates/java;
        description = "Java devshell (JDK + Maven)";
      };
    };
  };
}
