{ pkgs, ... }:

pkgs.stdenv.mkDerivation {
  pname = "trackpad-haptic";
  version = "0.0.0";

  src = ./.;

  buildInputs = with pkgs; [
    darwin.apple_sdk.frameworks.AppKit
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp trackpad-haptic $out/bin/
  '';
}
