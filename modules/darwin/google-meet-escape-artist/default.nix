{ pkgs, ... }:

pkgs.stdenv.mkDerivation {
  pname = "google-meet-escape-artist";
  version = "0.0.0";

  src = ./.;

  buildInputs = with pkgs; [
    darwin.apple_sdk.frameworks.SkyLight
    darwin.apple_sdk.frameworks.SystemConfiguration
  ];

  # Set the install phase to copy the built executable to the desired output directory
  installPhase = ''
    mkdir -p $out/bin
    cp google-meet-escape-artist $out/bin/
  '';
}
