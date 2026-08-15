{
  description = "Python devshell (uv + venv)";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
    let
      forAllSystems = nixpkgs.lib.genAttrs [ "aarch64-darwin" "x86_64-linux" "aarch64-linux" ];
    in
    {
      devShells = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              python313
              uv
              basedpyright
              ruff
            ];

            shellHook = ''
              test -d .venv || uv venv --quiet
              source .venv/bin/activate
            '';
          };
        });
    };
}
