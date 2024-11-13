{ pkgs, ... }:
pkgs.stdenv.mkDerivation rec {
  name = "dockutil-${version}";
  version = "3.1.3";

  src = pkgs.fetchurl {
    url = "https://github.com/kcrawford/dockutil/releases/download/${version}/dockutil-3.1.3.pkg";
    sha256 = "9g24Jz/oDXxIJFiL7bU4pTh2dcORftsAENq59S0/JYI=";
  };

  nativeBuildInputs = with pkgs; [ xar cpio makeWrapper ];

  unpackPhase = ''
    xar -xf $src
    zcat < intermediary_dockutil-${version}.pkg/Payload | cpio -i
  '';

  dontPatch = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin/
    mv usr/local/bin/dockutil $out/bin/dockutil
    runHook postInstall
  '';
}
