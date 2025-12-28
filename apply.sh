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
cd "$script_dir"

SYSTEM="${SYSTEM:-aarch64-darwin}"

# The flake uses the machine's host name as the configuration key.
# Historically this repo used `hostname` so we keep that behavior, but allow
# overriding it when needed (e.g. if Tahoe changes what `hostname` returns).
host_candidates=()
if [[ -n "${HOST:-}" ]]; then
  host_candidates+=("$HOST")
fi
if command -v scutil >/dev/null 2>&1; then
  if local_host_name="$(scutil --get LocalHostName 2>/dev/null)"; then
    # Prefer LocalHostName (no `.local`), since `darwin-rebuild` uses it by
    # default and its CLI can't select quoted attribute names.
    host_candidates+=("$local_host_name")
  fi
fi
host_candidates+=("$(hostname)")

available_hosts_json="$(nix eval --json --no-warn-dirty \
  "$script_dir#darwinConfigurations.${SYSTEM}" \
  --apply 'builtins.attrNames' 2>/dev/null || true)"

if [[ -z "$available_hosts_json" ]]; then
  echo "Error: failed to evaluate host list for system '$SYSTEM'." >&2
  echo "Try: nix eval --json '.#darwinConfigurations.${SYSTEM}' --apply 'builtins.attrNames'" >&2
  exit 1
fi

HOST="$(
  python3 - "$available_hosts_json" "${host_candidates[@]}" <<'PY'
import json, sys
hosts = json.loads(sys.argv[1])
candidates = sys.argv[2:]
for c in candidates:
    if c in hosts:
        print(c)
        raise SystemExit(0)
raise SystemExit(1)
PY
)" || {
  echo "Error: couldn't determine which host configuration to use." >&2
  echo "Tried: ${host_candidates[*]}" >&2
  echo "Available for ${SYSTEM}:" >&2
  python3 - "$available_hosts_json" <<'PY'
import json, sys
for h in json.loads(sys.argv[1]):
    print(f"  - {h}")
PY
  exit 1
}

if [[ "$HOST" == *.local ]]; then
  # Prefer the non-`.local` alias if present (see flake.nix `normalizeHostName`).
  host_without_local="${HOST%.local}"
  if python3 - "$available_hosts_json" "$host_without_local" <<'PY' >/dev/null; then
import json, sys
hosts = set(json.loads(sys.argv[1]))
candidate = sys.argv[2]
raise SystemExit(0 if candidate in hosts else 1)
PY
    echo "Note: using host '$host_without_local' (alias for '$HOST')." >&2
    HOST="$host_without_local"
  fi
fi

build_attr="$script_dir#darwinConfigurations.${SYSTEM}.\"${HOST}\".system"
flake_target="$script_dir#${SYSTEM}.${HOST}"

echo "Building: $build_attr" >&2
nix run nixpkgs#nix-output-monitor -- build --no-warn-dirty "$build_attr"

# Apply via the upstream entrypoint so the system profile is updated.
# This is what makes `/run/current-system` come back after reboot (since `/run`
# is ephemeral on macOS and is recreated at boot by `org.nixos.activate-system`).
darwin_rebuild=(darwin-rebuild)
if ! command -v darwin-rebuild >/dev/null 2>&1; then
  nix_darwin_rev="$(
    python3 - "$script_dir/flake.lock" <<'PY'
import json, sys
with open(sys.argv[1], "r", encoding="utf-8") as f:
    lock = json.load(f)
print(lock["nodes"]["nix-darwin"]["locked"]["rev"])
PY
  )"
  darwin_rebuild=(nix run "github:lnl7/nix-darwin/${nix_darwin_rev}#darwin-rebuild" --)
fi

echo "Switching system (this may prompt for sudo)..." >&2
sudo -H env NIX_REMOTE=daemon "${darwin_rebuild[@]}" switch --flake "$flake_target"

/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
killall skhd >/dev/null 2>&1 || true
