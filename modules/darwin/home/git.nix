{ pkgs, lib, config, ... }:
{
  config = lib.mkMerge [
    {
      programs.git.enable = true;
    }
    {
      programs.git = {
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
          personal = "config --local include.path ~/${config.xdg.configFile."git/config-personal".target}";
        };
      };

      programs.zsh = lib.mkIf
        config.programs.git.enable
        {
          shellAliases = {
            gpom = "git pull origin main";
          };
        };
    }
    {
      programs.git.personalConfig = {
        core = {
          sshCommand =
            let
              op_SSH_AUTH_SOCK = "~/Library/Group\\ Containers/2BUA8C4S2C.com.1password/t/agent.sock";
            in
            with pkgs; "${coreutils}/bin/env SSH_AUTH_SOCK=${op_SSH_AUTH_SOCK} ${openssh}/bin/ssh";
        };

        user = {
          name = "Andy Scott";
          email = "andy.g.scott@gmail.com";
        };
        github.user = "andyscott";

        url."git@github.com:".insteadOf = "https://github.com/";
      };
    }
    (
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

      in
      {
        programs.git.package = git-plus;
      }
    )
    (
      let
        # Time traveling helper for finding the right spot in the reflog
        git-tardis = with pkgs; resholve.writeScriptBin "git-tardis"
          {
            inputs = [ bash coreutils findutils fzf config.programs.git.package ];
            interpreter = "${bash}/bin/bash";
            execer = [
              ''cannot:${fzf}/bin/fzf''
              ''cannot:${config.programs.git.package}/bin/git''
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
        home.packages = [
          git-tardis
        ];
        programs.git.aliases.tardis = "${git-tardis}/bin/git-tardis";
      }
    )
    {
      xdg.configFile."git/config-personal".text = lib.generators.toGitINI config.programs.git.personalConfig;
    }
  ];

  options.programs.git.personalConfig =
    let
      gitIniType = with lib.types;
        let
          primitiveType = either str (either bool int);
          multipleType = either primitiveType (listOf primitiveType);
          sectionType = attrsOf multipleType;
          supersectionType = attrsOf (either multipleType sectionType);
        in
        attrsOf supersectionType;
    in
    lib.mkOption {
      type = gitIniType;
    };
}
