{ config, lib, ... }:
with lib; let
  combinedShellInit = ''
    if [ -x /opt/homebrew/bin/brew ]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
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


