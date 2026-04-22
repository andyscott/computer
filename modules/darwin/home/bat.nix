{ config, lib, pkgs, ... }:
{
  programs.bat = {
    enable = true;
  };
  programs.zsh = lib.mkIf config.programs.bat.enable {
    initContent = ''
      _cat_is_bat() {
        if [ -t 1 ]; then
          ${pkgs.bat}/bin/bat --style=plain --paging=never "$@"
        else
          # use regular cat in pipelines
          command cat "$@"
        fi
      }

      _less_is_bat() {
        if [ -t 1 ]; then
          ${pkgs.bat}/bin/bat --style=plain --paging=always "$@"
        else
          # use regular less in pipelines
          command less "$@"
        fi
      }

      #compdef _bat _cat_is_bat
      #compdef _bat _less_is_bat

      export MANPAGER="sh -c 'sed -u -e \"s/\\x1B\[[0-9;]*m//g; s/.\\x08//g\" | bat -p -lman'"
    '';

    shellAliases = {
      #cat = "_cat_is_bat";
      #less = "_less_is_bat";
    };
  };
}
