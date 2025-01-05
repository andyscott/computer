{ pkgs, config, ... }:


let user = "andy"; in
# andy's darwin customizations
{
  imports = [
    ./dock.nix
  ];

  users.users.${user} = {
    name = user;
    home = "/Users/${user}";
  };
  home-manager.users.${user} = { config, lib, pkgs, ... }: import ./home.nix { inherit config lib pkgs; };

  /*
    programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    };
  */

  programs.zsh.enable = true;

  # touch ID when sudo'ing
  security.pam.enableSudoTouchIdAuth = true;

  #services.emacs.enable = true;
  #services.emacs.package = pkgs.emacs-30;

  services.jankyborders.enable = true;
  services.jankyborders.active_color = "0xffe1e3e4";
  services.jankyborders.inactive_color = "0xff494d64";

  # caps locks is control :)
  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToControl = true;

  system.defaults.menuExtraClock.Show24Hour = true;
  system.defaults.menuExtraClock.ShowAMPM = false;
  system.defaults.menuExtraClock.ShowDate = 0; # show when space allows


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

  # change force press from default (1, medium) to (2, firm)
  system.defaults.trackpad.SecondClickThreshold = 2;

  system.defaults.dock.expose-animation-duration = 0.0;
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

  local = {
    dock.enable = true;
    dock.entries = [
      { path = "/Applications/Arc.app/"; }
      { path = "/Applications/Spotify.app/"; }
      {
        path = "/Users/${user}/Downloads/";
        section = "others";
        options = "--sort dateadded --view fan --display stack";
      }
    ];
  };
}
