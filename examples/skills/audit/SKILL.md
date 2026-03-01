---
name: audit
description: Weekly brain audit - check for drift, stale refs, security issues
user-invocable: true
---

# /audit - Marcus Brain Audit

Run a comprehensive audit of Marcus's configuration to detect drift, inconsistencies, and security issues.

## What It Checks

### 🚨 Security (Critical)
1. LaunchAgent plist permissions (should be 600, not 644)
2. API keys not in workspace markdown files
3. SECURITY.md alert channel is Telegram (not iMessage)
4. No plaintext secrets in git-tracked files

### ⚠️ Consistency (High)
1. AGENTS.md model routing matches openclaw.json
2. Golden record (`80_reference/golden/`) synced with root files
3. Skills don't reference abandoned keychain
4. CONFIG.md channel references match enabled channels

### 📋 Freshness (Medium)
1. CUSTOMERS.md last sync date (should be <7 days)
2. QMD index freshness (should be <25h)
3. Heartbeat state file has recent `last_run`
4. WORKLOG.md has entries for recent days

### 🔧 Operations (Low)
1. All OpenClaw cron jobs healthy
2. LaunchAgents loaded and not erroring
3. Gateway running on expected port
4. Memory indexes not dirty

## Execution

Run the audit script:
```bash
bash {baseDir}/audit.sh
```

Or manually check each category using the checklist below.

## Manual Checklist

### Security
- [ ] `stat -f "%Sp" ~/Library/LaunchAgents/ai.openclaw.gateway.plist` shows `-rw-------`
- [ ] `grep -r "sk-ant\|sk-proj\|ntn_" ~/clawd/*.md` returns nothing
- [ ] SECURITY.md line 70 says "Telegram" not "iMessage"

### Consistency
- [ ] `diff ~/clawd/AGENTS.md ~/clawd/80_reference/golden/AGENTS.md` shows no diff
- [ ] AGENTS.md model routing matches `cat ~/.openclaw/openclaw.json | grep -A2 '"primary"'`
- [ ] `grep -l "security find-generic-password" ~/clawd/skills/*.md` - verify each is intentional

### Freshness
- [ ] CUSTOMERS.md "Last Synced" date within 7 days
- [ ] `qmd status` shows update within 25h
- [ ] `cat ~/clawd/90_state/heartbeat-state.json` shows recent last_run

### Operations
- [ ] `openclaw cron list` shows all jobs "ok" or "idle"
- [ ] `openclaw gateway status` shows "running"
- [ ] `launchctl list | grep openclaw` shows services

## Output

Save audit results to `90_state/audit-YYYY-MM-DD.md` with:
- Summary (pass/warn/fail counts)
- Details for each failed check
- Recommended fixes

## Scheduling

This skill runs via OpenClaw cron job "Weekly Config Drift Audit" every Sunday at 10pm.
