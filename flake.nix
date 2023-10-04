{
  description = "the machine(s)";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      rev = "3a50c2dac5d0edd8b1e3be5894217db793a7a7a3";
    };
    home-manager = {
      type = "github";
      owner = "nix-community";
      repo = "home-manager";
      rev = "8aef005d44ee726911e9f793495bb40f2fbf5a05";
    };
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    git-linear.url = "github:andyscott/git-linear";
    git-linear.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ { self, flake-utils, nixpkgs, home-manager, darwin, git-linear }:
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
              (self: super: {
                git-linear = git-linear.packages.${system}.default;
              })
            ];
          };

        in
        nixpkgs.lib.optionalAttrs (strings.hasSuffix "-darwin" system) rec {
          packages.darwinConfigurations.default =
            let
              utils = import ./utils.nix { inherit (nixpkgs) lib; };

              linuxSystem = builtins.replaceStrings [ "darwin" ] [ "linux" ] system;

              darwin-builder = nixpkgs.lib.nixosSystem {
                system = linuxSystem;

                modules = [
                  "${nixpkgs}/nixos/modules/profiles/macos-builder.nix"
                  { virtualisation.host.pkgs = pkgs; }
                ];
              };

            in
            darwin.lib.darwinSystem {
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
