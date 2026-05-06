{ lib, ... }:
lib.mkMerge [
  {
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      # `compinit -C` trusts the existing dump file and skips the expensive
      # freshness/security scan on every shell startup. Rebuild the dump only
      # when completion definitions actually change.
      completionInit = "autoload -U compinit && compinit -C";
      initContent = lib.mkMerge [
        # Home Manager's history snippet always shells out to `dirname` +
        # `mkdir -p`, even when HISTFILE already lives directly under $HOME.
        # Intercept that one known no-op so every shell does not pay two process
        # spawns just to rediscover that the home directory exists.
        (lib.mkOrder 909 ''
          dirname() {
            if [[ "$1" == "$HOME/.zsh_history" ]]; then
              print -r -- "$HOME"
            else
              command dirname "$@"
            fi
          }

          mkdir() {
            if [[ "$1" == "-p" && "$2" == "$HOME" && $# -eq 2 ]]; then
              return 0
            fi
            command mkdir "$@"
          }
        '')

        (lib.mkOrder 911 ''
          unfunction dirname mkdir
        '')

        ''
          setopt transient_rprompt
        ''
      ];

      profileExtra = ''
        # I really don't like virtualenv style prompts
        export VIRTUAL_ENV_DISABLE_PROMPT=1
      '';

      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
    };
  }
  (
    let
      mkVeryAfter = lib.mkOrder 2000; # normal mkAfter is 1500
    in
    {
      programs.zsh = {
        initContent = mkVeryAfter ''
          source ~/.zshrc.unmanaged 2> /dev/null

          # Terminal editing keys arrive as escape sequences. Zsh does not bind
          # every terminfo key by default, so wire the common editing keys to the
          # sequences advertised by the active terminal. Keep this after the
          # unmanaged zshrc so these bindings are not accidentally overwritten.
          if [[ $options[zle] = on ]]; then
            zmodload zsh/terminfo 2> /dev/null || true

            bind_terminfo_key() {
              local cap="$1" widget="$2"
              [[ -n "''${terminfo[$cap]-}" ]] && bindkey "''${terminfo[$cap]}" "$widget"
            }

            bind_terminfo_key kdch1 delete-char
            bind_terminfo_key khome beginning-of-line
            bind_terminfo_key kend end-of-line
            bind_terminfo_key kich1 overwrite-mode
            bind_terminfo_key kcuu1 up-line-or-history
            bind_terminfo_key kcud1 down-line-or-history
            bind_terminfo_key kcub1 backward-char
            bind_terminfo_key kcuf1 forward-char

            unfunction bind_terminfo_key
          fi
        '';
        envExtra = mkVeryAfter "source ~/.zshenv.unmanaged 2> /dev/null";
        profileExtra = mkVeryAfter "source ~/.zprofile.unmanaged 2> /dev/null";
        #loginExtra = mkVeryAfter "source ~/.zlogin.unmanaged 2> /dev/null";
        #logoutExtra = mkVeryAfter "source ~/.zlogout.unmanaged 2> /dev/null";
      };
    }
  )
]
