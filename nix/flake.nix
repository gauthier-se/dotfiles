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

  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager, nix-homebrew }: {
    # Name matches LocalHostName: darwin-rebuild picks it up automatically.
    darwinConfigurations."Gauthiers-MacBook-Pro" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      specialArgs = { inherit inputs; };
      modules = [
        ./darwin/configuration.nix

        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            enable = true;
            user = "gauthierseyzeriat";
            # Take over the existing Homebrew installation (/opt/homebrew)
            autoMigrate = true;
          };
        }

        home-manager.darwinModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "before-nix";
            users.gauthierseyzeriat = import ./home/home.nix;
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
