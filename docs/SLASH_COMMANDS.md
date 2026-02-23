# Slash Commands

Slash commands in OpenClaw are skills that can be triggered by typing `/commandname` in Telegram, Discord, or other supported channels. They provide quick access to common operations without writing natural language prompts.

## How Slash Commands Work

### Registration

Skills become slash commands when they include `user-invocable: true` in their frontmatter:

```yaml
---
name: health
description: System health check
user-invocable: true
---
```

When OpenClaw starts, it scans the `skills/` directory and registers all `user-invocable` skills as native slash commands in connected channels.

### Three Types of Command Execution

| Type | Frontmatter | Execution |
|------|-------------|-----------|
| Reference | None (default) | LLM reads skill, decides when to use |
| Hook-triggered | `user-invocable: true` | LLM triggers → script executes |
| Command-dispatch | `command-dispatch: tool` | Bypasses LLM, direct tool call |

The `/health` command uses the **hook-triggered** pattern: the skill is minimal, the script does all the work.

---

## The `/health` Command Pattern

The `/health` command demonstrates the cleanest slash command architecture: a thin SKILL.md wrapper around a robust shell script.

### SKILL.md Structure

```markdown
---
name: health
description: Check system health status
user-invocable: true
---

# /health

Run the health check script and report the output exactly as returned.

```bash
bash ~/clawd/50_tools/health-check.sh
```
```

That's it. The skill doesn't process the output, transform it, or add commentary. It just runs the script and returns the result.

### Why This Pattern Works

1. **Deterministic output** — The script controls formatting, not the LLM
2. **Testable** — Run the script directly to verify behavior
3. **Version controlled** — Script changes are tracked in git
4. **Fast** — No LLM reasoning latency for simple status checks
5. **Cheap** — Zero API tokens for the status report itself

---

## What `health-check.sh` Verifies

The script performs 8 checks across the system:

### 1. Gateway Status
Checks if the OpenClaw gateway is responding on port 18789:
```bash
openclaw gateway status | grep "running (pid"
```
**Critical if:** Gateway down (agent can't receive messages)

### 2. Heartbeat Health
Reads `90_state/heartbeat-state.json` and warns if last_run >90 minutes ago:
```bash
python3 -c "import json; ... calculate minutes since last_run ..."
```
**Critical if:** No heartbeat for 90+ minutes (monitoring is silent)

### 3. Cron Job Status
Parses `openclaw cron list` output, counts jobs in ok/idle/error states:
```bash
openclaw cron list | grep -E "^[0-9a-f]{8}-"
```
**Warning if:** Any job shows errors

### 4. Memory Indexes
Checks both main and lite agent indexes via `openclaw memory status`:
```bash
openclaw memory status | grep "Indexed:"
```
**Warning if:** Index shows "dirty" flag (pending embeddings)

### 5. QMD Status
Runs `qmd status` and parses the "Updated:" field:
```bash
~/.bun/bin/qmd status | grep "Updated:"
```
**Warning if:** Last update >25 hours ago

### 6. Automation Logs
Checks the last line of guard and refresh logs:
```bash
tail -1 ~/clawd/90_state/qmd-guard.log
tail -1 ~/clawd/90_state/memory-refresh.log
```
**Critical if:** qmd-guard shows "GAVE UP" (auto-recovery failed)
**Warning if:** memory-refresh shows "FAILED"

### 7. Camofox Browser
Health check on local browser proxy:
```bash
curl -s http://localhost:9377/health | grep '"ok":true'
```
**Warning if:** Not responding (browser automation unavailable)

### 8. Granola Token
Makes live API call to verify WorkOS token:
```bash
curl -s https://api.granola.ai/v2/get-documents \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"limit":1}'
```
**Warning if:** Token invalid or API error (transcript sync will fail)

---

## Tiered Output Format

The health check uses a three-tier output system optimized for quick scanning on mobile:

### 🔴 Red — Critical Issues First

When critical issues exist, they appear first with full details:

```
🚨 2 critical issue(s)
→ openclaw gateway: not responding on :18789
→ Last heartbeat: 127m ago (expected 30m)

Gateway: DOWN · Heartbeat: 127m ago · Memory: main 64/65 · lite 12/12
```

**Critical conditions:**
- Gateway not running
- Heartbeat silent >90 minutes  
- QMD guard gave up (auto-recovery failed)

### 🟡 Yellow — Warnings Listed

When only warnings exist:

```
⚠️ 3 warning(s)
→ Memory: main index dirty (pending embeddings)
→ QMD: last update 28h ago (>25h)
→ Granola: token invalid or API error

Everything else ok.
Gateway: running · Heartbeat: 12m ago · Cron: 4/4 jobs ok
```

### 🟢 Green — One Summary Line

When all systems healthy:

```
✅ All systems healthy
Gateway: running · pid 1847
Heartbeat: Haiku · last 12m ago · 8 checks today
Cron: 4/4 jobs ok
Memory: main 64/65 · lite 12/12 · QMD 2h ago
Camofox: online · 0 sessions
Granola: token valid
```

---

## Why This Beats a Dashboard

### Phone-First Operations

Dashboards require:
- Opening a browser
- Loading a page
- Authenticating
- Parsing visual elements

The `/health` command requires:
- Typing 7 characters
- Reading ~5 lines of text

### Push vs Pull

Dashboards are pull (you must remember to check). The `/health` command is push (run it anytime from anywhere).

### Context Preservation

Dashboards exist outside your workflow. `/health` runs in your ops channel alongside all other activity, creating a searchable history of system state over time.

### Zero Infrastructure

No server to maintain, no database to scale, no SSL certificates to renew. A shell script and a skill definition.

---

## Complete SKILL.md Example

```markdown
---
name: health
description: Check system health status
user-invocable: true
---

# /health

Run the health check script and report the output exactly as returned.
Do not reformat, summarize, or add commentary. The script handles all output formatting.

```bash
bash ~/clawd/50_tools/health-check.sh
```

## Expected Output

The script returns tiered status:
- 🚨 Red: Critical issues listed first
- ⚠️ Yellow: Warnings listed, "everything else ok"  
- ✅ Green: One summary line with all key numbers

## When to Use

- Morning standup check
- Before important demos
- After system maintenance
- When something feels "off"
- Anytime from your phone
```

Copy this to `skills/health/SKILL.md` and the `health-check.sh` script to `50_tools/health-check.sh`.
