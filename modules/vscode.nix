# If the user has VS Code installed, this module will automatically add the
# CLI helper onto the path for bash and zsh sessions.
{ config, lib, pkgs, ... }:
with lib;
let
  update-path-with-vscode = ''
    vscode_path='/Applications/Visual Studio Code.app/Contents/Resources/app/bin'
    if [ -d "$vscode_path" ]; then
      export PATH="$PATH:$vscode_path"
    fi
  '';
in

{
  programs.bash.interactiveShellInit =
    mkIf config.programs.bash.enable (
      mkAfter update-path-with-vscode
    );
  programs.zsh.interactiveShellInit =
    mkIf config.programs.zsh.enable (
      mkAfter update-path-with-vscode
    );
}
