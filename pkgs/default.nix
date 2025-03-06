{ config, system, nixpkgs, ... }:

import nixpkgs {
  inherit config;
  inherit system;
  overlays = [
    (self: super: {
      pre-commit = super.pre-commit // {
        mkWithPath = super.callPackage ./pre-commit/mkWithPath.nix { };
      };
    })
  ];
}
