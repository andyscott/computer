{ config, lib, pkgs, ... }:
let
  zoxideZshInit = pkgs.runCommandLocal "zoxide-init.zsh" { } ''
    ${lib.getExe config.programs.zoxide.package} init zsh ${lib.escapeShellArgs config.programs.zoxide.options} > "$out"
  '';
in
{
  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
    # `zoxide init zsh` is package-version + option static. Its emitted
    # functions still read runtime env vars like _ZO_* when they execute, so
    # pre-rendering the wrapper does not freeze user behavior.
    enableZshIntegration = false;
    options = [
      "--cmd"
      "cd"
    ];
  };

  programs.zsh.initContent = lib.mkIf config.programs.zoxide.enable ''
    source ${zoxideZshInit}
  '';
}
