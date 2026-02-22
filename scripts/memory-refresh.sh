#!/usr/bin/env bash
# memory-refresh.sh — Nightly QMD + Kimi index refresh (runs via launchd at 2am)
# Calls qmd-guard.sh for safe QMD update, then refreshes the lite (Kimi) index.
# Logs to 90_state/memory-refresh.log (captured by launchd stdout/stderr).

set -euo pipefail

WORKSPACE="/Users/you/clawd"
GUARD="$WORKSPACE/50_tools/qmd-guard.sh"
OPENCLAW="/usr/local/bin/openclaw"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

echo "[$TIMESTAMP] memory-refresh starting"

# Step 1: QMD update + embed via guard script
if bash "$GUARD" both; then
    echo "[$TIMESTAMP] QMD refresh: OK"
else
    echo "[$TIMESTAMP] QMD refresh: FAILED — see qmd-guard.log for details"
fi

# Step 2: Kimi (lite) index refresh — always run regardless of QMD result
if "$OPENCLAW" memory index --agent lite 2>&1; then
    echo "[$TIMESTAMP] Kimi index refresh: OK"
else
    echo "[$TIMESTAMP] Kimi index refresh: FAILED"
fi

echo "[$TIMESTAMP] memory-refresh complete"
