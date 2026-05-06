{ config, lib, ... }:
with lib; let
  combinedShellInit = ''
    if [ -x /opt/homebrew/bin/brew ]; then
      # Original dynamic form:
      # eval "$(/opt/homebrew/bin/brew shellenv)"
      export HOMEBREW_PREFIX="/opt/homebrew"
      export HOMEBREW_CELLAR="/opt/homebrew/Cellar"
      export HOMEBREW_REPOSITORY="/opt/homebrew"
      export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
      export MANPATH="/opt/homebrew/share/man''${MANPATH+:$MANPATH}:"
      export INFOPATH="/opt/homebrew/share/info:''${INFOPATH:-}"
    fi
  '';
in
{
  programs.bash.profileExtra = mkIf config.programs.bash.enable (
    mkAfter combinedShellInit
  );

  programs.zsh.profileExtra = mkIf config.programs.zsh.enable (
    mkAfter combinedShellInit
  );
}


