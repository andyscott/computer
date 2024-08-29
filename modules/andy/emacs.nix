{ pkgs }:
let
  base =
    if pkgs.stdenv.isDarwin
    then
      pkgs.emacs.overrideAttrs
        (old: {
          patches =
            (old.patches or [ ])
            ++ [
              ./emacs/patches/fix-window-role.patch
              ./emacs/patches/round-undecorated-frame.patch
              #poll.patch
              #round-undecorated-frame.patch
              #system-appearance.patch

              # Use poll instead of select to get file descriptors
              # (pkgs.fetchpatch {
              #   url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/master/patches/emacs-29/poll.patch";
              #   sha256 = "sha256-jN9MlD8/ZrnLuP2/HUXXEVVd6A+aRZNYFdZF8ReJGfY=";
              # })
              # Enable rounded window with no decoration
              #             (pkgs.fetchpatch {
              #               url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/master/patches/emacs-28/no-titlebar-and-round-corners.patch";
              #               sha256 = "sha256-RYdjAf1c43Elh7ad4kujPnrCX8qY7ZWxufJfCc0QW00=";
              #             })
              # Make emacs aware of OS-level light/dark mode
              #            (pkgs.fetchpatch {
              #              url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/master/patches/emacs-28/system-appearance.patch";
              #              sha256 = "sha256-oM6fXdXCWVcBnNrzXmF0ZMdp8j0pzkLE66WteeCutv8=";
              #            })
            ];
          configureFlags =
            (old.configureFlags or [ ])
            ++ [
              "LDFLAGS=-headerpad_max_install_names"
            ];
        })
    else pkgs.emacs;
in
pkgs.emacsWithPackagesFromUsePackage {
  package = base;
  config = ./emacs.org;
}
