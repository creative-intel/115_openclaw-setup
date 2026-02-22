# Automation: launchd vs OpenClaw Cron vs Heartbeat

Three scheduling mechanisms. Each has a purpose.

## Decision Guide

| Use Case | Mechanism |
|----------|-----------|
| Check inbox every 30min | Heartbeat |
| Send morning brief at 7am | OpenClaw cron (isolated, Haiku) |
| Index QMD at 2am nightly | macOS launchd |
| Refresh Kimi memory index | macOS launchd (with QMD) |
| Weekly docs review | OpenClaw cron (isolated, Haiku) |
| Anything needing LLM judgment | Heartbeat or OpenClaw cron |
| Pure shell, no LLM needed | macOS launchd |

## OpenClaw Cron

All OpenClaw cron jobs require an LLM call (main session event or isolated agent turn). No raw shell execution.

```bash
# Add a recurring isolated job
openclaw cron add \
  --name "Morning Brief" \
  --cron "0 7 * * *" \
  --tz "America/Detroit" \
  --session isolated \
  --message "Send morning briefing to [YOUR_USER]." \
  --announce
```

⚠️ Always specify `--model anthropic/claude-haiku-4-5` for isolated jobs to avoid using Sonnet.
⚠️ Add `anthropic/claude-haiku-4-5` to `agents.defaults.models` or the job will fail with `model not allowed`.

## macOS launchd

For pure shell jobs that don't need an LLM. Zero cost. Runs at 2am whether OpenClaw is busy or not.

See `scripts/memory-refresh.sh` and `scripts/ai.openclaw.memory-refresh.plist`.

Install:
```bash
cp scripts/ai.openclaw.memory-refresh.plist ~/Library/LaunchAgents/
launchctl load ~/Library/LaunchAgents/ai.openclaw.memory-refresh.plist
```

## Heartbeat

Runs in the main session every 30 minutes. Reads HEARTBEAT.md and handles all checks in one turn.

**Keep HEARTBEAT.md to 4 checks maximum.** More than that and the checks start interfering with each other and with active work.

Move mechanical checks (index refresh, log rotation) to launchd. Keep only checks that need judgment (inbox, tasks, transcripts, briefing) in heartbeat.
