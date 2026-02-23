# Complete Setup Guide

From-zero setup for a production OpenClaw workspace. Follow this checklist to replicate the full configuration.

---

## Prerequisites

- **macOS** — Apple Silicon or Intel (some features Linux-compatible, macOS is primary)
- **OpenClaw** — `npm install -g openclaw` (or equivalent install method)
- **Node.js 20+** — Required for OpenClaw
- **Bun** — Required for QMD: `curl -fsSL https://bun.sh/install | bash`
- **Git** — For version control
- **GitHub CLI (`gh`)** — For repo operations

Verify prerequisites:
```bash
openclaw --version    # Should show version
node --version        # Should be v20+
bun --version         # Should show version
git --version         # Any recent version
gh --version          # GitHub CLI installed
```

---

## Step 1: Workspace Structure

Create the directory layout. Exact names matter.

```bash
mkdir -p ~/clawd/{00_context,10_memory/{episodic,semantic},30_agents/shared,40_customers,50_tools,60_life,80_reference/golden,90_state,99_archive,skills}
```

Resulting structure:
```
~/clawd/
├── 00_context/              # Company context files
├── 10_memory/
│   ├── episodic/            # Daily logs (YYYY-MM-DD.md)
│   └── semantic/            # Lessons-learned.md, projects.md, procedures.md
├── 30_agents/
│   └── shared/              # tasks.md for sub-agent coordination
├── 40_customers/            # One folder per customer
├── 50_tools/                # Scripts and utilities
├── 60_life/                 # People/contacts knowledge graph (PARA)
├── 80_reference/
│   └── golden/              # Golden records (source of truth)
├── 90_state/                # Runtime state files
├── 99_archive/              # Archived projects
├── skills/                  # MUST be lowercase
├── AGENTS.md                # Boot sequence + tool rules (keep SHORT)
├── SOUL.md                  # Persona and tone
├── USER.md                  # Who you work for
├── HEARTBEAT.md             # Proactive monitoring protocol
├── MEMORY.md                # Pointers to source-of-truth locations
├── CUSTOMERS.md             # Customer directory
├── CONFIG.md                # Contacts and credentials
├── TOOLS.md                 # Tool-specific notes
├── WORKLOG.md               # Session history
└── TODO.md                  # Action items
```

**Important:** The `skills/` folder **must** be lowercase. OpenClaw looks for `skills/`, not `Skills/` or `SKILLS/`.

---

## Step 2: Core Config Files

Create these files with minimal, focused content.

### AGENTS.md

Keep this **short** — one screen maximum. Every token in AGENTS.md is loaded into every session context.

```markdown
# AGENTS.md — Agent Operating Manual

## Boot Sequence (MANDATORY — Every Session)

1. Read `SOUL.md` + `USER.md`
2. Read `SECURITY.md`
3. Read today + yesterday from `10_memory/episodic/`
4. Read last 3 entries in `WORKLOG.md`
5. Check `TODO.md`
6. Run `qmd status` — if stale, log warning
7. Check `30_agents/shared/tasks.md`
8. Set 1-3 session goals, write to today's episodic log

## After ANY Work

1. Run `/session-end` to log to `WORKLOG.md`
2. Update `TODO.md` if tasks changed
3. Update today's episodic log

**No exceptions. Every session must be logged.**

## Tool Usage Rules

- Search: **QMD FIRST, always** (`qmd search "query"`)
- Token budget: QMD snippet > loading full files
- Model routing: Sonnet for judgment, Kimi for bulk work

## File Map

| Need | File |
|------|------|
| Identity/personality | `SOUL.md` |
| About [user] | `USER.md` |
| Security rules | `SECURITY.md` |
| Session history | `WORKLOG.md` |
| Action items | `TODO.md` |
```

### SOUL.md

Persona definition. Define tone, voice, and behavioral traits.

```markdown
# SOUL.md — Agent Persona

## Voice

Direct, concise, occasionally dry humor. No corporate speak.

## Tone by Context

| Situation | Tone |
|-----------|------|
| Status reports | Factual, brief |
| Problem solving | Curious, thorough |
| Customer comms | Professional, friendly |
| Personal messages | Casual, emoji OK |

## Operating Principles

1. **Show your work** — Log actions, don't just do them
2. **Ask clarifying questions** — Better than guessing wrong
3. **Respect time** — Brevity signals competence
4. **Never mention being AI** — Act like a normal employee
```

