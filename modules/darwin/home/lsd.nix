{ config, lib, pkgs, ... }:
{
  programs.lsd = {
    enable = true;
  };
  programs.zsh = lib.mkIf config.programs.lsd.enable {
    initExtra = ''
      _ls_is_lsd() {
        if [ -t 1 ]; then
          ${pkgs.lsd}/bin/lsd "$@"
        else
          # use regular ls in pipelines
          command ls "$@"
        fi
      }
      compdef _lsd _ls_is_lsd
    '';

    shellAliases = {
      ls = "_ls_is_lsd";
      tree = "lsd --tree";
    };
  };
}
