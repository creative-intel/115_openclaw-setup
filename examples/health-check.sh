#!/usr/bin/env bash
# health-check.sh — Marcus system health check
# Outputs tiered status: green (one summary), yellow (warnings only), red (criticals first)
set -uo pipefail

WARNINGS=()
CRITICALS=()

# ── 1. Gateway ────────────────────────────────────────────────────────────────
GW_OUTPUT=$(openclaw gateway status 2>/dev/null || true)
GATEWAY_RUNNING=false
GATEWAY_PID=""
if echo "$GW_OUTPUT" | grep -q "running (pid"; then
  GATEWAY_RUNNING=true
  GATEWAY_PID=$(echo "$GW_OUTPUT" | grep -oE "pid [0-9]+" | awk '{print $2}' | head -1)
else
  CRITICALS+=("openclaw gateway: not responding on :18789")
fi

# ── 2. Heartbeat ──────────────────────────────────────────────────────────────
HEARTBEAT_MINS_AGO=""
HEARTBEAT_CHECKS_TODAY=0
if [ -f ~/clawd/90_state/heartbeat-state.json ]; then
  HB_DATA=$(cat ~/clawd/90_state/heartbeat-state.json 2>/dev/null)
  HB_LAST_RUN=$(echo "$HB_DATA" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('last_run',''))" 2>/dev/null || true)
  HEARTBEAT_CHECKS_TODAY=$(echo "$HB_DATA" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('checks_completed_today',0))" 2>/dev/null || echo "0")
  if [ -n "$HB_LAST_RUN" ]; then
    HB_TS=$(echo "$HB_LAST_RUN" | sed 's/T/ /' | sed 's/\([+-][0-9][0-9]\):\([0-9][0-9]\)$/\1\2/')
    HB_EPOCH=$(date -j -f "%Y-%m-%d %H:%M:%S%z" "$HB_TS" "+%s" 2>/dev/null || date -d "$HB_LAST_RUN" "+%s" 2>/dev/null || true)
    if [ -n "$HB_EPOCH" ]; then
      NOW_EPOCH=$(date "+%s")
      HEARTBEAT_MINS_AGO=$(( (NOW_EPOCH - HB_EPOCH) / 60 ))
      if [ "$HEARTBEAT_MINS_AGO" -gt 90 ]; then
        CRITICALS+=("Last heartbeat: ${HEARTBEAT_MINS_AGO}m ago (expected 30m)")
      fi
    fi
  fi
fi

# ── 3. Cron jobs ──────────────────────────────────────────────────────────────
CRON_TOTAL=0
CRON_OK=0
CRON_ERRORS=()

CRON_TEXT=$(openclaw cron list 2>/dev/null || true)
if [ -n "$CRON_TEXT" ]; then
  # Each job line contains a UUID — count those
  while IFS= read -r line; do
    if echo "$line" | grep -qE "^[0-9a-f]{8}-"; then
      CRON_TOTAL=$((CRON_TOTAL + 1))
      # Extract status field (ok/idle/error) — it's after Last column
      STATUS=$(echo "$line" | grep -oE '\s(ok|idle|error)\s' | tr -d ' ' | head -1)
      NAME=$(echo "$line" | awk '{print $2}' | head -1)
      ERRORS=$(echo "$line" | grep -oE '[0-9]+ error' | awk '{print $1}' | head -1)
      if [ "$STATUS" = "error" ] || [ -n "$ERRORS" ]; then
        CRON_ERRORS+=("$NAME")
        WARNINGS+=("Cron: $NAME has errors")
      else
        CRON_OK=$((CRON_OK + 1))
      fi
    fi
  done <<< "$CRON_TEXT"
fi

# ── 4. Memory indexes ─────────────────────────────────────────────────────────
MEM_OUTPUT=$(openclaw memory status 2>/dev/null || true)

# main agent: "Indexed: 64/65 files" (first occurrence)
MAIN_INDEXED=$(echo "$MEM_OUTPUT" | grep "Indexed:" | head -1 | grep -oE "[0-9]+/[0-9]+" | head -1)
MAIN_DIRTY=$(echo "$MEM_OUTPUT" | grep "Dirty:" | head -1 | grep -oE "yes|no" | head -1)

# lite agent: second "Indexed:" line
LITE_INDEXED=$(echo "$MEM_OUTPUT" | grep "Indexed:" | sed -n '2p' | grep -oE "[0-9]+/[0-9]+" | head -1)
LITE_DIRTY=$(echo "$MEM_OUTPUT" | grep "Dirty:" | sed -n '2p' | grep -oE "yes|no" | head -1)

if [ "$MAIN_DIRTY" = "yes" ]; then
  WARNINGS+=("Memory: main index dirty (pending embeddings)")
fi
if [ "$LITE_DIRTY" = "yes" ]; then
  WARNINGS+=("Memory: lite index dirty (pending embeddings)")
fi

# ── 5. QMD status ─────────────────────────────────────────────────────────────
QMD_OUTPUT=$(~/.bun/bin/qmd status 2>/dev/null || true)
QMD_UPDATED=$(echo "$QMD_OUTPUT" | grep "Updated:" | grep -oE "[0-9]+[hmd] ago" | head -1)
QMD_VECTORS=$(echo "$QMD_OUTPUT" | grep "Vectors:" | grep -oE "[0-9]+" | head -1)

