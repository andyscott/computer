#!/usr/bin/env bash
set -euo pipefail

check_full_disk_access() {
  if ! ls ~/Library/Messages >/dev/null 2>&1; then
    echo 'Error: The current terminal does not have Full Disk Access.'
    echo 'Please grant Full Disk Access by following these steps:'
    echo '  1. Open System Settings > Privacy & Security > Full Disk Access'
    echo '  2. Enable the current terminal app.'

    read -r -p 'Would you like to open the settings page now? (y/n): ' answer
    if [[ "$answer" =~ ^[Yy]$ ]]; then
      open 'x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles'
    fi

    exit 1
  fi
}
check_full_disk_access

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

nix run nixpkgs#nix-output-monitor -- \
    build '.#darwinConfigurations."'"$(hostname)"'".system'

"$script_dir"/result/activate-user
sudo "$script_dir"/result/activate

/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
killall skhd
