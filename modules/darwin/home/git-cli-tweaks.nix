{ pkgs, ... }:
let

  # This is a wrapper around the real git to automatically fix references
  # to the main branch by intelligently replacing master with main and main
  # with master.
  git-plus = pkgs.symlinkJoin {
    name = "git+";
    paths = [
      (pkgs.resholve.writeScriptBin "git"
        {
          inputs = [ pkgs.git ];
          interpreter = "none";
          execer = [
            ''cannot:${pkgs.git}/bin/git''
          ];
        } ''
        #!${pkgs.bash}/bin/bash
        shopt -s extglob
        if root="$(git rev-parse --show-toplevel 2> /dev/null)"; then
          if [ -f "$root"/.git/refs/heads/main ]; then
              from=master
              to=main
          else
              from=main
              to=master
          fi

          for arg; do
            shift
            case "$arg" in
            "$from"*(^) ) set -- "$@" "$to''${arg/#$from}";;
            *           ) set -- "$@" "$arg";;
            esac
          done
        fi
        exec git "$@"
      ''
      )
      pkgs.git
    ];
  };

  # Time traveling helper for finding the right spot in the reflog
  git-tardis = pkgs.writeShellScriptBin "git-tardis" ''
    ${pkgs.git}/bin/git --no-pager log --color -g --abbrev-commit --pretty='%C(auto)%h% D %C(blue)%cr%C(reset) %gs (%s)' \
      | ${pkgs.fzf}/bin/fzf --ansi \
      | cut -d " " -f 1 \
      | xargs -I {} bash -c "( git name-rev --refs 'heads/*' --no-undefined --name-only {} 2>/dev/null || echo {} )" \
      | xargs git checkout;
  '';

in
{
  programs.git = {
    package = git-plus;
    aliases = {
      tardis = "${git-tardis}/bin/git-tardis";
    };
  };

  programs.zsh = {
    shellAliases = {
      gpom = "git pull origin main";
    };
  };

}
