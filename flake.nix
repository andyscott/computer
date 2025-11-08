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
      nixpkgsConfig = {
        config.allowUnfree = true;
      };
    in
    (flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import ./pkgs {
        inherit (nixpkgsConfig) config;
        inherit system nixpkgs;
      };
    in
    {
      packages = {
        inherit (pkgs) google-meet-escape-artist trackpad-haptic zing;
      };
      devShells.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          just
          (pre-commit.mkWithPath [
            coreutils
            clang-tools
            git
            nixpkgs-fmt
            shellcheck
            statix
            yamlfmt
          ])
        ];
      };
      darwinConfigurations =
        with nixpkgs.lib; let
          discover-modules = dir: prefix: f:
            pipe (builtins.readDir dir) [
              (filterAttrs (n: _: strings.hasPrefix prefix n))
              (mapAttrs' (n: v:
                let path = "${toString dir}/${n}"; in
                if v == "directory" && pathExists "${path}/default.nix"
                then nameValuePair n (f path)
                else if v == "regular" && n != "default.nix" && strings.hasSuffix ".nix" n
                then nameValuePair (strings.removeSuffix ".nix" n) (f path)
                else nameValuePair "" null
              ))
              (filterAttrs (n: v: v != null))
              (mapAttrs' (n: v: (nameValuePair (strings.removePrefix prefix n) v)))
            ];
        in
        discover-modules ./modules/host "darwin-" (module:
          nix-darwin.lib.darwinSystem {
            inherit pkgs;
            specialArgs = {
              inherit inputs;
            };
            modules = [
              home-manager.darwinModules.home-manager
              { nixpkgs = nixpkgsConfig; }
              module
            ];
          }
        );
    })
    ) // { };
}
