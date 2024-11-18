{
  description = "the machine(s)";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-darwin.url = "github:lnl7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-darwin-emacs.url = "github:c4710n/nix-darwin-emacs";
    nix-darwin-emacs.inputs.nixpkgs.follows = "nixpkgs";
    git-linear.url = "github:andyscott/git-linear";
    git-linear.inputs.nixpkgs.follows = "nixpkgs";
    emacs-overlay.url = "github:nix-community/emacs-overlay";
    emacs-overlay.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs @ { self
    , flake-utils
    , nixpkgs
    , home-manager
    , nix-darwin
    , nix-darwin-emacs
    , git-linear
    , emacs-overlay
    }:
    let
      utils = import ./utils.nix { inherit (nixpkgs) lib; };
      nixpkgsConfig = {
        config.allowUnfree = true;
        overlays = [
          nix-darwin-emacs.overlays.emacs
          emacs-overlay.overlays.package
        ];
      };
    in
    (flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        inherit system;
        inherit (nixpkgsConfig) config;
      };
    in
    {
      devShells.default = pkgs.callPackage ./dev-shell-default.nix { };
    })
    ) // {
      darwinConfigurations."Andys-MacBook-Pro" = nix-darwin.lib.darwinSystem {
        specialArgs = { inherit inputs; };
        modules = [
          {
            nixpkgs.hostPlatform = "aarch64-darwin";
            system.stateVersion = 5;
          }
          home-manager.darwinModules.home-manager
          {
            nixpkgs = nixpkgsConfig;
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
          }
        ] ++ (
          utils.discover-modules' ./modules import
        );
      };
    };
}
