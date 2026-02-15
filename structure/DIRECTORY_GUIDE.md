# Directory Structure Deep Dive

This document explains each directory's purpose, what goes where, and why.

## Root Files (The Essentials)

These files are read at the start of every session. Keep them concise.

### AGENTS.md — The Boot Sequence
**MUST READ FIRST.** Contains the mandatory boot sequence that every session follows. Think of it as the agent's startup routine.

**What it does:**
1. Read SOUL.md + USER.md (identity)
2. Read SECURITY.md (rules)
3. Read recent episodic memory
4. Check WORKLOG.md for continuity
5. Check TODO.md for actions
6. Verify QMD is working
7. Check shared tasks
8. Set session goals

**Why:** Ensures every session starts with proper context and doesn't drift.

### SOUL.md — Agent Identity
Who you are. Your personality, voice, preferences, boundaries.

**Include:**
- Name and role
- Communication style
- How you make decisions
- What you value
- What you won't do

**Why:** Without this, every session starts from zero. This persists "you" across sessions.

### USER.md — Human Preferences
Who your human is. How they work, what they like, what they hate.

**Include:**
- Name, contact info, timezone
- Work style (early bird, night owl)
- Communication preferences
- Family details (if relevant)
- Pet peeves
- Background and interests

**Why:** Personalization. You're not a generic assistant, you're THEIR assistant.

### CONFIG.md — Operational Reference
Contacts, credentials reference, tool locations.

**Include:**
- Team contact list
- Customer list (high-level)
- API credential locations
- Tool paths and configs
- Notion database IDs

**Security:** Reference WHERE credentials are, don't store them here.

### SECURITY.md — Rules of Engagement
What you can and cannot share.

**Critical Rules:**
- Never share customer details with others
- Never share calendar events
- Never share financial data
- Never share personal details
- Never mention being AI in external comms
- When in doubt, ask

**Why:** Prevents information leaks and maintains professional boundaries.

### HEARTBEAT.md — Proactive Monitoring
Scheduled checks the agent runs automatically.

**Includes:**
- Inbox monitoring
- Task manager checks
- Calendar scans
- System health checks

**Why:** Agents shouldn't just react. They should anticipate and alert.

### WORKLOG.md — Session History
What you've done. Append-only.

**Format:**
```markdown
## 2026-02-15 14:30 - Deployed Mission Control
- Migrated from crshdn to abhi1693 version
- Configured agents and boards
- Applied CI branding
```

**Why:** Continuity. You can look back and see what happened.

### TODO.md — Action Items
What needs to be done. Living document.

**Why:** Prevents things from falling through cracks.

---

## Numbered Directories (00-99)

Numbering ensures consistent ordering and makes the structure scannable.

### 00_context/ — Company Context
High-level business context that rarely changes.

**Contents:**
- Company history and evolution
- Mission and values
- Service offerings
- Pricing models
- Team structure

**Why:** New sessions need business context, not just task context.

### 10_memory/ — The Memory System

#### episodic/ — Daily Session Logs
One file per day: `YYYY-MM-DD.md`

**What to log:**
- Session goals (set at start)
- What was accomplished
- Decisions made
- Problems encountered
- Context for tomorrow

**Why:** This is your short-term memory. Yesterday's context is crucial.

#### semantic/ — Persistent Knowledge
Long-term memory that persists across sessions.

**Files:**
- `lessons-learned.md` — What worked, what didn't, why
- `projects.md` — Active and completed projects with status
- `procedures.md` — How-to guides and SOPs

**Why:** Episodic memory is chronological. Semantic memory is topical. You need both.

#### archive/ — Old Memory
Episodic logs older than 90 days. Move them here to keep `episodic/` fast.

#### transcripts/ — Meeting Transcripts
Raw meeting transcripts from tools like Granola. Processed into episodic logs.

### 30_agents/ — Sub-Agent Coordination

#### shared/tasks.md
File-based handoff system for sub-agents.

**Why:** Sub-agents (like Morgan for accounting) check this file for work. No database needed.

### 40_customers/ — Customer Symlinks

Symlinks to customer repositories:
```
40_customers/atlas-headrest → ~/github/40_atlas-headrest
40_customers/ars → ~/github/40_ars
```

**Why:** Your workspace references customers, but customer data lives in dedicated repos.

### 50_tools/ — Scripts and Utilities

#### scripts/
Automation scripts:
- `weekly-audit.sh` — Drift detection
- `qmd-update.sh` — Re-index search
- `backup.sh` — Archive old memory

**Why:** Automate the boring stuff. Scripts run on schedule or on demand.

### 60_life/ — PARA Knowledge Graph

Knowledge management using the PARA method:

#### projects/
Active projects with deadlines. Everything here should be completable.

#### areas/
Ongoing responsibilities without deadlines. (Health, finances, relationships)

#### resources/
Reference material. Things you might need later.

#### archives/
Completed projects, old resources. Searchable but not active.

**Why:** PARA (Projects, Areas, Resources, Archives) is a battle-tested knowledge management system. It scales.

### 80_reference/ — Immutable Baselines

#### golden/
Files that should rarely change. The "gold standard."

**Files:**
- `AGENTS.md` — Boot sequence
- `CONFIG.md` — Contacts
- `SECURITY.md` — Rules
- `TOOLS.md` — Tool guides
- `HEARTBEAT.md` — Monitoring protocol

**Drift Protection:** Weekly audits compare current files against golden. Changes are flagged.

**Why:** These files define how the agent operates. They shouldn't drift without intentional changes.

### 90_state/ — Runtime State

#### heartbeat-state.json
Tracks which proactive checks have run.

**Why:** Prevents duplicate checks and enables rotation (check #1 today, #2 tomorrow).

### 99_archive/ — Backups and Experiments

Things that didn't work, old versions, experiments.

**Why:** Keep the main workspace clean. Archive rather than delete.

---

## Why This Structure Works

1. **Boot sequence is fast** — Root files are small and focused
2. **Memory is layered** — Episodic (short-term) + Semantic (long-term)
3. **Search is local** — QMD indexes everything; no API calls needed
4. **Drift is detected** — Golden records catch unintended changes
5. **Security is enforced** — Credentials separate from config
6. **Scale is possible** — PARA handles growth; numbered dirs stay organized

## Common Mistakes

### ❌ Putting too much in root files
Keep AGENTS.md, SOUL.md, USER.md under 200 lines. Link to deeper docs.

### ❌ Not logging to episodic memory
Every session must log. Without this, context is lost.

### ❌ Forgetting semantic memory
Don't just log what happened (episodic). Capture what you learned (semantic).

### ❌ Skipping the boot sequence
Reading AGENTS.md first isn't optional. It ensures proper initialization.

### ❌ Putting credentials in git
Use `~/.openclaw/openclaw.json` for API keys. Never commit credentials.
