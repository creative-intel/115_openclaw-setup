# The Boot Sequence

Every session starts with the boot sequence defined in `AGENTS.md`. This isn't optional—it's mandatory for consistent agent behavior.

## Why a Boot Sequence Matters

Without a boot sequence:
- Every session starts cold
- Context is lost between sessions
- Agent behavior drifts over time
- Critical files are missed
- Sub-agents don't coordinate properly

With a boot sequence:
- Consistent initialization
- Context carries forward
- Behavior stays aligned with goals
- Nothing important is forgotten

## The 8-Step Boot Sequence

### Step 1: Read Identity Files
**Files:** `SOUL.md` + `USER.md`

**What you're loading:**
- Who you are (SOUL.md)
- Who your human is (USER.md)
- How you communicate
- What you value

**Why first:** Everything else depends on knowing who you're being.

### Step 2: Read Security Rules
**File:** `SECURITY.md`

**What you're loading:**
- What you can share
- What you cannot share
- Communication rules
- Privacy boundaries

**Why second:** Security must be active before any external actions.

### Step 3: Read Recent Episodic Memory
**Files:** `10_memory/episodic/YYYY-MM-DD.md`

**What to read:**
- Today's log (if exists)
- Yesterday's log
- Day before yesterday's log

**What to look for:**
- What was accomplished
- What problems occurred
- What decisions were made
- What needs follow-up

**Why third:** Recent context is the most relevant. You need to know what just happened.

### Step 4: Check Session Continuity
**File:** `WORKLOG.md`

**What to look for:**
- Last 3 entries
- Patterns in recent work
- Unfinished items

**Why fourth:** This is your work history. It shows trends and continuity.

### Step 5: Check Current Tasks
**File:** `TODO.md`

**What to look for:**
- Overdue items
- Due today items
- Blocked items

**Why fifth:** You need to know what you're supposed to be doing.

### Step 6: Verify QMD
**Command:** `qmd --version`

**What you're checking:**
- QMD is installed
- Index exists
- Search is functional

**Why sixth:** QMD is your primary search tool. If it's broken, everything slows down.

**If QMD fails:**
- Log a warning
- Fall back to memory_search (slower, uses API tokens)
- Try to re-index later

### Step 7: Check Sub-Agent Tasks
**File:** `30_agents/shared/tasks.md`

**What to look for:**
- Tasks assigned to sub-agents
- Handoffs that need your attention
- Completed work to review

**Why seventh:** You're the coordinator. Sub-agents file-based handoffs go here.

### Step 8: Set Session Goals
**File:** `10_memory/episodic/YYYY-MM-DD.md` (today's file)

**What to write:**
- 1-3 goals for this session
- Why they matter
- Success criteria

**Why eighth:** Starting with clear goals keeps the session focused.

---

## Boot Sequence Checklist

```markdown
## 2026-02-15 09:00 - Session Start

### Boot Sequence Complete
- [x] Read SOUL.md — Marcus, Chief of Staff, 🦞
- [x] Read USER.md — Cort Corwin, founder, EST timezone
- [x] Read SECURITY.md — No customer details shared, etc.
- [x] Read episodic memory — Feb 14 (deployed MC), Feb 13 (worked on...)
- [x] Read WORKLOG.md — Last 3 entries checked
- [x] Check TODO.md — 2 items due today
- [x] QMD verified — 1186 files indexed
- [x] Check shared tasks — Morgan has 1 pending item

### Session Goals
1. Complete X
2. Review Y  
3. Follow up on Z

---
```

---

## Post-Work Protocol

After ANY work, you MUST:

### 1. Append to WORKLOG.md
```markdown
## 2026-02-15 14:30 - Deployed Mission Control
- Migrated from crshdn to abhi1693 version
- Configured PostgreSQL, Redis, FastAPI backend
- Set up agents: Marcus, Teddy, Morgan
- Applied CI branding (dark theme, logo)
```

### 2. Update TODO.md
- Mark completed items
- Add new items discovered during work
- Re-prioritize if needed

### 3. Update Today's Episodic Log
- What was accomplished
- Decisions made
- Problems encountered
- Context for tomorrow

---

## Boot Sequence in Practice

### Fast Boot (Existing Session)
If you've been working recently:
1. Read today's episodic log (already exists)
2. Check TODO.md for updates
3. Verify QMD
4. Set 1-3 goals

**Time:** ~30 seconds

### Cold Boot (New Day)
If it's been a while:
1. Full 8-step sequence
2. Read 3 days of episodic memory
3. Review all shared tasks
4. Set detailed goals

**Time:** ~2-3 minutes

### Recovery Boot (After Error)
If something went wrong:
1. Full 8-step sequence
2. Check 90_state/ for error states
3. Review last WORKLOG.md entry for clues
4. Set recovery goals

**Time:** ~3-5 minutes

---

## Common Issues

### "I forgot to run the boot sequence"
Stop. Run it now. Don't proceed without it.

### "The boot sequence is taking too long"
Your files are too large. Keep root files under 200 lines. Move details to semantic memory.

### "QMD is failing"
Log it, proceed with memory_search, fix QMD later.

### "I don't have episodic memory files"
Create today's file. Set your first session goal: "Establish episodic logging habit."

### "TODO.md is overwhelming"
You're putting too much in it. Move non-urgent items to `10_memory/semantic/projects.md`.

---

## Research: Why Boot Sequences Work

This pattern comes from:
- **Cognitive science:** Humans need context to reason effectively
- **Aviation:** Pre-flight checklists prevent disasters
- **DevOps:** Health checks before service startup
- **Psychology:** Priming effects on behavior

The boot sequence is your pre-flight checklist. Don't skip it.
