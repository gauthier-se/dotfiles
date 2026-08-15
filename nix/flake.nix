{
  description = "Declarative macOS (nix-darwin) & NixOS configurations — shared home-manager";

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
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager, nix-homebrew, nixos-hardware, disko }:
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
            users.${user} = import ./home/darwin.nix;
          };
        }
      ];
    };

    # Laptop: nixos-rebuild switch --flake ~/dotfiles/nix#laptop
    nixosConfigurations."laptop" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs user; };
      modules = [
        ./nixos/configuration.nix

        # Huawei MateBook 14 2020 AMD (KLVL-WFH9) — no dedicated profile in
        # nixos-hardware, so the generic Ryzen/Radeon laptop ones:
        nixos-hardware.nixosModules.common-cpu-amd
        nixos-hardware.nixosModules.common-cpu-amd-pstate
        nixos-hardware.nixosModules.common-gpu-amd
        nixos-hardware.nixosModules.common-pc-laptop
        nixos-hardware.nixosModules.common-pc-ssd

        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "before-nix";
            users.${user} = import ./home/linux.nix;
          };
        }
      ];
    };

    # Dev box: nix run github:nix-community/nixos-anywhere -- \
    #   --flake ~/dotfiles/nix#devbox --build-on remote root@10.10.20.20
    nixosConfigurations."devbox" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs user; };
      modules = [
        ./nixos/devbox.nix

        disko.nixosModules.disko
        ./nixos/devbox-disko.nix

        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "before-nix";
            users.${user} = import ./home/server.nix;
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
