{ pkgs, ... }:

pkgs.stdenv.mkDerivation {
  pname = "google-meet-escape-artist";
  version = "0.0.0";

  meta = {
    description = "Google Meet is an Excape Artist";
    longDescription = ''
      Automatically moves the Google Meet sticky meeting window out of the way of the
      cursor.

      The window will move out of the way whenever the cursor moves within a fixed
      threshold. You can hold <ctrl> to disable the behavior; this allows you to easily
      interact with the window when needed (e.g. close it fully).

      Background info for the uninitiated:

      Google Meet floats a sticky meeting window on your screen when you tab away
      from the current meeting. This is nice, but also not nice, as the sticky window
      very often gets in the way of content on your screen if you're on a small monitor
      (e.g. MacBook screen).

    '';
    platforms = pkgs.lib.platforms.darwin;
  };

  src = ./.;

  # Set the install phase to copy the built executable to the desired output directory
  installPhase = ''
    mkdir -p $out/bin
    cp google-meet-escape-artist $out/bin/
  '';
}
