{ pkgs, ... }:
{
  programs.ghostty = {
    enable = false;
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
