{ config, lib, pkgs }:

let
  base16-shell = pkgs.stdenv.mkDerivation rec {
    name = "base16-shell";

    src = pkgs.fetchFromGitHub {
      owner = "chriskempson";
      repo = "base16-shell";
      rev = "588691ba71b47e75793ed9edfcfaa058326a6f41";
      sha256 = "sha256-X89FsG9QICDw3jZvOCB/KsPBVOLUeE7xN3VCtf0DD3E=";
    };

    installPhase = ''
      mkdir -p $out
      cp -r . $out
    '';
  };

  git-gpg-key = "C0012AF12CAF6F92";

  andy-bin = pkgs.callPackage ./bin.nix { };

  oauth2l = pkgs.buildGoModule rec {
    pname = "oauth2l";
    version = "21ab08b88b2e8d6b6ac0b0cc1560368a1c87b989";

    src = pkgs.fetchFromGitHub {
      owner = "google";
      repo = pname;
      rev = version;
      hash = "sha256-vhotf5yDt/c4yMmwDAP8uT3sRFaL1AATRgEKTe/Oq7c=";
    };

    doCheck = false;

    vendorHash = null;

    buildInputs = [ ];
  };

  python-vipaccess = pkgs.python3Packages.buildPythonPackage rec {
    name = "python-vipaccess";
    version = "0.0.0";
    src = pkgs.fetchFromGitHub {
      owner = "cyrozap";
      repo = "${name}";
      rev = "cc4366f7bce41d5ebce64ae8d86cc71e5eda5703";
      sha256 = "sha256-V1jYoXa5WZFs7hRwMRDlzaWaUEGcyuHcD0F4IUBw3AY=";
    };

    buildInputs = with pkgs.python3Packages; [
      nose2
    ];

    doCheck = false;

    propagatedBuildInputs = with pkgs.python3Packages; [
      oath
      requests
      pycryptodome
    ];
  };
in
lib.mkMerge [
  {
    home.username = "andy";
    home.homeDirectory = "/Users/andy";

    # Base install of packages
    home.packages = [
      pkgs._1password
      pkgs.gh
      pkgs.babashka
      pkgs.coreutils # cat, date, md5sum, mkdir, mv, realpath, sha1sum, touch, ...
      pkgs.moreutils # sponge, chronic, ...
      pkgs.jq # jq
      pkgs.yq-go # yq but the better version
      pkgs.curl # curl
      pkgs.diffutils # diff
      pkgs.nixpkgs-fmt
      pkgs.findutils # find, xargs, ...
      pkgs.gawk # awk
      pkgs.glow # tui markdown reader
      pkgs.gnugrep # grep
      pkgs.gnused # sed
      pkgs.gnutar # tar
      pkgs.gnupg
      pkgs.neo-cowsay # cowsay/cowthink
      pkgs.openssh # ssh, ssh-keygen, ...
      pkgs.wget # wget
      pkgs.xz # xz
      pkgs.python3 # python3
      pkgs.ripgrep
      pkgs.zellij
      pkgs.helix
      pkgs.julia_18-bin
      pkgs.sl
      pkgs.tig
      pkgs.gti
      oauth2l
      python-vipaccess

      pkgs.git-linear
      andy-bin.git-tardis
    ];

    programs.zsh = {
      shellAliases = {
        glb = "git linear branch";
        glo = "git linear open";
      };
    };

    # without this, nix-darwin managed GPG won't be able to generate keys
    # and do other important work
    home.file.".gnupg/gpg-agent.conf".text = ''
      allow-preset-passphrase
      pinentry-program ${pkgs.pinentry_mac}/Applications/pinentry-mac.app/Contents/MacOS/pinentry-mac
    '';

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
    programs.bash = {
      enable = true;
    };
  }
  {
    programs.bat = {
      enable = true;
      extraPackages = with pkgs.bat-extras; [
        batdiff
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
  }
  {
    programs.fzf = {
      enable = true;
    };
  }
  {
    programs.git = {
      enable = true;
      package = andy-bin.git;
      userName = "Andy Scott";
      userEmail = "andy.g.scott@gmail.com";
      aliases = {
        tardis = "${andy-bin.git-tardis}/bin/git-tardis";
        linear = "${pkgs.git-linear}/bin/git-linear";
      };
      signing = {
        signByDefault = true;
        key = git-gpg-key;
      };
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
        github.user = "andyscott";
        url."https://github".insteadOf = "git://git@github.com";
      };
    };
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

      # know to break prompts... this breaks mine!
      # https://github.com/kovidgoyal/kitty/blob/6a3529b7c2cee78d9ebb564765308babfb3eda8f/shell-integration/zsh/kitty-integration#L204
      shellIntegration.mode = "no-prompt-mark";
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
    # Let Home Manager install and manage itself.
    programs.home-manager = {
      enable = true;
    };
  }
  {
    programs.zoxide = {
      enable = true;
    };
  }
  {
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      initExtra = '' 

      setopt completealiases

      unset PS1
      unset PROMPT

      unset RPS1
      unset RPROMPT

      function _ansi() { (($# - 2)) || echo -n "%F{$1}$2%f"; }

      function _wrap() {
        setopt localoptions noautopushd; builtin cd -q $1
        local -a outputs
        local cmd output
        shift
        for cmd in $@; do output=$($cmd); ( (( $? )) || [[ -z "''${output// }" ]] ) || outputs+=$output; done

        echo "''${(ej. .)outputs}"
      }

      function _prompt_path() {
          _ansi magenta "%$(( ($COLUMNS > 80 ? 80 : $COLUMNS) - 40 ))<...<%~%<<"
      }

      local last_status

      function _prompt_status_symbol() {
          local root; [[ $UID = 0 || $EUID = 0 ]] && root=true || root=false
          local error; (( $last_status )) && error=true || error=false

          local color;

          if ( $error ); then
            color='red'
          else
            color='blue'
          fi

          ( $root && $error ) && _ansi $color '▽' && return
          ( $root ) && _ansi $color '▼' && return
          ( $error ) && _ansi $color '△' && return
          _ansi $color '▲'
      }

      function _prompt_git_status() {
          ${pkgs.git}/bin/git rev-parse 2>/dev/null || return

          branch=$(${pkgs.git}/bin/git symbolic-ref HEAD 2> /dev/null | sed -e 's|^refs/heads/||')

          bits=(
            $([[ -z "$(${pkgs.git}/bin/git diff --no-ext-diff --quiet --exit-code)" ]] && _ansi green "⬢" || _ansi red "⬡")
            $(_ansi cyan $branch)
          )

        echo $bits
      }

      function _prompt() {
          last_status=$?
          local bits && bits=(
            _prompt_status_symbol
            _prompt_git_status
          )
          _wrap $PWD $bits
      }

      setopt prompt_subst
      PROMPT=' $(_prompt) ';

      precmd() {
        print -Pn "\e]133;A\e\\"
      }

      # Base16 Shell

      source '${base16-shell}/profile_helper.sh'
      base16_rebecca

      # eval "$(${pkgs._1password}/bin/op signin)"
      # ${pkgs._1password}/bin/op item get "Git GPG Key" --fields passphrase \
      #   | ${pkgs.gnupg}/bin/libexec/gpg-preset-passphrase --preset ${git-gpg-key}
    '';

      shellAliases = {
        tree = "lsd --tree";
        gpom = "git pull origin main";
      };
    };

  }
]
