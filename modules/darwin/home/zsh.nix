{ lib, ... }:
lib.mkMerge [
  {
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      initExtra = ''
        setopt completealiases
        setopt transient_rprompt
      '';

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
        initExtra = mkVeryAfter "source ~/.zshrc.unmanaged 2> /dev/null";
        envExtra = mkVeryAfter "source ~/.zshenv.unmanaged 2> /dev/null";
        profileExtra = mkVeryAfter "source ~/.zprofile.unmanaged 2> /dev/null";
        #loginExtra = mkVeryAfter "source ~/.zlogin.unmanaged 2> /dev/null";
        #logoutExtra = mkVeryAfter "source ~/.zlogout.unmanaged 2> /dev/null";
      };
    }
  )
]
