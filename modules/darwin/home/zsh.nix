{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    initExtra = ''
      setopt completealiases
      setopt transient_rprompt
    '';

    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
  };
}
