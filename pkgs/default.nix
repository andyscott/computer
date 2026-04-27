{ config, system, nixpkgs, ... }:

import nixpkgs {
  inherit config;
  inherit system;
  overlays = [
    (self: super: {
      google-meet-escape-artist = super.callPackage ./google-meet-escape-artist { };
      media-key-router = super.callPackage ./media-key-router { };
      pre-commit = super.pre-commit // {
        mkWithPath = super.callPackage ./pre-commit/mkWithPath.nix { };
      };
      trackpad-haptic = super.callPackage ./trackpad-haptic { };
      zing = super.callPackage ./zing { };
    })
  ];
}
