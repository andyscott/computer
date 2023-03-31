{ pkgs, ... }:
{
  # yabai window manager
  # https://github.com/koekeishiya/yabai
  services.yabai.enable = true;
  services.yabai.package = pkgs.yabai;
  services.yabai.extraConfig = builtins.readFile ./yabairc;
  services.yabai.enableScriptingAddition = true;

  launchd.user.agents.yabai.serviceConfig = {
    StandardOutPath = "/var/tmp/yabai.log";
    StandardErrorPath = "/var/tmp/yabai.log";
  };
}
