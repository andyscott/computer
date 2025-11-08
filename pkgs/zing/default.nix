{ pkgs, lib, ... }:

pkgs.rustPlatform.buildRustPackage rec {
  pname = "zing";
  version = "0.1.0";

  src = ./.;
  cargoLock.lockFile = ./Cargo.lock;

  buildInputs = [ ];
}
