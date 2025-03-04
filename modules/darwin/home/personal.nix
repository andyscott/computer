{ pkgs, lib, config, ... }:

let
  setup-gpg-keys = pkgs.resholve.writeScriptBin "setup-gpg-keys"
    {
      inputs = with pkgs; [
        gnupg
        "${pkgs.gnupg}/bin/libexec/gpg-preset-passphrase"
        _1password-cli
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

  pinentry-op = pkgs.resholve.writeScriptBin "pinentry-op"
    {
      inputs = with pkgs; [
        _1password-cli
      ];
      interpreter = "${pkgs.bash}/bin/bash";
    } ''
    passphrase="$(
        op read \
        --account V7K6KBP2URA3HEJMZNEZLO6S3U \
        'op://personal/Git GPG Key/passphrase'
    )"

    echo "OK Pleased to meet you"

    while IFS= read -r cmd; do
        case "$cmd" in
        GETPIN)
            echo "D $passphrase"
            echo "OK"
            ;;
        GETINFO*)
            echo "D none"
            echo "OK"
            ;;
        BYE)
            echo "OK closing connection"
            exit 0
            ;;
        *)
            echo "OK"
            ;;
        esac
    done
  '';
in
{
  # without this, nix-darwin managed GPG won't be able to generate keys
  # and do other important work
  programs.gpg = {
    enable = true;
  };
  home.file.".gnupg/gpg-agent.conf".text = ''
    allow-preset-passphrase
    pinentry-program ${pinentry-op}/bin/pinentry-op
  '';

  programs.zsh = lib.mkIf config.programs.gpg.enable {
    initExtra = ''
      ${setup-gpg-keys}/bin/setup-gpg-keys
    '';
  };

  programs.git.personalConfig = {
    commit.gpgSign = true;
    tag.gpgSign = true;
    # github doesn't support signed push :(
    # push.gpgSign = true;

    user.signingkey = "C0012AF12CAF6F92";
  };

}
