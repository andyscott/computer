{ config, lib, pkgs, ... }:
let
  atuinZshInit = pkgs.runCommandLocal "atuin-init.zsh"
    {
      nativeBuildInputs = [ pkgs.writableTmpDirAsHomeHook ];
    } ''
    ${lib.getExe config.programs.atuin.package} init zsh ${lib.escapeShellArgs config.programs.atuin.flags} > "$out"
  '';
in
{
  # shell history program
  programs.atuin = {
    enable = true;
    # `atuin init zsh` is package-version + flag static. The emitted script
    # still performs runtime work (for example creating ATUIN_SESSION), but the
    # text itself does not depend on the user's Atuin config. Pre-rendering it
    # here avoids one process spawn before every prompt while preserving the
    # normal runtime behavior inside the sourced script.
    enableZshIntegration = false;
  };

  programs.zsh.initContent = lib.mkIf config.programs.atuin.enable ''
    if [[ $options[zle] = on ]]; then
      source ${atuinZshInit}
    fi
  '';
}
