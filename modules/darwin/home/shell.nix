{ config, lib, ... }:
# misc shell config goes here
with lib; let
  maybeAddAppBinToPath = appName: ''
    app_paths=(
      "/Applications/${appName}.app/Contents/Resources/app/bin"
      "$HOME/Applications/Home Manager Apps/${appName}.app/Contents/Resources/app/bin"
    )

    for app_path in ''${app_paths[@]}; do
      if [ -d "$app_path" ]; then
        export PATH="$PATH:$app_path"
        break
      fi
    done
  '';

  combinedShellInit = builtins.concatStringsSep "\n" [
    (maybeAddAppBinToPath "Cursor")
    (maybeAddAppBinToPath "Visual Studio Code")
    (maybeAddAppBinToPath "Windsurf")
  ];
in
{
  programs.bash.initExtra = mkIf config.programs.bash.enable (
    mkAfter combinedShellInit
  );

  programs.zsh.initExtra = mkIf config.programs.zsh.enable (
    mkAfter combinedShellInit
  );
}
