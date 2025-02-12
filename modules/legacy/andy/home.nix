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

  alias = name: actual: pkgs.writeShellScriptBin name ''
    exec ${actual} "$@"
  '';

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
      owner = "dlenski";
      repo = "${name}";
      rev = "9f49da31664e31608b2604e12768995368f7dfc7";
      sha256 = "sha256-J9HKwkJStTZ6zm4u100+DSuxIbn4/kiGu/uAE8P/ALg=";
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
      (pkgs.google-cloud-sdk.withExtraComponents [
        pkgs.google-cloud-sdk.components.gke-gcloud-auth-plugin
      ])
      pkgs.go
      andy-bin.hass
      pkgs.graphite-cli
      pkgs.dive
      pkgs.kubie
      pkgs._1password-cli
      (alias "bazel" "${pkgs.bazelisk}/bin/bazelisk")
      pkgs.bazel-buildtools
      pkgs.gh
      pkgs.coreutils # cat, date, md5sum, mkdir, mv, realpath, sha1sum, touch, ...
      pkgs.difftastic
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
      pkgs.zed-editor
      pkgs.tig
      pkgs.gti
      pkgs.tokei
      oauth2l
      python-vipaccess

      #pkgs.git-linear
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
    programs.gpg = {
      enable = true;
    };
    home.file.".gnupg/gpg-agent.conf".text = ''
      allow-preset-passphrase
      pinentry-program ${andy-bin.pinentry-op}/bin/pinentry-op
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
    programs.zsh = lib.mkIf config.programs.lsd.enable {
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
    programs.emacs = {
      #enable = true;
      package = pkgs.emacsWithPackagesFromUsePackage {
        package = pkgs.emacs-30;
        config = ./emacs.el;
      };
      #extraConfig = builtins.readFile ./emacs.el;
    };

    home.file.".emacs.d/init.el".source = ./emacs.el;
  }
  {
    programs.fzf = {
      enable = true;
    };
    programs.zsh = lib.mkIf config.programs.fzf.enable {
      # zsh init from https://blog.jez.io/fzf-bazel/
      initExtra = ''
        _fzf_complete_bazel_test() {
          _fzf_complete '-m' "$@" < <(command bazel query \
            "kind('(test|test_suite) rule', //...)" 2> /dev/null)
        }

        _fzf_complete_bazel() {
          local tokens
          tokens=(''${(z)LBUFFER})

          if [ ''${#tokens[@]} -ge 3 ] && [ "''${tokens[2]}" = "test" ]; then
            _fzf_complete_bazel_test "$@"
          else
            # Might be able to make this better someday, by listing all repositories
            # that have been configured in a WORKSPACE.
            # See https://stackoverflow.com/questions/46229831/ or just run
            #     bazel query //external:all
            # This is the reason why things like @ruby_2_6//:ruby.tar.gz don't show up
            # in the output: they're not a dep of anything in //..., but they are deps
            # of @ruby_2_6//...
            _fzf_complete '-m' "$@" < <(command bazel query --keep_going \
              --noshow_progress \
              "kind('(binary rule)|(generated file)', deps(//...))" 2> /dev/null)
          fi
        }
      '';
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
        #linear = "${pkgs.git-linear}/bin/git-linear";
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
      #difftastic.enable = true;
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
      setopt transient_rprompt

      # Base16 Shell
      source '${base16-shell}/profile_helper.sh'
      base16_rebecca

      ${andy-bin.setup-gpg-keys}/bin/setup-gpg-keys
    '';

      shellAliases = {
        tree = "lsd --tree";
        gpom = "git pull origin main";
      };
    };

  }
  {
    programs.starship = {
      enable = true;
      # Configuration written to ~/.config/starship.toml
      settings = {
        add_newline = false;
        continuation_prompt = "[⌇ ](dimmed)";
        format = pkgs.lib.concatStrings [
          "$directory"
          "$time"
          "$character "
        ];

        right_format = pkgs.lib.concatStrings [
          "$jobs"
          "$git_branch"
          "$git_status"
          "$git_state"
        ];

        directory = {
          truncation_length = 20;
          truncate_to_repo = true;
          read_only = "ˣ";
          read_only_style = "red";
          format = "[$path]($style)[$read_only]($read_only_style)";
        };


        git_branch = {
          format = "[$branch(:$remote_branch)]($style)";
        };

        git_status = {
          format = "([$all_status$ahead_behind]($style))";
        };

        character = {
          format = " $symbol";
          success_symbol = "[▲](blue)";
          error_symbol = "[△](red)";
        };

        time = {
          disabled = false;
          format = " [⸱](dimmed)[$time]($style)";
        };

      };
    };
  }
]
