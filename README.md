# computer

Living configuration for my computer(s).

# setup

1. Install Nix.
2. Run `./apply.sh` (or `just apply`).

Note: `/run` is ephemeral on macOS. nix-darwin recreates `/run/current-system`
on boot via the `org.nixos.activate-system` LaunchDaemon, which depends on the
system profile at `/nix/var/nix/profiles/system`. `./apply.sh` runs
`darwin-rebuild switch` (which updates that profile) so `/run/current-system`
comes back after reboot.
# license
Some code in this repo is attributed to upstream sources and is either
unlicensed or very permissive. Refer to those upstream sources for specific
information.

Some code is licensed under Apache 2.0. The header of the files says so.

```
Copyright 2025 Andy Scott <andy.g.scott@gmail.com>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

Everything else is licensed as WTFPL, so feel free to use it and make your
own config more useful.
