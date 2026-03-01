# Marcus Runbook - Common Operations & Failures

> Quick reference for common issues and their fixes.
> For detailed audit, run `/audit` or `bash ~/clawd/skills/audit/audit.sh`

---

## 🚨 Emergency Procedures

### Gateway Not Responding
```bash
# Check status
openclaw gateway status

# Restart
openclaw gateway restart

# If still failing, check logs
tail -100 ~/.openclaw/logs/gateway.log
```

### Model Fallback Triggered
```bash
# Check what happened
grep -i "fallback\|error" ~/.openclaw/logs/gateway.log | tail -20

# If Kimi is down, temporarily switch to Sonnet
# Edit ~/.openclaw/openclaw.json → agents.defaults.model.primary
openclaw gateway restart
```

### Heartbeat Stopped
```bash
# Check heartbeat state
cat ~/clawd/90_state/heartbeat-state.json

# Force a heartbeat
openclaw heartbeat trigger

# Check if it ran
openclaw heartbeat status
```

---

## 🔧 Common Operations

### Restart Everything
```bash
openclaw gateway restart
# LaunchAgents restart automatically
```

### Refresh Memory Indexes
```bash
# Safe way (with retry logic)
~/clawd/50_tools/qmd-guard.sh both

# Check status
qmd status
```

### Backup Config Before Changes
```bash
~/clawd/50_tools/backup-config.sh
```

### Run Health Check
```bash
~/clawd/50_tools/health-check.sh
```

### Run Full Audit
```bash
bash ~/clawd/skills/audit/audit.sh
cat ~/clawd/90_state/audit-$(date +%Y-%m-%d).md
```

---

## 🔄 Model Routing

### Current Config (as of 2026-03-01)
- **Primary:** moonshot/kimi-k2.5
- **Fallback:** anthropic/claude-haiku-4-5
- **Heartbeat:** moonshot/kimi-k2.5

### Revert to Sonnet (if Kimi fails)
```bash
cp ~/.openclaw/openclaw.json.backup-2026-02-28-pre-kimi ~/.openclaw/openclaw.json
openclaw gateway restart
```

### Switch Models Manually
Edit `~/.openclaw/openclaw.json`:
```json
"agents": {
  "defaults": {
    "model": {
      "primary": "moonshot/kimi-k2.5",
      "fallbacks": ["anthropic/claude-haiku-4-5"]
    }
  }
}
```
Then: `openclaw gateway restart`

---

## 📱 Messaging

### Telegram Only (iMessage Disabled)
- iMessage was disabled 2026-02-28 due to routing issues
- All messaging goes through Telegram
- To re-enable iMessage (not recommended):
  - Edit `~/.openclaw/openclaw.json` → `channels.imessage.enabled: true`
  - Edit `~/.openclaw/openclaw.json` → `plugins.entries.imessage.enabled: true`

### Send Alert to Cort
```bash
~/clawd/50_tools/alert-telegram.sh "Your message" CRITICAL
```

---

## 📊 Cron Jobs

### List All Jobs
```bash
openclaw cron list
```

### Current Jobs (as of 2026-03-01)
| Job | Schedule | Purpose |
|-----|----------|---------|
| Morning Briefing | 7am daily | Weather, tasks, email summary |
| clawd-git-auto-push | 2am daily | Auto-commit workspace |
| Weekly Config Drift Audit | Sun 10pm | Run /audit skill |
| Morgan Weekly Reconciliation | Mon 9am | Accounting sync |
| Month-End Close Reminder | 5th 9am | Accounting reminder |
| OpenClaw Update Check | Sun 6am | Check for updates |

### Add New Cron Job
```bash
openclaw cron add "Job Name" --schedule "cron 0 9 * * *" --prompt "Your prompt here"
```

### Remove Cron Job
```bash
openclaw cron remove <job-id>
```

---

## 🔐 Credentials

### Location
- **Primary:** `~/.openclaw/openclaw.json` (env section, skills.entries)
- **Manus API:** macOS Keychain (`manus.api_key`)
- **OAuth tokens:** `~/.config/gmail-cli/`

### Rotate API Key
1. Generate new key from provider
2. Update in `~/.openclaw/openclaw.json`
3. Run `openclaw gateway restart`
4. Test with a simple query

---

## 📁 Key Files

| File | Purpose |
|------|---------|
| `~/.openclaw/openclaw.json` | Main config |
| `~/clawd/AGENTS.md` | Operating manual |
| `~/clawd/90_state/heartbeat-state.json` | Heartbeat tracking |
| `~/clawd/90_state/audit-*.md` | Audit reports |
| `~/.openclaw/logs/gateway.log` | Gateway logs |

---

## 🆘 Escalation

If you can't fix it:
1. Alert Cort via Telegram
2. Document the issue in WORKLOG.md
3. Check OpenClaw Discord/docs for known issues
4. File GitHub issue if it's a bug

---

*Last updated: 2026-03-01*
