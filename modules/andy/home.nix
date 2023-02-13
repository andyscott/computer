{ pkgs }:

let
  darwinShellInit = ''
    export NIX_PATH=$HOME/.nix-defexpr/channels''${NIX_PATH:+:}$NIX_PATH
  '';
in
{
  home.username = "andy";
  home.homeDirectory = "/Users/andy";

  programs.git = {
    enable = true;
    userName = "Andy Scott";
    userEmail = "andy.g.scott@gmail.com";

    extraConfig = {
      color = {
        status = "auto";
        diff = "auto";
        branch = "auto";
        interactive = "auto";
        ui = "auto";
        sh = "auto";
      };
      #whitespace = "trailing-space,space-before-tab";

      #commit.gpgsign         = true;

      github.user = "andyscott";

      url."https://github".insteadOf = "git://git@github.com";
    };

  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # the one true editor
  #programs.emacs.enable = true;
  #programs.emacs.package = pkgs.emacsMacport;

  programs.zsh = {
    enable = true;
    initExtra = '' 
      _ls() {
        if [ -t 1 ]; then
          lsd "$@"
        else
          # use regular ls in pipelines
          command ls "$@"
        fi
      }

      unset PS1
      unset PROMPT

      unset RPS1
      unset RPROMPT

      BASE16_SHELL=$HOME/.config/base16-shell/
      [ -s $BASE16_SHELL/profile_helper.sh ] && eval "$($BASE16_SHELL/profile_helper.sh)"

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
          git rev-parse 2>/dev/null || return

          branch=$(command git symbolic-ref HEAD 2> /dev/null | sed -e 's|^refs/heads/||')

          bits=(
            $([[ -z "$(command git diff --no-ext-diff --quiet --exit-code)" ]] && _ansi green "⬢" || _ansi red "⬡")
            $(_ansi cyan $branch)
          )

        echo $bits
      }

      function _prompt() {
          last_status=$?
          local bits && bits=(
            _prompt_status_symbol
            _prompt_path
            _prompt_git_status
          )
          _wrap $PWD $bits
      }

      setopt prompt_subst
      PROMPT=' $(_prompt) ';


      eval "$(atuin init zsh)"
      eval "$(zoxide init zsh)"
    '';

    shellAliases = {
      ls = "_ls";
      tree = "lsd --tree";
    };
  };

  programs.bash = {
    enable = true;
    #initExtra = darwinShellInit;
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "21.11";

  # Base install of packages
  home.packages = [
    pkgs.atuin #
    pkgs.coreutils # cat, date, md5sum, mkdir, mv, realpath, sha1sum, touch, ...
    pkgs.curl # curl
    pkgs.diffutils # diff
    pkgs.nixpkgs-fmt
    #pkgs.exa # exa
    pkgs.lsd # lsd
    pkgs.findutils # find, xargs, ...
    pkgs.gawk # awk
    #pkgs.git       # git
    pkgs.gnugrep # grep
    pkgs.gnused # sed
    pkgs.gnutar # tar
    pkgs.x86.jq # jq
    pkgs.moreutils # chronic
    pkgs.openssh # ssh, ssh-keygen, ...
    pkgs.wget # wget
    pkgs.xz # xz
    pkgs.yq-go # yq
    pkgs.python3 # python3
    pkgs.zoxide # zoxide
    pkgs.fzf
    pkgs.ripgrep
    pkgs._1password
  ];
}
