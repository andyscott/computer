{
  description = "the machine(s)";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      rev = "0d15ddddc54e04bc34065a9e47024a2c90063f47";
    };
    home-manager = {
      type = "github";
      owner = "nix-community";
      repo = "home-manager";
      rev = "95201931f2e733705296d1d779e70793deaeb909";
    };
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ { self, flake-utils, nixpkgs, home-manager, darwin }:
    with nixpkgs.lib;
    let
      nixpkgsConfig = {
        config.allowUnfree = true;
      };

      system-agnostic = {
        overlays = {
          apple-m1-x86 = final: prev: optionalAttrs (prev.stdenv.system == "aarch64-darwin") {
            x86 = import inputs.nixpkgs {
              system = "x86_64-darwin";
              inherit (nixpkgsConfig) config;
            };
          };
        };
      };

      system-dependent = flake-utils.lib.eachDefaultSystem (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            inherit (nixpkgsConfig) config;
            overlays = [
              system-agnostic.overlays.apple-m1-x86
            ];
          };

        in
        nixpkgs.lib.optionalAttrs (strings.hasSuffix "-darwin" system) rec {
          packages.darwinConfigurations.default =
            let utils = import ./utils.nix { inherit (nixpkgs) lib; };
            in darwin.lib.darwinSystem {
              inherit system;
              modules = [
                home-manager.darwinModules.home-manager
                {
                  home-manager.useGlobalPkgs = true;
                  home-manager.useUserPackages = true;
                  home-manager.extraSpecialArgs = { inherit inputs pkgs; };
                }
              ] ++ (
                utils.discover-modules' ./modules import
              );
            };

          defaultPackage = packages.darwinConfigurations.default.system;
          devShells.default = pkgs.callPackage ./dev-shell-default.nix { };
        });

    in
    system-dependent // system-agnostic;
}
