{ config, system, nixpkgs, ... }:

import nixpkgs {
  inherit config;
  inherit system;
  overlays = [
    (self: super: {
      google-meet-escape-artist = super.callPackage ./google-meet-escape-artist { };
      pre-commit = super.pre-commit // {
        mkWithPath = super.callPackage ./pre-commit/mkWithPath.nix { };
      };
    })
  ];
}
