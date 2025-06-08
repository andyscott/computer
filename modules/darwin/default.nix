{ pkgs, user, ... }: {

  imports = [
    ./cleanup-accessibility-services.nix
    ./dock.nix
    ./window-management.nix
  ];

  users.users.${user} = {
    name = user;
    home = "/Users/${user}";
  };

  nix.enable = false;

  nixpkgs.hostPlatform = "aarch64-darwin";
  system.stateVersion = 5;

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  programs.zsh.enable = true;
  programs.bash.enable = true;

  system.primaryUser = user;

  # touch ID when sudo'ing
  security.pam.services.sudo_local.touchIdAuth = true;

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

  # drag windows by ctrl + command clicking anywhere
  system.defaults.NSGlobalDomain.NSWindowShouldDragOnGesture = true;

  # change force press from default (1, medium) to (2, firm)
  system.defaults.trackpad.SecondClickThreshold = 2;

  # turn off the scatter all windows when clicking desktop behavior
  system.defaults.WindowManager.EnableStandardClickToShowDesktop = false;

  # disable automatic rearrangement of spaces
  system.defaults.dock.mru-spaces = false;

  # show battery percentage in menu bar
  system.defaults.controlcenter.BatteryShowPercentage = true;

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

  # dark mode
  system.defaults.NSGlobalDomain.AppleInterfaceStyle = "Dark";

  # less motion pls
  # note: if you get the "Could not write domain com.apple.universalaccess; exiting" error,
  # ensure the terminal program has full disk access.
  system.defaults.universalaccess.reduceMotion = true;

  system.defaults.CustomUserPreferences = {

    "com.apple.loginwindow" = {
      # Do not save app state on shutdown
      TALLogoutSavesState = false;
      # Do not reopen apps from saved state on login
      LoginwindowLaunchesRelaunchApps = false;
    };

    "com.apple.TextInputMenu" = {
      # hides the keyboard text input menu bar item
      visible = false;
    };

    "com.apple.symbolichotkeys" = {
      AppleSymbolicHotKeys = {
        # Disable 'Cmd + Space' for Spotlight Search
        "64" = {
          enabled = false;
        };

        # previous space: command + left
        "79" = {
          enabled = true;
          value = {
            type = "standard";
            parameters = [ 65535 123 10747904 ];
          };
        };

        # next space: command + right
        "81" = {
          enabled = true;
          value = {
            type = "standard";
            parameters = [ 65535 124 8650752 ];
          };
        };
      };
    };
  };

  # Enables some of the nice new nix commands.
  nix.extraOptions =
    let
      experimental-features = [
        "flakes"
        "nix-command"
      ];
    in
    ''
      # auto-optimise-store = true # disabled per https://github.com/NixOS/nix/issues/7273
      experimental-features = ${pkgs.lib.concatStringsSep " " experimental-features}
      build-users-group = nixbld
      bash-prompt-prefix = (nix:$name)\040
      extra-nix-path = nixpkgs=flake:nixpkgs
    '';
}
