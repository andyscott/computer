{ config, lib, pkgs, ... }:
{
  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };
  programs.zsh = lib.mkIf config.programs.direnv.enable {
    initExtra = ''
      _completions_hook() {
        trap -- ''' SIGINT;
        if (( ''${+DIRENV_FILE} )); then
          local fpath_before=$fpath
          typeset -xUT XDG_DATA_DIRS xdg_data_dirs
          local xdg_data_dir
          for xdg_data_dir in $xdg_data_dirs; do
              if [ -d "$xdg_data_dir"/zsh/site-functions ]; then
                  fpath+=("$xdg_data_dir"/zsh/site-functions)
              fi
          done
          if [[ $fpath != $fpath_before ]]; then
              compinit
          fi
        fi
        trap - SIGINT;
      }
      typeset -ag precmd_functions;
      if [[ -z "''${precmd_functions[(r)_completions_hook]+1}" ]]; then
        precmd_functions=( ''${precmd_functions[@]} _completions_hook )
      fi
      typeset -ag chpwd_functions;
      if [[ -z "''${chpwd_functions[(r)_completions_hook]+1}" ]]; then
        chpwd_functions=( ''${chpwd_functions[@]} _completions_hook )
      fi
    '';
  };
}
