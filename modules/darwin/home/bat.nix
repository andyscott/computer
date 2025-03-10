{ config, lib, pkgs, ... }:
{
  programs.bat = {
    enable = true;
    extraPackages = with pkgs.bat-extras; [
      (batdiff.overrideAttrs (old: {
        doCheck = false;
      }))
      batman
      batgrep
      batwatch
    ];
  };
  programs.zsh = lib.mkIf config.programs.bat.enable {
    initExtra = ''
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

      export MANPAGER="sh -c 'sed -u -e \"s/\\x1B\[[0-9;]*m//g; s/.\\x08//g\" | bat -p -lman'"
    '';

    shellAliases = {
      cat = "_cat_is_bat";
      less = "_less_is_bat";
    };
  };
}
