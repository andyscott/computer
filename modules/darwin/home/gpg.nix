{ pkgs, lib, config, ... }:

let
  setup-gpg-keys = pkgs.resholve.writeScriptBin "setup-gpg-keys"
    {
      inputs = with pkgs; [
        gnupg
        _1password-cli
      ];
      interpreter = "${pkgs.bash}/bin/bash";
      execer = [
        ''cannot:${pkgs.gnupg}/bin/gpg''
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

  mkIf-gpg-enabled = lib.mkIf config.programs.gpg.enable;
in
{
  programs.gpg = {
    enable = true;
  };

  home.file.".gnupg/gpg-agent.conf" = mkIf-gpg-enabled {
    text = ''
      allow-preset-passphrase
      pinentry-program ${pinentry-op}/bin/pinentry-op
    '';
  };

  # Key import is a one-time repair action, not shell initialization work.
  # Keep the helper available on PATH so it can be run explicitly when needed
  # without making every new terminal pay the 1Password/GPG startup cost.
  home.packages = mkIf-gpg-enabled [ setup-gpg-keys ];

  programs.git.personalConfig = mkIf-gpg-enabled {
    #commit.gpgSign = true;
    #tag.gpgSign = true;
    # github doesn't support signed push :(
    # push.gpgSign = true;

    #user.signingkey = "C0012AF12CAF6F92";
  };

}
