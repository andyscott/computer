{ lib, ... }:
{
  programs.zsh = {
    initExtra = ''
      # export VIRTUAL_ENV_DISABLE_PROMPT=1
    '';
  };

  programs.starship = {
    enable = true;
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

      time = {
        disabled = false;
        format = " [$time]($style)";
      };

    };
  };
}
