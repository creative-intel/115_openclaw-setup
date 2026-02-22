#!/usr/bin/env bash
# qmd-guard.sh — Safe QMD index update with retry backoff and failure logging
# Usage: qmd-guard.sh [update|embed|both]
# Wraps qmd update / qmd embed with:
#   - Max 3 attempts before giving up
#   - Exponential backoff on rate limit / error
#   - Failure logging to 90_state/qmd-guard.log
#   - Exit code 0 = success, 1 = failed after retries

set -euo pipefail

WORKSPACE="${WORKSPACE:-/Users/you/clawd}"
LOG_FILE="$WORKSPACE/90_state/qmd-guard.log"
QMD="${HOME}/.bun/bin/qmd"
MAX_RETRIES=3
BACKOFF_BASE=30  # seconds; doubles each retry

MODE="${1:-both}"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

log() {
  echo "[$TIMESTAMP] $*" | tee -a "$LOG_FILE"
}

run_with_retry() {
  local cmd=("$@")
  local attempt=1
  local wait_secs=$BACKOFF_BASE

  while [ $attempt -le $MAX_RETRIES ]; do
    log "Attempt $attempt/$MAX_RETRIES: ${cmd[*]}"
    if output=$("${cmd[@]}" 2>&1); then
      log "OK: ${cmd[*]}"
      return 0
    else
      exit_code=$?
      log "FAIL (exit $exit_code): ${cmd[*]}"
      log "Output: $output"

      # Detect error type for logging (rate limits are retriable; others may not be)
      if echo "$output" | grep -qiE "rate.?limit|429|too many requests"; then
        log "Rate limit detected — backing off ${wait_secs}s before retry"
      elif echo "$output" | grep -qiE "UNIQUE constraint|SQLiteError|SQLITE_CONSTRAINT"; then
        log "SQLite constraint error — run 'qmd cleanup' to fix orphaned records, then retry"
      elif echo "$output" | grep -qiE "ENOENT|no such file"; then
        log "Missing path error — check for ghost collections via 'qmd collection list'"
      else
        log "Error detected — backing off ${wait_secs}s before retry"
      fi

      if [ $attempt -lt $MAX_RETRIES ]; then
        sleep "$wait_secs"
        wait_secs=$((wait_secs * 2))
      fi

      attempt=$((attempt + 1))
    fi
  done

  log "GAVE UP after $MAX_RETRIES attempts: ${cmd[*]}"
  return 1
}

overall_status=0

if [ "$MODE" = "update" ] || [ "$MODE" = "both" ]; then
  if ! run_with_retry "$QMD" update; then
    log "qmd update failed — skipping embed"
    overall_status=1
  fi
fi

if [ "$MODE" = "embed" ] || [ "$MODE" = "both" ]; then
  if [ $overall_status -eq 0 ] || [ "$MODE" = "embed" ]; then
    if ! run_with_retry "$QMD" embed; then
      log "qmd embed failed"
      overall_status=1
    fi
  fi
fi

if [ $overall_status -eq 0 ]; then
  log "qmd-guard completed successfully (mode: $MODE)"
else
  log "qmd-guard finished with failures (mode: $MODE) — check $LOG_FILE"
fi

exit $overall_status
