{ config, lib, pkgs, ... }:
{
  programs.lsd = {
    enable = true;
  };
  programs.zsh = lib.mkIf config.programs.lsd.enable {
    shellAliases = {
      #ls = "_ls_is_lsd";
      tree = "lsd --tree";
    };
  };
}
