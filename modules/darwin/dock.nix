{ lib, user, ... }: {
  imports = [
    ./dock-helper
  ];

  local = {
    dock.enable = true;
    dock.entries = lib.mkMerge [
      (lib.mkIf (user == "andy") [
        { path = "/Applications/Arc.app/"; }
      ])
      (lib.mkIf (user == "ags") [
        { path = "/Applications/Google Chrome.app/"; }
      ])
      [
        { path = "/Applications/Spotify.app/"; }
        {
          path = "/Users/${user}/Downloads/";
          section = "others";
          options = "--sort dateadded --view fan --display stack";
        }
      ]
    ];
  };
}


