#!/bin/sh
# omp auto-update (LaunchAgent com.zllynx.omp-update)
LOG="$HOME/Library/Logs/omp-update.log"
exec >> "$LOG" 2>&1

out=$(/opt/homebrew/bin/omp update 2>&1)
printf '[%s] %s\n' "$(date '+%F %T')" "$(printf '%s\n' "$out" | tr '\n' ' ' | sed 's/  */ /g')"
