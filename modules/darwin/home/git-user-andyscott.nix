{ config, lib, pkgs, ... }:

let
  SSH_AUTH_SOCK = "~/Library/Group\\ Containers/2BUA8C4S2C.com.1password/t/agent.sock";

  gitIniType = with lib.types;
    let
      primitiveType = either str (either bool int);
      multipleType = either primitiveType (listOf primitiveType);
      sectionType = attrsOf multipleType;
      supersectionType = attrsOf (either multipleType sectionType);
    in
    attrsOf supersectionType;
in
{

  options.programs.git.personalConfig = lib.mkOption {
    type = gitIniType;
  };

  config = {

    programs.git = {
      aliases = {
        personal = "config --local include.path ~/${config.xdg.configFile."git/config-personal".target}";
      };
    };

    programs.git.personalConfig = {
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

    xdg.configFile."git/config-personal".text = lib.generators.toGitINI config.programs.git.personalConfig;
  };

}
