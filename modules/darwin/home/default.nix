{ lib, config, pkgs, user, ... }:

{
  specialArgs = {
    updatePathWithApp = appName: ''
      app_paths=(
        "/Applications/${appName}.app/Contents/Resources/app/bin"
        "$HOME/Applications/Home Manager Apps/${appName}.app/Contents/Resources/app/bin"
      )

      for app_path in ''${app_paths[@]}; do
        if [ -d "$app_path" ]; then
          export PATH="$PATH:$app_path"
          break
        fi
      done
    '';
  };

  imports = [
    ./atuin.nix
    ./bat.nix
    ./direnv.nix
    ./fzf.nix
    ./ghostty.nix
    ./git.nix
    ./gpg.nix
    ./jq.nix
    ./lsd.nix
    ./shell.nix
    ./starship.nix
    ./zed-editor.nix
    ./zoxide.nix
    ./zsh.nix
  ];
} // lib.mkMerge [
  {
    home.username = user;
    home.homeDirectory = "/Users/${user}";

    # Base install of packages
    home.packages = [
      pkgs.coreutils
      pkgs.moreutils
      pkgs.yq-go
      pkgs.curl
      pkgs.diffutils
      pkgs.nixpkgs-fmt
      pkgs.findutils
      pkgs.gawk
      pkgs.gnugrep
      pkgs.gnused
      pkgs.gnutar
      pkgs.wget
      pkgs.xz
      pkgs.ripgrep
      pkgs.tig
      pkgs.gti
      pkgs.ouch
      pkgs.tokei
      pkgs.trackpad-haptic
    ];

    programs.zsh = {
      shellAliases = {
        g = "git";
        k = "kubectl";
        kc = "kubectx";
        kn = "kubens";
      };
    };
  }
  (lib.mkIf (user == "andy") {
    home.packages = [
      pkgs.python312Packages.python-vipaccess

    ];
  })
  (lib.mkIf (user == "ags") {
    home.packages = [
      pkgs.postgresql.dev
      pkgs.kubectx
    ];
    programs.zsh = {
      shellAliases = {
        k = "kubectl";
        kc = "kubectx";
        kn = "kubens";
      };
    };
  })
  {
    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    home.stateVersion = "21.11";
  }
]
