{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    systems.url = "github:nix-systems/default";

    parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    gh-actions = {
      url = "github:nix-community/nix-github-actions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    inputs.parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;

      imports = with inputs; [ parts.flakeModules.easyOverlay ];

      flake.githubActions = inputs.gh-actions.lib.mkGithubMatrix {
        checks = inputs.nixpkgs.lib.getAttrs [ "x86_64-linux" ] inputs.self.checks;
      };

      perSystem =
        { pkgs, config, ... }:
        let
          packageName = "vscode-langservers-extracted";
          pkg = builtins.getAttr packageName config.packages;
        in
        {
          packages = {
            default = pkg;
            ${packageName} = pkgs.callPackage ./default.nix { };
          };

          overlayAttrs.${packageName} = pkg;

          checks.default = pkg;
        };
    };

  nixConfig = {
    extra-substituters = [ "https://arunim.cachix.org" ];
    extra-trusted-public-keys = [ "arunim.cachix.org-1:J07zWDguRFHQSio/VmTT8us5EelRNlDTFkbNeFel0xM=" ];
  };
}
