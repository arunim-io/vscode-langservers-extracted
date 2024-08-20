{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";
    parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs:
    inputs.parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;

      perSystem =
        { pkgs, ... }:
        {
          packages.default = pkgs.callPackage ./default.nix { };

          devShells.default = pkgs.mkShell {
            buildInputs = with pkgs; [
              git
              python3
              nodejs
              yarn
              nodePackages.gulp-cli
            ];
          };
        };
    };
}
