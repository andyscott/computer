{ config, pkgs, lib, ... }:

# Original source: https://gist.github.com/antifuchs/10138c4d838a63c0a05e725ccd7bccdd

with lib;
let
  inherit (pkgs) stdenv;
  cfg = config.local.dock;

  dockutil = pkgs.callPackage ./dockutil.nix { };



  /*
    dockutil = with (import <nixpkgs> { });
    derivation {
      name = "dockutil-2.0.5";
      builder = "${bash}/bin/bash";
      args = [
        "-xeuc"
        ''
          ${unzip}/bin/unzip $src
          ${coreutils}/bin/mkdir -p $out/bin
          ${coreutils}/bin/mv dockutil-2.0.5/scripts/dockutil $out/bin/dockutil
        ''
      ];
      src = fetchurl {
        url = "https://github.com/kcrawford/dockutil/releases/download/3.1.3/dockutil-3.1.3.pkg";
        sha256 = "0b18awdaimf3gc4dhxx6lpivvx4li7j7kci648ssz39fwmbknlam";
      };
      system = builtins.currentSystem;
    };
    */
in
{
  options = {
    local.dock.enable = mkOption {
      description = "Enable dock";
      default = stdenv.isDarwin;
      example = false;
    };

    local.dock.entries = mkOption
      {
        description = "Entries on the Dock";
        type = with types; listOf (submodule {
          options = {
            path = lib.mkOption { type = str; };
            section = lib.mkOption {
              type = str;
              default = "apps";
            };
            options = lib.mkOption {
              type = str;
              default = "";
            };
          };
        });
        readOnly = true;
      };
  };

  config =
    mkIf cfg.enable
      (
        let
          normalize = path: if hasSuffix ".app" path then path + "/" else path;
          entryURI = path: "file://" + (builtins.replaceStrings
            [ " " "!" "\"" "#" "$" "%" "&" "'" "(" ")" ]
            [ "%20" "%21" "%22" "%23" "%24" "%25" "%26" "%27" "%28" "%29" ]
            (normalize path)
          );
          wantURIs = concatMapStrings
            (entry: "${entryURI entry.path}\n")
            cfg.entries;
          createEntries = concatMapStrings
            (entry: "${dockutil}/bin/dockutil --no-restart --add '${entry.path}' --section ${entry.section} ${entry.options}\n")
            cfg.entries;
        in
        {
          system.activationScripts.postUserActivation.text = ''
            echo >&2 "Setting up the Dock..."
            haveURIs="$(${dockutil}/bin/dockutil --list | ${pkgs.coreutils}/bin/cut -f2)"
            if ! diff -wu <(echo -n "$haveURIs") <(echo -n '${wantURIs}') >&2 ; then
              echo >&2 "Resetting Dock."
              ${dockutil}/bin/dockutil --no-restart --remove all
              ${createEntries}
              killall Dock
            else
              echo >&2 "Dock setup complete."
            fi
          '';
        }
      );
}