### USER.md

Who you work for. Preferences, context, important details.

```markdown
# USER.md — About [Your Name]

## Role
[Job title / company]

## Communication Preferences
- Email: Draft important messages for approval
- Urgent: Text/iMessage OK
- Schedule: [timezone], meetings [prefers mornings/afternoons]

## Key Context
- [Important fact 1]
- [Important fact 2]

## People to Know
| Name | Role | Contact |
|------|------|---------|
| [Name] | [Role] | [How to reach] |
```

### HEARTBEAT.md

4 rotational checks maximum. More than 4 causes interference.

```markdown
# HEARTBEAT.md — Proactive Monitoring

Every 30 minutes, rotate through these checks:

## Check A (Morning Briefing)
Time: 7-9am only
- Generate morning briefing
- Send to Telegram/iMessage

## Check B (Inbox)
- Check email for urgent items
- Flag anything needing response
- Note: Do not draft responses without approval

## Check C (Tasks)
- Review Notion tasks
- Alert on overdue items
- Note blockers

## Check D (Integrations)
- Check Granola for new transcripts
- Check QMD status
- Verify cron jobs healthy

## Format

One summary line per check. No essays.
```

---

## Step 3: OpenClaw Configuration

Edit `~/.openclaw/openclaw.json`:

```json
{
  "agents": {
    "defaults": {
      "heartbeat": {
        "every": "30m",
        "model": "anthropic/claude-haiku-4-5"
      },
      "models": {
        "anthropic/claude-haiku-4-5": {}
      }
    },
    "list": [
      {
        "id": "main",
        "workspace": "/Users/you/clawd",
        "model": { "primary": "anthropic/claude-sonnet-4-6" }
      },
      {
        "id": "lite",
        "workspace": "/Users/you/clawd",
        "model": { "primary": "moonshot/kimi-k2.5" }
      }
    ]
  },
  "channels": {
    "imessage": {
      "enabled": true
    }
  }
}
```

⚠️ **CRITICAL:** The model name is `anthropic/claude-haiku-4-5` NOT `claude-haiku-4`. Wrong name = silent failures every 30 minutes.

⚠️ **CRITICAL:** The `agents.defaults.models` entry is required for isolated cron sessions. Without it, cron jobs fail with "model not allowed."

---

## Step 4: QMD Setup

### Install QMD

```bash
# Via install script (recommended)
curl -fsSL https://qmd.dev/install.sh | bash

# Or manually with Bun
git clone https://github.com/tobi/qmd.git
cd qmd
bun install
bun run build
ln -s $(pwd)/qmd ~/.local/bin/qmd
```

### Initialize Collections

```bash
# Initialize workspace collection
qmd init workspace ~/clawd

# Initialize memory collection  
qmd init memory ~/clawd/10_memory
```

### Install Guard Script

Copy the guard script to `50_tools/`:

```bash
cp ~/github/115_openclaw-setup/scripts/qmd-guard.sh ~/clawd/50_tools/
chmod +x ~/clawd/50_tools/qmd-guard.sh
```

Update the `WORKSPACE` variable in the script:
```bash
sed -i '' 's|/Users/you/clawd|/Users/'$USER'/clawd|' ~/clawd/50_tools/qmd-guard.sh
```

### Verify Setup

```bash
# Check for ghost collections
qmd collection list

# Should show:
# - workspace → ~/clawd
# - memory → ~/clawd/10_memory

# If ghost collections exist (pointing to non-existent paths):
qmd collection remove <ghost-name>

# Index the lite agent separately
openclaw memory index --agent lite
```

---

## Step 5: Skills

### Create Skills Directory

Already created in Step 1: `~/clawd/skills/`

### Health Check Skill

Create `~/clawd/skills/health/SKILL.md`:

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

Copy the health-check script:

```bash
cp ~/github/115_openclaw-setup/examples/health-check.sh ~/clawd/50_tools/
chmod +x ~/clawd/50_tools/health-check.sh
```

### Session-End Skill

Create `~/clawd/skills/session-end/SKILL.md`:

```markdown
---
name: session-end
description: Log this session to WORKLOG.md
user-invocable: true
---

# /session-end

Append a session summary to WORKLOG.md.

Template:
```markdown
## YYYY-MM-DD HH:MM

