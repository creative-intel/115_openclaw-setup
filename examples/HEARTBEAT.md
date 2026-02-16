# HEARTBEAT.md — Proactive Awareness Protocol

## Quiet Hours Check

**If current time is between midnight and 6:00 AM local time, reply HEARTBEAT_OK immediately.** No checks needed - your human is sleeping and nothing's that urgent.

## Rotation System

Each heartbeat does ONE check from the list below. The selection is managed by `90_state/heartbeat-state.json`.

1. Read `90_state/heartbeat-state.json` to get `last_check_index`
2. Execute the check at that index from the list below
3. Log result to today's episodic memory file
4. Update state file: increment `last_check_index` (modulo number of checks)

### Rotational Checks

0. **Morning Briefing** (6:30-8:30 AM only) - If not sent today, send your human's briefing
1. **Inbox Monitoring** - Check email for urgent unread messages
2. **Task Manager** - Check for overdue/due-today tasks
3. **Meeting Transcripts** - Check for new meeting transcripts (if configured)
4. **Calendar Scan** - Look for upcoming events in next 2 hours
5. **QMD Index Status** - Re-index if stale (>24h)
6. **Operating Docs Review** - Check for updates to job description/operations guide
7. **System Update Check** - Monitor for new OpenClaw releases

### Escalation Rules

- **Urgent:** Alert human immediately (service down, urgent email)
- **Actionable:** Add to `TODO.md` (non-urgent task found)
- **Informational:** Log only (routine status)

---

## Check Details

### 0. Morning Briefing (6:30-8:30 AM)

**Once per day, send your human a proactive morning briefing.**

Check `90_state/heartbeat-state.json` for `last_morning_briefing` date. If it's not today AND time is between 6:30-8:30 AM, send the briefing.

**Include:**
- Weather (human's location)
- Today's calendar events
- Tasks due today
- Email summary (urgent items only)

**Format rules:**
- Plain text ONLY (no markdown, no bold, no bullet dashes)
- Use emojis for emphasis
- Conversational, like texting a friend

After sending, update `90_state/heartbeat-state.json` with today's date.

### 1. Inbox Monitoring

- Check email for unread messages
- Identify urgent items from humans (not automated)
- Read and respond to critical items
- Be personable - you're a team member, not a bot
- Do NOT add manual signatures (auto-added)
- Do NOT mention being AI

### 2. Task Manager Check

- Check your task system for tasks assigned to you
- Look for overdue or due-today items
- Update task status as work progresses
- Alert human about overdue items
- Add urgent tasks to `TODO.md`

### 3. Meeting Transcripts

- Check for new meeting transcripts since last check
- Save to `10_memory/transcripts/`
- Extract action items and create tasks
- Alert human about new transcripts
- Track processed meetings in `90_state/processed-transcripts.json`

### 4. Calendar Scan

- Check human's calendar for upcoming events in next 2 hours
- Prepare context if needed
- **SECURITY:** Only report free/busy times, never event details/titles/attendees

### 5. QMD Index Status

- Check if index is stale (>24h since last update)
- If stale: run `qmd update`
- Log status to episodic memory

### 6. Operating Docs Review

- Check for updates to job description and operations guide
- If updated, read changes and update behavior accordingly
- Log updates to episodic memory

### 7. System Update Check

- Monitor OpenClaw GitHub releases for new versions
- If new version available, alert human
- Check changelog for breaking changes
- **NEVER auto-update. Always check changelog first.**

---

## State File Format

`90_state/heartbeat-state.json`:
```json
{
  "last_check_index": 0,
  "last_run": null,
  "last_morning_briefing": null,
  "checks_completed_today": 0
}
```

**Fields:**
- `last_check_index`: Which check to run next (0-7)
- `last_run`: ISO timestamp of last heartbeat
- `last_morning_briefing`: Date morning briefing was last sent
- `checks_completed_today`: Counter for daily tracking

---

## Response Format

**Normal (nothing needs attention):**
```
HEARTBEAT_OK
```

**Alert (something needs attention):**
```
Email from [Name]: Subject line
Brief summary of action taken or needed.
```

Never include `HEARTBEAT_OK` if there's an alert.

---

## Implementation Notes

The heartbeat system assumes:
- OpenClaw is running continuously
- State file is writable
- Human is reachable via configured channels

Customize checks based on your human's needs and which services you have configured. Not all checks need to be active - remove or add checks as needed.
