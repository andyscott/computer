{ pkgs, ... }:

pkgs.stdenv.mkDerivation {
  pname = "media-key-router";
  version = "0.0.0";

  src = ./.;

  meta = {
    description = "Routes macOS media-key commands to approved already-running media apps";
    platforms = pkgs.lib.platforms.darwin;
  };

  installPhase = ''
    mkdir -p $out/bin
    cp media-key-router $out/bin/
  '';
}
