{ config, lib, pkgs, ... }:
with lib;
let

  nix-direnv-lib = pkgs.writeTextFile rec {
    name = "nix-direnv.sh";
    executable = true;
    destination = "/lib/${name}";
    text = ''
      source ${pkgs.nix-direnv}/share/nix-direnv/direnvrc
    '';
  };

  wrapped-direnv = pkgs.symlinkJoin
    {
      name = "direnv";
      paths = [ pkgs.direnv ];
      buildInputs = [ pkgs.makeBinaryWrapper ];
      postBuild = ''
        wrapProgram $out/bin/direnv \
          --set DIRENV_CONFIG ${nix-direnv-lib}
      '';
    };
in

{
  environment.systemPackages = [
    wrapped-direnv
  ];

  # Direnv sorts out its own exectuable path in some intelligent manner
  # so we can easily wind up with hooks that point to regular direnv instead
  # of our wrapped direnv. To mitigate this, we do a quick sed replacement.

  programs.bash.interactiveShellInit =
    mkIf config.programs.bash.enable (
      mkAfter ''
        eval "$(direnv hook bash | sed 's|.direnv-wrapped|direnv|')"
      ''
    );
  programs.zsh.interactiveShellInit =
    mkIf config.programs.zsh.enable (
      mkAfter ''
        eval "$(direnv hook zsh | sed 's|.direnv-wrapped|direnv|')"
      ''
    );
}
