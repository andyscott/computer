{ pkgs, ... }:

pkgs.stdenv.mkDerivation {
  pname = "trackpad-haptic";
  version = "0.0.0";

  src = ./.;

  installPhase = ''
    mkdir -p $out/bin
    cp trackpad-haptic $out/bin/
  '';
}
