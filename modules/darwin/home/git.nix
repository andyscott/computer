{ pkgs, lib, config, ... }:
let

  # This is a wrapper around the real git to automatically fix references
  # to the main branch by intelligently replacing master with main and main
  # with master.
  git-plus = with pkgs; symlinkJoin {
    name = "git+";
    paths = [
      (resholve.writeScriptBin "git"
        {
          inputs = [ git ];
          # Resholve's syntax checker doesn't like extended glob syntax so
          # we set the interpreter manually.
          interpreter = "none";
          execer = [
            ''cannot:${git}/bin/git''
          ];
        } ''
        #!${bash}/bin/bash
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
      git
    ];
  };

  # Time traveling helper for finding the right spot in the reflog
  git-tardis = with pkgs; resholve.writeScriptBin "git-tardis"
    {
      inputs = [ bash coreutils findutils fzf git-plus ];
      interpreter = "${bash}/bin/bash";
      execer = [
        ''cannot:${fzf}/bin/fzf''
        ''cannot:${git-plus}/bin/git''
      ];
    } ''
    git --no-pager log --color -g --abbrev-commit --pretty='%C(auto)%h% D %C(blue)%cr%C(reset) %gs (%s)' \
      | fzf --ansi \
      | cut -d " " -f 1 \
      | xargs -I {} bash -c "git name-rev --refs 'heads/*' --no-undefined --name-only {} 2>/dev/null || echo {}" \
      | xargs git checkout;
  '';

in
{
  programs.git = {
    enable = true;
    package = pkgs.symlinkJoin {
      name = "all-the-git";
      paths = [
        git-plus
        git-tardis
      ];
    };

    extraConfig = {
      color = {
        status = "auto";
        diff = "auto";
        branch = "auto";
        interactive = "auto";
        ui = "auto";
        sh = "auto";
      };
      init.defaultBranch = "main";
    };

    aliases = {
      tardis = "${git-tardis}/bin/git-tardis";
    };
  };

  programs.zsh = lib.mkIf config.programs.git.enable {
    shellAliases = {
      gpom = "git pull origin main";
    };
  };

}
