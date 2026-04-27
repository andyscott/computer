{ pkgs, ... }:

let
  media-key-router = "${pkgs.media-key-router}/bin/media-key-router";
in
{
  # Capture media keys before macOS can launch Music. Focused Safari and focused
  # local media players get the original key event; otherwise Spotify wins if it
  # is already running, and the key becomes a no-op.
  services.skhd.skhdConfig = ''
    play [
      "safari" ~
      "iina" ~
      "vlc" ~
      "quicktime player" ~
      * : ${media-key-router} play-pause
    ]

    next [
      "safari" ~
      "iina" ~
      "vlc" ~
      "quicktime player" ~
      * : ${media-key-router} next
    ]

    previous [
      "safari" ~
      "iina" ~
      "vlc" ~
      "quicktime player" ~
      * : ${media-key-router} previous
    ]
  '';
}
