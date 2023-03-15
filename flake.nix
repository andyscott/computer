{
  description = "the machine(s)";

  inputs = {
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

  outputs = inputs @ { self, nixpkgs, home-manager, darwin }:
    let
      nixpkgsConfig = {
        config.allowUnfree = true;
      };
    in
    with nixpkgs.lib;    rec {
      overlays = {
        apple-m1-x86 = final: prev: optionalAttrs (prev.stdenv.system == "aarch64-darwin") {
          x86 = import inputs.nixpkgs {
            system = "x86_64-darwin";
            inherit (nixpkgsConfig) config;
          };
        };
      };

      darwinConfigurations.default =
        let
          system = "aarch64-darwin";

          pkgs = import nixpkgs {
            inherit system;
            inherit (nixpkgsConfig) config;
            overlays = [
              self.overlays.apple-m1-x86
            ];
          };
          utils = import ./utils.nix { inherit (nixpkgs) lib; };

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

      defaultPackage.aarch64-darwin = darwinConfigurations.default.system;
    };
}
