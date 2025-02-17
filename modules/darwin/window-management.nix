_:
{
  services.jankyborders = {
    enable = true;
    active_color = "0xff6dfedf";
    inactive_color = "0xff494d64";
    width = 4.0;
    style = "round";
  };

  # shkd hotkey manager
  # https://github.com/koekeishiya/skhd
  services.skhd.enable = true;
  services.skhd.skhdConfig = ''
    :: default  : borders 'active_color=0xff6dfedf'
    :: focus  @ : borders 'active_color=0xffdb9610'

    default < rcmd - w  ; focus
    default < rcmd - r  : yabai -m space --rotate 180

    focus   < rcmd - w  ; default
    focus   < escape    ; default
    focus   < return    ; default

    focus   < r         : yabai -m space --rotate 180
    focus   < n         : yabai -m window --focus east
    focus   < p         : yabai -m window --focus west
    focus   < f         : yabai -m window --toggle float --grid 20:20:2:2:16:16
    focus   < z         : yabai -m window --toggle zoom-parent
    focus   < h         : skhd -k 'escape'; skhd -k 'cmd - h'

    focus   < 1         : yabai -m window --grid 20:20:9:9:2:2
    focus   < 2         : yabai -m window --grid 20:20:8:8:4:4
    focus   < 3         : yabai -m window --grid 20:20:7:7:6:6
    focus   < 4         : yabai -m window --grid 20:20:6:6:8:8
    focus   < 5         : yabai -m window --grid 20:20:5:5:10:10
    focus   < 6         : yabai -m window --grid 20:20:4:4:12:12
    focus   < 7         : yabai -m window --grid 20:20:3:3:14:14
    focus   < 8         : yabai -m window --grid 20:20:2:2:16:16
    focus   < 9         : yabai -m window --grid 20:20:1:1:18:18
    focus   < 0         : yabai -m window --grid 20:20:0:0:20:20
  '';

  launchd.user.agents.skhd.serviceConfig = {
    StandardOutPath = "/var/tmp/skhd.log";
    StandardErrorPath = "/var/tmp/skhd.log";
  };

  # yabai window manager
  # https://github.com/koekeishiya/yabai
  services.yabai.enable = true;
  services.yabai.extraConfig = ''
    #!/usr/bin/env sh

    yabai -m rule --add app='System Settings'    manage=off grid=20:20:5:1:0:20
    yabai -m rule --add app='Finder'             manage=off grid=20:20:2:2:16:16
    yabai -m rule --add app='1Password'          manage=off grid=20:20:2:2:16:16

    yabai -m config debug_output                 on
    yabai -m config mouse_follows_focus          on
    yabai -m config window_placement             second_child
    yabai -m config window_topmost               off
    yabai -m config split_ratio                  0.50
    yabai -m config auto_balance                 off

    yabai -m config layout                       bsp
    yabai -m config top_padding                  0
    yabai -m config bottom_padding               0
    yabai -m config left_padding                 0
    yabai -m config right_padding                0
    yabai -m config window_gap                   3
  '';
  services.yabai.enableScriptingAddition = false;

  launchd.user.agents.yabai.serviceConfig = {
    StandardOutPath = "/var/tmp/yabai.log";
    StandardErrorPath = "/var/tmp/yabai.log";
  };
}
