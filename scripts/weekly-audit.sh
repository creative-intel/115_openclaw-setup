#!/usr/bin/env bash
# audit.sh - Marcus Brain Audit Script
# Runs weekly via OpenClaw cron, outputs to 90_state/audit-YYYY-MM-DD.md

set -uo pipefail

WORKSPACE="/Users/marcus/clawd"
DATE=$(date +%Y-%m-%d)
OUTPUT="$WORKSPACE/90_state/audit-$DATE.md"
PASS=0
WARN=0
FAIL=0

log_pass() { echo "✅ $1"; ((PASS++)); }
log_warn() { echo "⚠️ $1"; ((WARN++)); }
log_fail() { echo "🚨 $1"; ((FAIL++)); }

{
echo "# Marcus Brain Audit - $DATE"
echo ""
echo "Generated: $(date)"
echo ""
echo "---"
echo ""

# ══════════════════════════════════════════════════════════════════════════════
echo "## 🚨 Security Checks"
echo ""

# 1. LaunchAgent plist permissions
PLIST_PERMS=$(stat -f "%Lp" ~/Library/LaunchAgents/ai.openclaw.gateway.plist 2>/dev/null || echo "missing")
if [ "$PLIST_PERMS" = "600" ]; then
  log_pass "Gateway plist permissions: 600 (owner only)"
elif [ "$PLIST_PERMS" = "missing" ]; then
  log_fail "Gateway plist not found"
else
  log_fail "Gateway plist permissions: $PLIST_PERMS (should be 600)"
fi

# 2. Check for API keys in workspace markdown
SECRETS_FOUND=$(grep -rE "sk-ant-|sk-proj-|ntn_[a-zA-Z0-9]" "$WORKSPACE"/*.md 2>/dev/null | grep -v "audit-" | head -3 || true)
if [ -z "$SECRETS_FOUND" ]; then
  log_pass "No API keys found in root markdown files"
else
  log_fail "API keys found in markdown files:"
  echo "\`\`\`"
  echo "$SECRETS_FOUND"
  echo "\`\`\`"
fi

# 3. SECURITY.md alert channel
ALERT_CHANNEL=$(grep -i "Alert Cort" "$WORKSPACE/SECURITY.md" | head -1 || true)
if echo "$ALERT_CHANNEL" | grep -qi "telegram"; then
  log_pass "SECURITY.md alert channel: Telegram"
elif echo "$ALERT_CHANNEL" | grep -qi "imessage"; then
  log_fail "SECURITY.md still references iMessage for alerts"
else
  log_warn "SECURITY.md alert channel unclear"
fi

echo ""

# ══════════════════════════════════════════════════════════════════════════════
echo "## ⚠️ Consistency Checks"
echo ""

# 4. Model routing consistency
AGENTS_MODEL=$(grep -A1 "primary" "$WORKSPACE/AGENTS.md" 2>/dev/null | grep -oE "Kimi|Sonnet|Haiku|kimi|sonnet|haiku" | head -1 || echo "unknown")
CONFIG_MODEL=$(cat ~/.openclaw/openclaw.json 2>/dev/null | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('agents',{}).get('defaults',{}).get('model',{}).get('primary','unknown'))" 2>/dev/null || echo "unknown")
if echo "$CONFIG_MODEL" | grep -qi "kimi" && echo "$AGENTS_MODEL" | grep -qi "kimi"; then
  log_pass "Model routing consistent: Kimi in both AGENTS.md and config"
elif echo "$CONFIG_MODEL" | grep -qi "sonnet" && echo "$AGENTS_MODEL" | grep -qi "sonnet"; then
  log_pass "Model routing consistent: Sonnet in both AGENTS.md and config"
else
  log_warn "Model routing mismatch: AGENTS.md says '$AGENTS_MODEL', config says '$CONFIG_MODEL'"
fi

# 5. Golden record sync
AGENTS_DIFF=$(diff -q "$WORKSPACE/AGENTS.md" "$WORKSPACE/80_reference/golden/AGENTS.md" 2>/dev/null || echo "differs")
if [ -z "$AGENTS_DIFF" ]; then
  log_pass "Golden record AGENTS.md in sync"
else
  log_warn "Golden record AGENTS.md differs from root"
fi

# 6. iMessage references in active files
IMSG_REFS=$(grep -l "iMessage" "$WORKSPACE/AGENTS.md" "$WORKSPACE/CONFIG.md" "$WORKSPACE/SECURITY.md" 2>/dev/null | wc -l | tr -d ' ')
if [ "$IMSG_REFS" = "0" ]; then
  log_pass "No iMessage references in core config files"
else
  log_warn "iMessage still referenced in $IMSG_REFS core config file(s)"
fi

echo ""

# ══════════════════════════════════════════════════════════════════════════════
echo "## 📋 Freshness Checks"
echo ""

# 7. CUSTOMERS.md sync date
CUSTOMERS_DATE=$(grep -i "Last Synced" "$WORKSPACE/CUSTOMERS.md" 2>/dev/null | grep -oE "[0-9]{4}-[0-9]{2}-[0-9]{2}" | head -1 || echo "unknown")
if [ "$CUSTOMERS_DATE" != "unknown" ]; then
  DAYS_AGO=$(( ($(date +%s) - $(date -j -f "%Y-%m-%d" "$CUSTOMERS_DATE" +%s 2>/dev/null || echo 0)) / 86400 ))
  if [ "$DAYS_AGO" -lt 7 ]; then
    log_pass "CUSTOMERS.md synced $DAYS_AGO days ago"
  elif [ "$DAYS_AGO" -lt 30 ]; then
    log_warn "CUSTOMERS.md synced $DAYS_AGO days ago (should be <7)"
  else
    log_fail "CUSTOMERS.md synced $DAYS_AGO days ago (very stale)"
  fi
else
  log_warn "CUSTOMERS.md sync date not found"
fi

# 8. QMD freshness
QMD_STATUS=$(~/.bun/bin/qmd status 2>/dev/null | grep "Updated:" | head -1 || echo "unknown")
if echo "$QMD_STATUS" | grep -qE "[0-9]+m ago|[0-9]+h ago"; then
  log_pass "QMD index: $QMD_STATUS"
elif echo "$QMD_STATUS" | grep -qE "[0-9]+d ago"; then
  log_warn "QMD index stale: $QMD_STATUS"
else
  log_warn "QMD status unclear: $QMD_STATUS"
fi

# 9. Heartbeat recency
HB_LAST=$(cat "$WORKSPACE/90_state/heartbeat-state.json" 2>/dev/null | python3 -c "import json,sys; print(json.load(sys.stdin).get('last_run','unknown'))" 2>/dev/null || echo "unknown")
if [ "$HB_LAST" != "unknown" ]; then
  log_pass "Last heartbeat: $HB_LAST"
else
  log_warn "Heartbeat state not readable"
fi

echo ""

# ══════════════════════════════════════════════════════════════════════════════
echo "## 🔧 Operations Checks"
echo ""

# 10. Gateway status
GW_STATUS=$(openclaw gateway status 2>/dev/null || echo "unknown")
if echo "$GW_STATUS" | grep -qi "running (pid"; then
  log_pass "Gateway: running"
elif echo "$GW_STATUS" | grep -qi "loaded"; then
  log_pass "Gateway: loaded"
else
  log_fail "Gateway: not running"
fi

# 11. Cron jobs
CRON_OUTPUT=$(openclaw cron list 2>/dev/null || echo "")
CRON_ERRORS=$(echo "$CRON_OUTPUT" | grep -c " error " 2>/dev/null || echo "0")
CRON_TOTAL=$(echo "$CRON_OUTPUT" | grep -cE "^[0-9a-f]{8}-" 2>/dev/null || echo "0")
CRON_ERRORS=${CRON_ERRORS:-0}
CRON_TOTAL=${CRON_TOTAL:-0}
if [ "$CRON_ERRORS" = "0" ] && [ "$CRON_TOTAL" -gt 0 ]; then
  log_pass "Cron jobs: $CRON_TOTAL jobs, 0 errors"
elif [ "$CRON_TOTAL" = "0" ]; then
  log_warn "Cron jobs: none found"
else
  log_warn "Cron jobs: $CRON_ERRORS errors out of $CRON_TOTAL jobs"
fi

# 12. Memory index dirty
MEM_OUTPUT=$(openclaw memory status 2>/dev/null || echo "")
MEM_DIRTY=$(echo "$MEM_OUTPUT" | grep "Dirty:" | grep -c "yes" 2>/dev/null || echo "0")
MEM_DIRTY=${MEM_DIRTY:-0}
if [ "$MEM_DIRTY" = "0" ]; then
  log_pass "Memory indexes: clean"
else
  log_warn "Memory indexes: $MEM_DIRTY dirty (pending embeddings)"
fi

echo ""

# ══════════════════════════════════════════════════════════════════════════════
echo "---"
echo ""
echo "## Summary"
echo ""
echo "| Status | Count |"
echo "|--------|-------|"
echo "| ✅ Pass | $PASS |"
echo "| ⚠️ Warn | $WARN |"
echo "| 🚨 Fail | $FAIL |"
echo ""

if [ "$FAIL" -gt 0 ]; then
  echo "**Action Required:** $FAIL critical issue(s) need immediate attention."
elif [ "$WARN" -gt 0 ]; then
  echo "**Review Recommended:** $WARN warning(s) should be addressed."
else
  echo "**All Clear:** No issues detected."
fi

echo ""
echo "---"
echo "*Generated by /audit skill*"

} > "$OUTPUT"

echo "Audit complete: $OUTPUT"
echo "Pass: $PASS | Warn: $WARN | Fail: $FAIL"

# Exit with error if any failures
[ "$FAIL" -eq 0 ]
