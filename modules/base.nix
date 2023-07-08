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
      auto-optimise-store = true
      experimental-features = ${pkgs.lib.concatStringsSep " " experimental-features}
      build-users-group = nixbld
      bash-prompt-prefix = (nix:$name)\040
      extra-nix-path = nixpkgs=flake:nixpkgs
    '';
}
