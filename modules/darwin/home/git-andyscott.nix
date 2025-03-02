{ config, lib, pkgs, ... }: {

  programs.git = {
    enable = true;

    includes = [
      { path = "~/${config.xdg.configFile."git/config-andyscott".target}"; }
    ];

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
      url."https://github".insteadOf = "git://git@github.com";
    };

  };

  xdg.configFile."git/config-andyscott".text = lib.generators.toGitINI {
    user = {
      name = "Andy Scott";
      email = "andy.g.scott@gmail.com";
    };

    github.user = "andyscott";
  };


}
