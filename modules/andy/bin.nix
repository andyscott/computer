{ pkgs }:
rec {

  # This is a wrapper around the real git to automatically fix references
  # to the main branch by intelligently replacing master with main and main
  # with master.
  git = pkgs.symlinkJoin {
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

  hass = pkgs.writeShellScriptBin "hass" ''
    if [ $# -lt 1 ]; then
      exit 1
    fi
    
    hass_token_file=~/.hass_office_token
    if [ ! -f "$hass_token_file" ]; then
      ${pkgs._1password}/bin/op item get \
        --account V7K6KBP2URA3HEJMZNEZLO6S3U \
        'Office HASS Token' \
        --fields credential > "$hass_token_file"
    fi
    export HASS_TOKEN="$(cat "$hass_token_file")"

    case "$1" in
    toggle-office)
      ${pkgs.curl}/bin/curl \
        -H "Authorization: Bearer $HASS_TOKEN" \
        -H "Content-Type: application/json" \
        --json '{"entity_id": "light.office"}' \
        http://office.local/api/services/light/toggle
      ;;
    toggle-ring-light)
      ${pkgs.curl}/bin/curl \
        -H "Authorization: Bearer $HASS_TOKEN" \
        -H "Content-Type: application/json" \
        --json '{"entity_id": "light.ring_light"}' \
        http://office.local/api/services/light/toggle
      ;;
    esac
  '';

  setup-gpg-keys = pkgs.resholve.writeScriptBin "setup-gpg-keys"
    {
      inputs = with pkgs; [
        gnupg
        "${pkgs.gnupg}/bin/libexec/gpg-preset-passphrase"
        _1password
        jq
      ];
      interpreter = "${pkgs.bash}/bin/bash";
      execer = [
        ''cannot:${pkgs.gnupg}/bin/gpg''
        ''cannot:${pkgs.gnupg}/bin/libexec/gpg-preset-passphrase''

      ];
    } ''
    if gpg --list-secret-keys C0012AF12CAF6F92 &>/dev/null; then
      exit 0
    fi

    echo 'setting up your gpg key(s)...'
    
    passphrase="$(
      op read \
        --account V7K6KBP2URA3HEJMZNEZLO6S3U \
        'op://personal/Git GPG Key/passphrase'
    )"

    op read \
      --account V7K6KBP2URA3HEJMZNEZLO6S3U \
      'op://personal/Git GPG Key/private.pgp' \
      | gpg --pinentry-mode=loopback --passphrase "$(echo "$passphrase")" --import
  '';

}
