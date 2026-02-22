# Real Failures (And What Fixed Them)

These are actual production failures from running this setup. Not theory — things that happened and cost real time/money.

---

## 1. Wrong Haiku Model Name

**What happened:** Switched heartbeats from Sonnet to Haiku for cost savings. Used `anthropic/claude-haiku-4`. Every heartbeat silently failed for hours. Also used the same wrong name in cron jobs.

**Symptom:** Gateway error log: `FailoverError: Unknown model: anthropic/claude-haiku-4` repeating every 30 minutes. Cron jobs showing `consecutiveErrors: 3+`.

**Fix:** The correct name is `anthropic/claude-haiku-4-5`.

**Prevention:** Always verify model names against `openclaw models list` before configuring.

---

## 2. Lite Agent Running Blind

**What happened:** Set up the lite (Kimi) agent for execution tasks. Never ran `openclaw memory index --agent lite`. Kimi had 0/64 files indexed for weeks. Ran every task with zero memory retrieval.

**Symptom:** No errors. Just subtly worse output — Kimi couldn't look up repo locations, customer naming conventions, file structures.

**Fix:** `openclaw memory index --agent lite` — one command, fixed immediately.

**Prevention:** Include `openclaw memory index --agent lite` in nightly launchd refresh. Verify with `openclaw memory status --agent lite`.

---

## 3. QMD Silent Crash

**What happened:** `qmd update` was running via heartbeat. SQLite UNIQUE constraint error caused it to fail silently. The index became stale but no alerts fired.

**Symptom:** Search results from days ago. No error messages anywhere obvious.

**Fix:** `qmd cleanup` to remove orphaned records, then `qmd update`.

**Prevention:** Use `qmd-guard.sh` instead of raw `qmd update`. The guard classifies errors and logs failures to a readable log file.

---

## 4. Ghost QMD Collection

**What happened:** A `life` collection was configured pointing to `/Users/marcus/clawd/life` which didn't exist. Every `qmd update` run hit an ENOENT error on this collection.

**Symptom:** `qmd update` partially succeeds then errors on the ghost collection.

**Fix:** `qmd collection list` to find it, `qmd collection remove life` to remove it.

**Prevention:** After any workspace reorganization, run `qmd collection list` and verify all paths exist.

---

## 5. iMessage Group Routing Confusion

**What happened:** Multi-party iMessage sessions caused routing failures. Messages from a third party arrived in the wrong session context, got incorrect replies.

**Root cause:** iMessage has no threading, group chats require different tools than DMs, and queued messages from different senders collapse into one stream.

**Fix:** Switched to Telegram as primary ops channel. Proper group support, threading, clear routing.

**Prevention:** Use Telegram for anything involving more than one contact or multi-party conversations.

---

## 6. Model Not Allowed in Isolated Cron

**What happened:** Configured cron jobs to use `anthropic/claude-haiku-4-5`. Jobs failed with `model not allowed: anthropic/claude-haiku-4-5`.

**Root cause:** Isolated cron sessions require the model to be explicitly listed in `agents.defaults.models`. It's not an allowlist per se, but the config entry is required.

**Fix:** Add to `openclaw.json`:
```json5
{ agents: { defaults: { models: { "anthropic/claude-haiku-4-5": {} } } } }
```

---

## 7. Session-End Logging Drift

**What happened:** Agent was logging sessions to WORKLOG.md freeform. Format varied every session — sometimes detailed, sometimes vague, sometimes missing entirely.

**Fix:** `session-end.sh` script that appends a fixed template to WORKLOG.md. Agent fills in the fields but can't invent a new format.

**Template:**
```
## YYYY-MM-DD (Day)
**Completed:** [bullets]
**Files Changed:** [key files]
**Decisions:** [behavior-changing decisions]
**Lessons:** [mistakes, corrections]
**Tasks Created:** [count + breakdown]
**Open Blockers:** [waiting on human or external]
```
