# Working With This Flake

- Always verify host attributes first:
  - `SYSTEM=aarch64-darwin`
  - `HOST=$(hostname)` (if uncertain, list hosts with `nix eval .#darwinConfigurations.${SYSTEM} --apply 'builtins.attrNames'`).
- Fast feedback loop for changes:
  - `nix build .#darwinConfigurations.${SYSTEM}.${HOST}.system`
  - If you need more detail, rerun with `--show-trace`.
- Apply the result via the existing helper (requires Full Disk Access): `./apply.sh`.
- Known warnings today: nixpkgs emits a `builtins.toFile` notice and Home Manager warns that `programs.zsh.initExtra` is deprecated. They are cosmetic; cleanups can be tackled separately.
- Nix is enabled via `nix.enable = true;` and settings live under `nix.settings` in `modules/darwin/default.nix`. Avoid reintroducing `services.nix-daemon.enable` (it is ignored by nix-darwin).
