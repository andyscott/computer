{
  description = "the machine(s)";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    git-linear.url = "github:andyscott/git-linear";
    git-linear.inputs.nixpkgs.follows = "nixpkgs";
    emacs-overlay.url = "github:nix-community/emacs-overlay";
    emacs-overlay.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ { self, flake-utils, nixpkgs, home-manager, darwin, git-linear, emacs-overlay }:
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
              (import emacs-overlay)
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
