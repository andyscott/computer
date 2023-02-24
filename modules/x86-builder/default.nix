{ pkgs, ... }:
{
  nix.distributedBuilds = true;
  nix.buildMachines = [{
    hostName = "nix-docker";
    sshUser = "root";
    sshKey = "/etc/nix/docker_rsa";
    systems = [ "x86_64-linux" ];
    maxJobs = 2;
  }];

  environment.etc."nix/docker_rsa".source = ./ssh/insecure_rsa;

  system.activationScripts.postActivation.text = ''
    chmod 0600 /etc/nix/docker_rsa
  '';


  home-manager.users.root = {
    programs.ssh.enable = true;
    programs.ssh.matchBlocks = {
      "nix-docker" = {
        identityFile = "/etc/nix/docker_rsa";
        hostname = "127.0.0.1";
        user = "root";
        port = 3022;
      };
    };

    home.stateVersion = "22.11";
  };

  # TODO -- use the new? darwin builder?
  # https://nixos.org/manual/nixpkgs/unstable/#sec-darwin-builder

  # TODO -- can I get this working? Turn it into callable script, instead?
  #launchd.user.agents.start-colima = {
  #  script = ''
  #    ${pkgs.colima}/bin/colima start --arch x86_64 --cpu 4 --memory 8 --disk 20 --profile nix-builder
  #  '';
  #  serviceConfig.KeepAlive = false;
  #  serviceConfig.RunAtLoad = true;
  #};
}
