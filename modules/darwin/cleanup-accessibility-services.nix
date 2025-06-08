{ config, pkgs, lib, ... }: {
  system.activationScripts.postActivation.text = ''
    echo >&2 "Cleaning up accessibility packages..."

    # macOS TCC accessibility database
    DB_PATH="/Library/Application Support/com.apple.TCC/TCC.db"

    # Backup the database first
    #sudo cp "$DB_PATH" "$DB_PATH.backup.$(date '+%Y%m%d%H%M%S')"
    #echo "Backup created at $DB_PATH.backup.$(date '+%Y%m%d%H%M%S')"

    # Get the list of apps from TCC.db
    apps=$(sudo sqlite3 "$DB_PATH" "SELECT client FROM access WHERE service='kTCCServiceAccessibility';")

    IFS=$'\n'
    for app in $apps; do
        eval expanded_app="$app"

        # shellcheck disable=SC2154
        [[ ! "$expanded_app" == ${builtins.storeDir}* ]] && continue

        case "$expanded_app" in
            ${lib.concatMapStringsSep "| \\\n" (pkg: "${lib.escapeShellArg pkg}*") config.environment.systemPackages})
            # shellcheck disable=SC2154
            echo "✓ $expanded_app"
            continue
            ;;
          *)
            ;;
        esac

        # shellcheck disable=SC2154
        echo "✗ $expanded_app"
        # gah... SIP qqqq
        #sudo sqlite3 "$DB_PATH" "DELETE FROM access WHERE client='$app' AND service='kTCCServiceAccessibility';"
    done


  '';
}
