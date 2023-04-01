{ pkgs, ... }:

# andy's darwin customizations
{
  users.users.andy = {
    name = "andy";
    home = "/Users/andy";
  };
  home-manager.users.andy = { config, lib, pkgs, ... }: import ./home.nix { inherit config lib pkgs; };

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # touch ID when sudo'ing
  security.pam.enableSudoTouchIdAuth = true;

  /*
    services.emacs.enable = true;
    services.emacs.package =
    let
    emacsOsx = import (pkgs.fetchFromGitHub {
    owner = "sagittaros";
    repo = "emacs-osx";
    rev = "9cc5119b33d5fad1bfe4426d7a298d610a18f700";
    sha256 = "0nk15jz7pkh85w6s887999gka5dl0va2qippbc1jgx2gb1zj5kxa";
    });
    in
    emacsOsx.emacsOsxNative;
  */

  # caps locks is control :)
  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToControl = true;

  # enable full keyboard access for all controls (e.g. enable tab in modal dialogs)
  system.defaults.NSGlobalDomain.AppleKeyboardUIMode = 3;
  # show all filename extensions in Finder
  system.defaults.NSGlobalDomain.AppleShowAllExtensions = true;
  # set a blazingly fast keyboard repeat rate
  system.defaults.NSGlobalDomain.KeyRepeat = 1;
  # set a shorter Delay until key repeat
  system.defaults.NSGlobalDomain.InitialKeyRepeat = 18;
  # disable opening and closing window animations
  system.defaults.NSGlobalDomain.NSAutomaticWindowAnimationsEnabled = false;
  # show all file extensions
  system.defaults.finder.AppleShowAllExtensions = true;

  system.defaults.dock.autohide = true;
  system.defaults.dock.launchanim = false;
  system.defaults.dock.orientation = "right";

  # screen corner actions
  #  1: disabled
  #  3: application windows
  #  5: start screen saver
  # 13: lock screen
  system.defaults.dock.wvous-tl-corner = 3;
  system.defaults.dock.wvous-tr-corner = 5;
  system.defaults.dock.wvous-bl-corner = 1;
  system.defaults.dock.wvous-br-corner = 1;

  system.defaults.finder._FXShowPosixPathInTitle = true;
  system.defaults.finder.FXEnableExtensionChangeWarning = false;
}
