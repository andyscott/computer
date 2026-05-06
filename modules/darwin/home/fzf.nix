{ config, lib, pkgs, ... }:
let
  fzfZshInit = pkgs.runCommandLocal "fzf-init.zsh" { } ''
    ${lib.getExe config.programs.fzf.package} --zsh > "$out"
  '';
in
{
  # command line fuzzy finder
  programs.fzf = {
    enable = true;
    # `fzf --zsh` emits package-version-static shell functions; user knobs such
    # as FZF_DEFAULT_OPTS are read later by those functions at runtime. Source a
    # pre-rendered copy so keybindings stay identical without spawning `fzf`
    # during shell startup.
    enableZshIntegration = false;
  };

  # Home Manager normally initializes fzf early so later history managers can
  # intentionally take over Ctrl-R; preserve that ordering while sourcing the
  # pre-rendered script.
  programs.zsh.initContent = lib.mkIf config.programs.fzf.enable (lib.mkOrder 910 ''
    if [[ $options[zle] = on ]]; then
      source ${fzfZshInit}
    fi
  '');
}
