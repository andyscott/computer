{ config, lib, pkgs, ... }:
let
  starshipZshInit = pkgs.runCommandLocal "starship-init.zsh" { } ''
    ${lib.getExe config.programs.starship.package} init zsh > "$out"
  '';
in
{
  programs.starship = {
    enable = true;
    # `starship init zsh` is package-version-static glue. Prompt rendering still
    # shells out to `starship prompt` at runtime, so config changes remain live;
    # only the startup-time wrapper generation moves into the Nix build.
    enableZshIntegration = false;
    settings = {
      add_newline = false;
      continuation_prompt = "[⌇ ](dimmed)";
      format = lib.concatStrings [
        "$directory"
        "$time"
        "$character "
        #"$python"
      ];

      right_format = lib.concatStrings [
        "$jobs"
        "$python"
        "$git_branch"
        #"$git_status"
        "$git_state"
      ];

      directory = {
        truncation_length = 20;
        truncate_to_repo = true;
        read_only = "ˣ";
        read_only_style = "red";
        format = "[$path]($style)[$read_only]($read_only_style)";
      };

      custom.zsh_rprompt_truncation = {
        format = "%10<..<";
        unsafe_no_escape = true;
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

      python = {
        format = "[\($virtualenv\) ]($style)";
      };

      time = {
        disabled = false;
        format = " [$time]($style)";
      };

    };
  };

  programs.zsh.initContent = lib.mkIf config.programs.starship.enable ''
    if [[ $TERM != "dumb" ]]; then
      source ${starshipZshInit}
    fi
  '';
}
