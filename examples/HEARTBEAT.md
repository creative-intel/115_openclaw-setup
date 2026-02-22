# HEARTBEAT.md — Proactive Awareness Protocol

## Quiet Hours Check
**If current time is between midnight and 6:00 AM ([YOUR_TIMEZONE]), reply HEARTBEAT_OK immediately.** No checks needed - [YOUR_USER] is sleeping and nothing's that urgent.

## Rotation System

Each heartbeat does ONE check from the list below. The selection is managed by `90_state/heartbeat-state.json`.

1. Read `90_state/heartbeat-state.json` to get `last_check_index`
2. Execute the check at that index from the list below
3. Log result to today's episodic memory file
4. Update state file: increment `last_check_index` (modulo number of checks)

### Rotational Checks (4 checks, index 0–3)

0. **Morning Briefing** (6:30-8:30 AM only) — If not sent today, send [YOUR_USER]'s briefing
1. **Inbox Monitoring** — Check Gmail for urgent unread messages
2. **Notion Task Manager** — Check for overdue/due-today tasks assigned to you
3. **Granola Transcripts** — Check for new meeting transcripts

> **Automated (not heartbeat):**
> - QMD + Kimi index refresh → launchd `ai.openclaw.memory-refresh` (2am daily)
> - Operating docs review → OpenClaw cron `Weekly Config Drift Audit` (Sun 10pm)
> - OpenClaw update check → OpenClaw cron `OpenClaw Update Check` (Sun 6am)
>
> ⚠️ Morning Briefing also runs as OpenClaw cron at 7am daily. Heartbeat check #0 is a fallback only — skip if `lastMorningBriefing` is already today.

### Escalation Rules

- **Urgent:** Alert [YOUR_USER] immediately (service down, urgent email)
- **Actionable:** Add to `TODO.md` (non-urgent task found)
- **Informational:** Log only (routine status)

---

## Check Details

### 0. Morning Briefing (6:30-8:30 AM — fallback only)
Skip if `90_state/heartbeat-state.json` shows `lastMorningBriefing` is already today (cron handles it at 7am).

If not yet sent: weather ([YOUR_LOCATION]), tasks due today, urgent emails. Plain text, emojis OK. Update `lastMorningBriefing` after sending.

### 1. Inbox Monitoring
- `~/bin/gmail list --max 10` + `~/bin/gmail list --max 5 --query "in:spam"`
- If unread emails from humans: read and respond. No manual signatures. Don't mention being AI.

### 2. Notion Task Manager Check
- Query Task Manager (DB: `[YOUR_NOTION_DB_ID]`) for tasks assigned to you
- Check overdue/due-today. Update status as work progresses.

### 3. Granola Meeting Transcripts
- Check for new transcripts since last check. Track in `90_state/processed-transcripts.json`.
- When new transcript found: alert [YOUR_USER] and run `/sync`.

---

## State File Format

`90_state/heartbeat-state.json`:
```json
{
  "last_check_index": 0,
  "last_run": "2026-02-11T23:00:00-05:00",
  "last_morning_briefing": "2026-02-11",
  "checks_completed_today": 0
}
```
