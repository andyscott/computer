{ config, lib, pkgs, user, ... }:

{
  imports = [
    ./git.nix
    ./gpg.nix
    ./starship.nix
  ];
} // lib.mkMerge [
  {
    home.username = user;
    home.homeDirectory = "/Users/${user}";

    # Base install of packages
    home.packages = [
      pkgs.coreutils
      pkgs.moreutils
      pkgs.jq
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
      pkgs.fzf
      pkgs.ouch
      pkgs.tokei
    ];

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
  {
    # shell history program
    programs.atuin = {
      enable = true;
    };
  }
  {
    programs.bat = {
      enable = true;
      extraPackages = with pkgs.bat-extras; [
        (batdiff.overrideAttrs (old: {
          doCheck = false;
        }))
        batman
        batgrep
        batwatch
      ];
    };
    programs.zsh = lib.mkIf config.programs.bat.enable {
      initExtra = ''
        _cat_is_bat() {
          if [ -t 1 ]; then
            ${pkgs.bat}/bin/bat "$@"
          else
            # use regular cat in pipelines
            command cat "$@"
          fi
        }
      '';

      shellAliases = {
        cat = "_cat_is_bat";
      };
    };
  }
  {
    programs.direnv = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };
    programs.zsh = lib.mkIf config.programs.direnv.enable {
      initExtra = ''
        _completions_hook() {
          trap -- ''' SIGINT;
          if (( ''${+DIRENV_FILE} )); then
            local fpath_before=$fpath
            typeset -xUT XDG_DATA_DIRS xdg_data_dirs
            local xdg_data_dir
            for xdg_data_dir in $xdg_data_dirs; do
                if [ -d "$xdg_data_dir"/zsh/site-functions ]; then
                    fpath+=("$xdg_data_dir"/zsh/site-functions)
                fi
            done
            if [[ $fpath != $fpath_before ]]; then
                compinit
            fi
          fi
          trap - SIGINT;
        }
        typeset -ag precmd_functions;
        if [[ -z "''${precmd_functions[(r)_completions_hook]+1}" ]]; then
          precmd_functions=( ''${precmd_functions[@]} _completions_hook )
        fi
        typeset -ag chpwd_functions;
        if [[ -z "''${chpwd_functions[(r)_completions_hook]+1}" ]]; then
          chpwd_functions=( ''${chpwd_functions[@]} _completions_hook )
        fi
      '';
    };
  }
  {
    programs.lsd = {
      enable = true;
    };
    programs.zsh = lib.mkIf config.programs.lsd.enable {
      initExtra = ''
        _ls_is_lsd() {
          if [ -t 1 ]; then
            ${pkgs.lsd}/bin/lsd "$@"
          else
            # use regular ls in pipelines
            command ls "$@"
          fi
        }
      '';

      shellAliases = {
        ls = "_ls_is_lsd";
      };
    };
  }
  {
    programs.ghostty = {
      enable = true;
      enableZshIntegration = true;
      package =
        let
          version = "1.1.2";
          sha256 = "sha256:1qa83ishd5iy8zm25bzsh1r9ai2xzgvfp16hlmzl9jild0wh3bfl";
          dmg = builtins.fetchurl {
            url = "https://release.files.ghostty.org/${version}/Ghostty.dmg";
            inherit sha256;
          };
        in
        pkgs.runCommand "ghostty" { nativeBuildInputs = [ pkgs._7zz ]; } ''
          mkdir -p $out/Applications $out/bin $out/share
          cd $out/Applications
          7zz x ${dmg}
          ln -s $out/Applications/Ghostty.app/Contents/MacOS/ghostty $out/bin/ghostty
          ln -s $out/Applications/Ghostty.app/Contents/Resources/bat $out/share/bat
          ln -s $out/Applications/Ghostty.app/Contents/Resources/man $out/share/man
          ln -s $out/Applications/Ghostty.app/Contents/Resources/terminfo $out/share/terminfo
          ln -s $out/Applications/Ghostty.app/Contents/Resources/ghostty $out/share/ghostty
        '';

      settings = {
        background-opacity = 0.9;
        background-blur-radius = 20;
        font-family = "Fira Code";
        macos-titlebar-style = "hidden";
        macos-icon = "custom-style";
        macos-icon-screen-color = "#663399";
        macos-icon-ghost-color = "#6dfedf";
        theme = "rebecca";
      };
    };
    home.packages = [
      pkgs.fira-code
    ];
  }
  {
    programs.kitty = {
      enable = true;

      font = {
        package = pkgs.fira-code;
        name = "Fira Code";
        size = 13.0;
      };

      extraConfig = ''
        confirm_os_window_close 0
        allow_remote_control yes
        enabled_layouts *
      '';
    };
  }
  {
    programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
    };
  }
  {
    programs.zed-editor = {
      enable = true;
      userSettings = {
        ui_font_size = 15;
        buffer_font_size = 12;
        load_direnv = "direct";
        #theme = "Rosé Pine";
      };
    };
  }
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
    };
  }
]