# Warn if updated >25h ago
if [ -n "$QMD_UPDATED" ]; then
  if echo "$QMD_UPDATED" | grep -qE "^[0-9]+d"; then
    WARNINGS+=("QMD: last update ${QMD_UPDATED} (>25h)")
  elif echo "$QMD_UPDATED" | grep -qE "^[0-9]+h"; then
    QMD_H=$(echo "$QMD_UPDATED" | grep -oE "^[0-9]+")
    if [ "$QMD_H" -gt 25 ]; then
      WARNINGS+=("QMD: last update ${QMD_UPDATED} (>25h)")
    fi
  fi
fi

# ── 6. QMD guard + memory refresh logs ───────────────────────────────────────
QMD_GUARD_LAST=$(tail -1 ~/clawd/90_state/qmd-guard.log 2>/dev/null || true)
if echo "$QMD_GUARD_LAST" | grep -qi "GAVE UP\|FAILED"; then
  CRITICALS+=("QMD guard: last run failed — check 90_state/qmd-guard.log")
fi

MEM_REFRESH_LAST=$(tail -1 ~/clawd/90_state/memory-refresh.log 2>/dev/null || true)
if echo "$MEM_REFRESH_LAST" | grep -qi "FAILED"; then
  WARNINGS+=("Memory refresh: last launchd run failed")
fi

# ── 7. Camofox ────────────────────────────────────────────────────────────────
CAMOFOX_JSON=$(curl -s --max-time 3 http://localhost:9377/health 2>/dev/null || true)
CAMOFOX_OK=false
CAMOFOX_SESSIONS=0
if echo "$CAMOFOX_JSON" | grep -q '"ok":true'; then
  CAMOFOX_OK=true
  CAMOFOX_SESSIONS=$(echo "$CAMOFOX_JSON" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('sessions',0))" 2>/dev/null || echo "0")
else
  WARNINGS+=("Camofox: not responding on :9377")
fi

# ── 8. Granola token ──────────────────────────────────────────────────────────
GRANOLA_VALID=false
GRANOLA_FILE=~/Library/Application\ Support/Granola/supabase.json
if [ -f "$GRANOLA_FILE" ]; then
  GRANOLA_TOKEN=$(python3 -c "
import json, sys
with open('$GRANOLA_FILE') as f:
    d = json.load(f)
wt = d.get('workos_tokens', '{}')
if isinstance(wt, str):
    wt = json.loads(wt)
print(wt.get('access_token', ''))
" 2>/dev/null || true)
  if [ -n "$GRANOLA_TOKEN" ]; then
    GRANOLA_RESP=$(curl -s --max-time 5 --compressed -X POST 'https://api.granola.ai/v2/get-documents' \
      -H "Authorization: Bearer $GRANOLA_TOKEN" -H 'Content-Type: application/json' \
      -d '{"limit":1,"offset":0}' 2>/dev/null || true)
    if echo "$GRANOLA_RESP" | python3 -c "import json,sys; d=json.load(sys.stdin); sys.exit(0 if d.get('docs') is not None else 1)" 2>/dev/null; then
      GRANOLA_VALID=true
    else
      WARNINGS+=("Granola: token invalid or API error")
    fi
  else
    WARNINGS+=("Granola: no access token in supabase.json")
  fi
else
  WARNINGS+=("Granola: supabase.json not found")
fi

# ── Output ────────────────────────────────────────────────────────────────────
NUM_WARN=${#WARNINGS[@]}
NUM_CRIT=${#CRITICALS[@]}

# Build reusable summary fields
HB_STR="${HEARTBEAT_MINS_AGO:-?}m ago"
MEM_STR="main ${MAIN_INDEXED:-?/?} · lite ${LITE_INDEXED:-?/?}"
GW_STR="running"; [ "$GATEWAY_RUNNING" = false ] && GW_STR="DOWN"
CAM_STR="online · ${CAMOFOX_SESSIONS} sessions"; [ "$CAMOFOX_OK" = false ] && CAM_STR="offline"
GRAN_STR="token valid"; [ "$GRANOLA_VALID" = false ] && GRAN_STR="token invalid"
QMD_STR="${QMD_UPDATED:-unknown}"; [ -z "$QMD_UPDATED" ] && QMD_STR="unknown"

if [ "$NUM_CRIT" -gt 0 ]; then
  echo "🚨 ${NUM_CRIT} critical issue(s)"
  for issue in "${CRITICALS[@]}"; do echo "→ $issue"; done
  if [ "$NUM_WARN" -gt 0 ]; then
    echo ""
    echo "⚠️ ${NUM_WARN} warning(s) also present"
    for issue in "${WARNINGS[@]}"; do echo "→ $issue"; done
  fi
  echo ""
  echo "Gateway: $GW_STR · Heartbeat: $HB_STR · Memory: $MEM_STR"

elif [ "$NUM_WARN" -gt 0 ]; then
  echo "⚠️ ${NUM_WARN} warning(s)"
  for issue in "${WARNINGS[@]}"; do echo "→ $issue"; done
  echo ""
  echo "Everything else ok."
  echo "Gateway: $GW_STR · Heartbeat: $HB_STR · Cron: ${CRON_OK}/${CRON_TOTAL} ok"

else
  echo "✅ All systems healthy"
  echo "Gateway: $GW_STR · pid ${GATEWAY_PID}"
  echo "Heartbeat: Haiku · last ${HB_STR} · ${HEARTBEAT_CHECKS_TODAY} checks today"
  echo "Cron: ${CRON_OK}/${CRON_TOTAL} jobs ok"
  echo "Memory: $MEM_STR · QMD ${QMD_STR}"
  echo "Camofox: $CAM_STR"
  echo "Granola: $GRAN_STR"
fi
