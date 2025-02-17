{ user, ... }: {
  imports = [
    ./dock-helper
  ];

  local = {
    dock.enable = true;
    dock.entries = [
      # { path = "/Applications/Arc.app/"; }
      { path = "/Applications/Spotify.app/"; }
      {
        path = "/Users/${user}/Downloads/";
        section = "others";
        options = "--sort dateadded --view fan --display stack";
      }
    ];
  };
}
