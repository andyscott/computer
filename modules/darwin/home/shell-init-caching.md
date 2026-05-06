# Zsh init-script caching

Some CLI tools print a Zsh integration script on demand, and Home Manager's
usual integration runs that generator in every new shell. When the generated
**text** depends only on the package version plus declared module options, we
render it once in the Nix build and `source` the store path at shell startup.
The script may still do runtime work after it is sourced; only the code
_generation_ moves out of the prompt path.

Use this pattern only after verifying both of these:

1. A fresh runtime generation matches the store-rendered script for the same
   package/options.
2. The output is not personalized by HOME, per-user files, or other ambient
   machine state. If it is, keep the normal dynamic integration instead.

Current examples:

- Safe to pre-render: Atuin, direnv, fzf, Starship, zoxide.
- Intentionally dynamic: Carapace. Its generated Zsh script changes with HOME
  and per-user support-directory state, so build-time rendering is not faithful.

When adding another tool, leave a short comment beside the module explaining
which side of that line it falls on. That keeps the optimization legible and
prevents future speed work from quietly freezing user-specific behavior.
