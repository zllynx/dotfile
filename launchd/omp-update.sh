#!/bin/sh
# omp auto-update (LaunchAgent com.zllynx.omp-update)
LOG="$HOME/Library/Logs/omp-update.log"
exec >> "$LOG" 2>&1

log() { printf '[%s] %s\n' "$(date '+%F %T')" "$*"; }

# Gate on network readiness: omp update checks registry.npmjs.org first.
# Fires right after wake sometimes; probe up to 10x30s before updating.
try=0
until /usr/bin/curl -fsS --connect-timeout 5 -o /dev/null https://registry.npmjs.org/; do
  try=$((try + 1))
  if [ "$try" -ge 10 ]; then
    log "network unreachable after $try probes, giving up"
    exit 1
  fi
  sleep 30
done

# Transient brew/git/CDN failures happen; retry up to 3 attempts.
attempt=1
while :; do
  out=$(/opt/homebrew/bin/omp update 2>&1)
  rc=$?
  flat=$(printf '%s\n' "$out" | tr '\n' ' ' | sed 's/  */ /g')
  if [ "$rc" -eq 0 ]; then
    log "$flat"
    exit 0
  fi
  if [ "$attempt" -ge 3 ]; then
    log "$flat [rc=$rc, gave up after $attempt attempts]"
    exit "$rc"
  fi
  log "$flat [rc=$rc, attempt $attempt failed, retrying]"
  attempt=$((attempt + 1))
  sleep 120
done
