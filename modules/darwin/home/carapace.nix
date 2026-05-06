{
  programs.carapace = {
    enable = true;
    # Keep Home Manager's normal dynamic Zsh integration here. Unlike the other
    # init generators below, `carapace _carapace zsh` is not purely
    # package-version-static: its first line changes with HOME and with whether
    # the per-user Carapace support directory exists. That makes pre-rendering
    # it at Nix build time subtly wrong.
  };
}
