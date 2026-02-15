# HEARTBEAT.md — Proactive Awareness Protocol

## Overview

The heartbeat system runs periodic checks to catch issues before they become problems. Think of it as a cron job for awareness.

## Rotation System

Each heartbeat does **ONE** check. The selection is managed by `90_state/heartbeat-state.json`.

### How It Works

1. Read `90_state/heartbeat-state.json` to get `last_check_index`
2. Execute the check at that index
3. Log result to today's episodic memory
4. Update state file: increment `last_check_index`

### Check Rotation

0. **Morning Briefing** (6:30-8:30 AM only)
1. **Inbox Monitoring** — Check email for urgent unread
2. **Task Manager** — Check for overdue/due-today tasks
3. **Meeting Transcripts** — Check for new transcripts
4. **Calendar Scan** — Look for upcoming events
5. **QMD Index Status** — Re-index if stale
6. **Operating Docs** — Check for updates to guides
7. **System Updates** — Check for OpenClaw updates

### Escalation Rules

- **Urgent:** Alert human immediately
- **Actionable:** Add to `TODO.md`
- **Informational:** Log only

---

## Check Details

### 0. Morning Briefing (6:30-8:30 AM only)

**Trigger:** Once per day, between 6:30-8:30 AM local time.

**Check:** `90_state/heartbeat-state.json` for `last_morning_briefing` date

**Content:**
- Weather (human's location)
- Today's calendar events
- Tasks due today
- Email summary (urgent only)

**Format:**
- Plain text only (no markdown)
- Emojis for emphasis
- Conversational, like texting

**After sending:** Update `last_morning_briefing` to today's date

---

### 1. Inbox Monitoring

**Check:** Email for unread messages

**Actions:**
- List unread emails
- Identify urgent items (from humans, not automated)
- Read and respond to critical items
- Mark spam checks as complete

**Response style:**
- Be personable
- No manual signatures (added automatically)
- Never mention being AI

---

### 2. Task Manager Check

**Check:** Notion Task Manager (or configured task system)

**Look for:**
- Tasks assigned to you
- Overdue items
- Due-today items
- High priority items

**Actions:**
- Update task status as work progresses
- Alert human about overdue items
- Add urgent tasks to `TODO.md`

---

### 3. Meeting Transcripts

**Check:** Granola (or configured transcript service)

**Look for:**
- New meetings since last check
- Unprocessed transcripts

**Actions:**
- Fetch new transcripts
- Save to `10_memory/transcripts/`
- Extract action items
- Alert human about new transcripts
- Update `90_state/processed-transcripts.json`

---

### 4. Calendar Scan

**Check:** Human's calendar for upcoming events

**Look for:**
- Events in next 2 hours
- Changes to existing events

**Actions:**
- Prepare context if needed
- Alert about upcoming meetings
- **SECURITY:** Only report free/busy, never details

---

### 5. QMD Index Status

**Check:** QMD index freshness

**Look for:**
- Last update timestamp
- Files pending indexing

**Actions:**
- If stale (>24h): Run `qmd update`
- If many pending: Run `qmd embed`
- Log status to episodic memory

---

### 6. Operating Docs Review

**Check:** Notion (or configured docs) for updates

**Look for:**
- Changes to job description
- Changes to operations guide
- New procedures

**Actions:**
- Read changes
- Update behavior accordingly
- Log updates to episodic memory

---

### 7. System Update Check

**Check:** OpenClaw GitHub releases

**Look for:**
- New versions
- Security patches
- Breaking changes

**Actions:**
- Alert human about available updates
- Do NOT auto-update
- Provide changelog summary

---

## State File Format

`90_state/heartbeat-state.json`:

```json
{
  "last_check_index": 3,
  "last_run": "2026-02-15T14:00:00-05:00",
  "last_morning_briefing": "2026-02-15",
  "checks_completed_today": 15
}
```

**Fields:**
- `last_check_index`: Which check to run next (0-7)
- `last_run`: ISO timestamp of last heartbeat
- `last_morning_briefing`: Date morning briefing was last sent
- `checks_completed_today`: Counter for daily tracking

---

## Quiet Hours

**Midnight to 6:00 AM:** No checks run. Reply `HEARTBEAT_OK` immediately.

**Why:** Human is sleeping. Nothing is that urgent.

---

## Response Format

### Normal: HEARTBEAT_OK

If nothing needs attention:
```
HEARTBEAT_OK
```

### Alert: Description

If something needs attention:
```
**Email from [Name]:** Subject line
Brief summary of action taken or needed.
```

Never include `HEARTBEAT_OK` if there's an alert.

---

## Manual Trigger

To run a specific check manually:

```bash
# Set the check index in state file
jq '.last_check_index = 2' 90_state/heartbeat-state.json > tmp.json
mv tmp.json 90_state/heartbeat-state.json

# Trigger heartbeat (will run check #2)
# [Your heartbeat trigger mechanism]
```

---

## Implementation Notes

The heartbeat system assumes:
- OpenClaw is running continuously
- State file is writable
- Human is reachable via configured channels
- All services (email, calendar, etc.) are configured

Customize checks based on your human's needs.
