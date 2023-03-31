_:
{
  # shkd hotkey manager
  # https://github.com/koekeishiya/skhd
  services.skhd.enable = true;
  services.skhd.skhdConfig = builtins.readFile ./skhdrc;
}
