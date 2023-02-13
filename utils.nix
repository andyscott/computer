{ lib }:
with lib;
rec {
  discover-modules = dir: f:
    filterAttrs
      (n: v: v != null)
      (mapAttrs'
        (n: v:
          let path = "${toString dir}/${n}"; in
          if v == "directory" && pathExists "${path}/default.nix"
          then nameValuePair n (f path)
          else if v == "regular" &&
            n != "default.nix" &&
            strings.hasSuffix ".nix" n
          then nameValuePair (strings.removeSuffix ".nix" n) (f path)
          else nameValuePair "" null
        )
        (builtins.readDir dir));

  discover-modules' = dir: f:
    attrValues (discover-modules dir f);
}
