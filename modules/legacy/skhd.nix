_:
{
  # shkd hotkey manager
  # https://github.com/koekeishiya/skhd
  services.skhd.enable = true;
  services.skhd.skhdConfig = builtins.readFile ./skhdrc;

  launchd.user.agents.skhd.serviceConfig = {
    StandardOutPath = "/var/tmp/skhd.log";
    StandardErrorPath = "/var/tmp/skhd.log";
  };
}
