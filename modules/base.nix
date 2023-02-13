{ pkgs, ... }:

{
  programs.zsh.enable = true;
  programs.bash.enable = true;

  # Make sure the nix daemon always runs
  services.nix-daemon.enable = true;

  # Enables some of the nice new nix commands.
  nix.extraOptions =
    let
      experimental-features = [
        "flakes"
        "nix-command"
      ];
    in
    ''
      experimental-features = ${pkgs.lib.concatStringsSep " " experimental-features}
    '';
}
