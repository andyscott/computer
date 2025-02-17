#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

nix run nixpkgs#nix-output-monitor -- \
    build .#darwinConfigurations."$(hostname)".system

"$script_dir"/result/activate-user
sudo "$script_dir"/result/activate

/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
killall skhd
