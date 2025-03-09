{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    initExtra = ''
      setopt completealiases
      setopt transient_rprompt
    '';

    shellAliases = {
      tree = "lsd --tree";
    };

    autosuggestion = {
      enable = true;
    };
  };
}
