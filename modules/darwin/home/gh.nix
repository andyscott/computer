{ pkgs, config, ... }:

let
  # Teach gh to honor the repo-local account selector already emitted by
  # `git personal`. GitHub CLI itself keeps one active account per host, which
  # makes it easy to accidentally create a PR from the wrong same-host account.
  gh-plus = with pkgs; symlinkJoin {
    name = "gh+";
    paths = [
      (resholve.writeScriptBin "gh"
        {
          inputs = [
            gh
            config.programs.git.package
          ];
          interpreter = "${bash}/bin/bash";
          execer = [
            ''cannot:${gh}/bin/gh''
            ''cannot:${config.programs.git.package}/bin/git''
          ];
        } ''
        # Leave credential-management commands alone. They need to inspect and
        # mutate gh's stored accounts rather than inheriting repo policy.
        if [[ "''${1-}" == "auth" ]]; then
          exec gh "$@"
        fi

        # Explicit tokens are stronger than repo convention, and non-github.com
        # hosts have their own auth story.
        if [[ -z "''${GH_TOKEN-}" && -z "''${GITHUB_TOKEN-}" ]] \
          && [[ -z "''${GH_HOST-}" || "''${GH_HOST}" == "github.com" ]]; then
          github_user="$(git config --get github.user 2> /dev/null || true)"

          if [[ -n "$github_user" ]]; then
            if ! github_token="$(gh auth token --hostname github.com --user "$github_user" 2> /dev/null)"; then
              printf 'gh: this repository selects GitHub account "%s", but no stored token exists for it.\n' "$github_user" >&2
              printf 'gh: run `gh auth login --hostname github.com --web` while signed in as "%s".\n' "$github_user" >&2
              exit 1
            fi

            export GH_TOKEN="$github_token"
          fi
        fi

        exec gh "$@"
      ''
      )
      gh
    ];
  };
in
{
  home.packages = [
    gh-plus
  ];
}
