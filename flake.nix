{
  description = "the machine(s)";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-darwin.url = "github:lnl7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs @ { self
    , flake-utils
    , nixpkgs
    , home-manager
    , nix-darwin
    }:
    let
      utils = import ./utils.nix { inherit (nixpkgs) lib; };
      nixpkgsConfig = {
        config.allowUnfree = true;
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
      devShells.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          pre-commit
          git
          nixpkgs-fmt
          shellcheck
          statix
          yamlfmt
        ];
      };
    })
    ) // {
      darwinConfigurations."com-62765" = nix-darwin.lib.darwinSystem {
        specialArgs = { inherit inputs; };
        modules = [
          home-manager.darwinModules.home-manager
          { nixpkgs = nixpkgsConfig; }
          ./modules/host/darwin-com-62765.nix
        ];
      };
    };
}
