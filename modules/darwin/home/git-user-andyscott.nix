{ config, lib, pkgs, ... }:

let
  SSH_AUTH_SOCK = "~/Library/Group\\ Containers/2BUA8C4S2C.com.1password/t/agent.sock";
in
{
  programs.git = {
    aliases = {
      personal = "config --local include.path ~/${config.xdg.configFile."git/config-user-andyscott".target}";
    };
  };

  xdg.configFile."git/config-user-andyscott".text = lib.generators.toGitINI {
    core = {
      sshCommand = with pkgs; "${coreutils}/bin/env SSH_AUTH_SOCK=${SSH_AUTH_SOCK} ${openssh}/bin/ssh";
    };

    user = {
      name = "Andy Scott";
      email = "andy.g.scott@gmail.com";
    };

    github.user = "andyscott";
    url."git@github.com:".insteadOf = "https://github.com/";

  };

}
