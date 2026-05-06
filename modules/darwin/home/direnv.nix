{ config, lib, pkgs, ... }:
let
  direnvZshHook = pkgs.runCommandLocal "direnv-hook.zsh" { } ''
    ${lib.getExe config.programs.direnv.package} hook zsh > "$out"
  '';
in
{
  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    # `direnv hook zsh` is package-version-static glue around runtime
    # `direnv export zsh` calls. Pre-render only that glue; directory-specific
    # environment loading still happens dynamically whenever the hook runs.
    enableZshIntegration = false;
    nix-direnv.enable = true;
  };
  programs.zsh = lib.mkIf config.programs.direnv.enable {
    initContent = ''
      source ${direnvZshHook}

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