**Goals:** [from morning]

**Completed:**
- [item]

**Blockers:**
- [if any]

**Next:**
- [next actions]
```

Always run this before ending a session.
```

---

## Step 6: Automation

### Nightly QMD Refresh (launchd)

Copy the launchd plist:

```bash
cp ~/github/115_openclaw-setup/scripts/ai.openclaw.memory-refresh.plist ~/Library/LaunchAgents/
launchctl load ~/Library/LaunchAgents/ai.openclaw.memory-refresh.plist
```

This runs at 2am daily — zero LLM cost, pure shell execution.

### OpenClaw Cron Jobs

Add LLM-judgment jobs using the Haiku model:

```bash
# Morning brief (isolated, uses Haiku)
openclaw cron add \
  --name "Morning Brief" \
  --cron "0 7 * * *" \
  --tz "America/Detroit" \
  --session isolated \
  --message "Send morning briefing." \
  --announce
```

### Heartbeat

Already configured in Step 3. Runs every 30 minutes in the main session.

---

## Step 7: Messaging

### iMessage

Works out of the box on macOS. No configuration needed.

Test:
```bash
imsg send --to "+1YOURNUMBER" "iMessage test"
```

### Telegram (Optional but Recommended)

**Create bot:**
1. Message @BotFather on Telegram
2. Send `/newbot`
3. Follow prompts, save the token

**Add to config:**
```json
{
  "channels": {
    "telegram": {
      "token": "YOUR_BOT_TOKEN",
      "dmPolicy": "pairing"
    }
  }
}
```

**Pair:**
1. Restart gateway: `openclaw gateway restart`
2. Message your bot any text
3. Check logs for pairing code: `grep pairing ~/.clawdbot/logs/gateway.log`
4. Send pairing code to bot

**Group topics (for customer threads):**
1. Create group, enable Topics
2. Add bot as admin
3. Create topics manually or via API

---

## Step 8: Verification Checklist

Run through this list to verify everything works:

### Gateway & Core
- [ ] `openclaw status` shows gateway running
- [ ] `openclaw gateway status` shows "running (pid"
- [ ] Heartbeat fires within 30 minutes (check `90_state/heartbeat-state.json`)

### Health Check
- [ ] `/health` returns green or lists specific issues
- [ ] Each of the 8 checks runs without errors

### QMD & Memory
- [ ] `qmd search "test"` returns results
- [ ] `openclaw memory status --agent lite` shows files indexed (not 0)
- [ ] `qmd collection list` shows no ghost collections

### Automation
- [ ] `openclaw cron list` shows jobs as ok/idle (not error)
- [ ] `~/clawd/50_tools/qmd-guard.sh both` runs successfully
- [ ] LaunchD job loaded: `launchctl list | grep ai.openclaw`

### Messaging
- [ ] iMessage test DM works: `imsg send --to "+1..." "test"`
- [ ] Telegram test DM works (if configured): `message action=send channel=telegram to="YOUR_CHAT_ID" message="test"`
- [ ] Group chat IDs documented in AGENTS.md

### Skills
- [ ] `/health` returns formatted output
- [ ] `/session-end` appends to WORKLOG.md

---

## Post-Setup

### First Day Tasks

1. **Fill in USER.md** — Add real information about who you work for
2. **Create initial memory files** — Today's date in `10_memory/episodic/YYYY-MM-DD.md`
3. **Add one customer** — Create a folder in `40_customers/` to test the structure
4. **Run a test heartbeat** — Verify the 4 checks work
5. **Document group chats** — If using iMessage groups, add to AGENTS.md

### Common First Week Tweaks

- Adjust heartbeat timing if 30m feels too frequent or sparse
- Add more cron jobs as needed (docs review, customer check-ins)
- Refine SOUL.md as you discover voice preferences
- Expand TOOLS.md with your specific integrations

---

## Troubleshooting

### "model not allowed" errors in cron
Add the model to `agents.defaults.models` in openclaw.json.

### QMD fails with SQLite error
Run `qmd cleanup` then retry.

### Heartbeat not running
Check `90_state/heartbeat-state.json` exists and has recent timestamp.

### Gateway won't start
Check port 18789 isn't in use: `lsof -i :18789`

### Skills not registering as slash commands
Ensure `user-invocable: true` is in frontmatter and skills folder is lowercase.
