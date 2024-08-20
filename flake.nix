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

      imports = with inputs; [ parts.flakeModules.easyOverlay ];

      perSystem =
        { pkgs, config, ... }:
        {
          packages = {
            default = config.packages.vscode-langservers-extracted;
            vscode-langservers-extracted = pkgs.callPackage ./default.nix { };
          };

          overlayAttrs = {
            inherit (config.packages) vscode-langservers-extracted;
          };

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
