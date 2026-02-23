# Directory Structure & File Purpose Map — What Lives Where and Why

```
╔═══════════════════════════════════════════════════════════════════════════════════════════════╗
║                     WORKSPACE DIRECTORY MAP                                                    ║
║                     ═══════════════════════                                                    ║
║                                                                                               ║
║   ✅ = required  |  ⚠️ = recommended  |  📎 = optional                                         ║
║                                                                                               ║
║                                                                                               ║
║  ═══════════════════════════════════════════════════════════════════════════════════════════   ║
║   ~/clawd/ DIRECTORY                                                                          ║
║  ═══════════════════════════════════════════════════════════════════════════════════════════   ║
║                                                                                               ║
║                                                                                               ║
║  ~/clawd/                                                                                     ║
║  │                                                                                            ║
║  │  ┌─────────────────────────────────────────────────────────────────────────────────────┐   ║
║  │  │  OPENCLAW CONVENTION FILES (must be at root, exact names)                           │   ║
║  │  │  Gateway auto-reads these. Renaming or moving them breaks the agent.               │   ║
║  │  └─────────────────────────────────────────────────────────────────────────────────────┘   ║
║  │                                                                                            ║
║  ├── AGENTS.md ──────────── ✅ Entry point. Boot sequence. Slash commands. User signals.       ║
║  │                          THE most important file. Gateway reads this FIRST.                 ║
║  │                                                                                            ║
║  ├── IDENTITY.md ────────── ✅ OpenClaw identity: name, creature, vibe, emoji, avatar.         ║
║  │                          Gateway reads this to set your identity in the UI.                ║
║  │                                                                                            ║
║  ├── SOUL.md ────────────── ✅ Philosophy, personality, ethics, voice, boundaries.              ║
║  │                          "Who am I?" — loaded in boot step 1.                              ║
║  │                                                                                            ║
║  ├── USER.md ────────────── ✅ About your human. Background, preferences, work style.          ║
║  │                          "Who am I helping?" — loaded in boot step 1.                      ║
║  │                                                                                            ║
║  ├── HEARTBEAT.md ───────── ✅ Proactive check protocol. 7 rotational checks.                  ║
║  │                          Runs every 30 min. Drives the heartbeat feature.                  ║
║  │                                                                                            ║
║  ├── skills/ ────────────── ✅ OpenClaw auto-discovers this. Lowercase ONLY (skills/ NOT Skills/)║
║  │   │                      Each skill = a procedure your agent can execute.                  ║
║  │   │                      Files with user-invocable: true become slash commands.             ║
║  │   │                                                                                        ║
║  │   ├── session-end.md ── ✅ /done: Log worklog, update TODO, update episodic                  ║
║  │   ├── email.md ──────── ✅ Email handling rules and procedures                               ║
║  │   ├── imessage.md ───── 📎 iMessage plain-text rules (if using iMessage)                    ║
║  │   ├── notion.md ─────── 📎 Notion API database operations (if using Notion)                 ║
║  │   │                                                                                        ║
║  │   │  EXAMPLE SLASH COMMAND SKILLS YOU COULD CREATE:                                        ║
║  │   │     status-check.md, audit-now.md, catchup.md,                                        ║
║  │   │     think-mode.md, deep-dive.md, focus-customer.md,                                   ║
║  │   │     tell.md, lessons.md                                                                ║
║  │   │                                                                                        ║
║  │   └── [tool-name]/ ──── 📎 Complex skills with multiple files                               ║
║  │       ├── SKILL.md        (frontmatter: name, description, requires bins)                  ║
║  │       ├── README.md                                                                        ║
║  │       └── *.js            (helper scripts)                                                 ║
║  │                                                                                            ║
║  │  ┌─────────────────────────────────────────────────────────────────────────────────────┐   ║
║  │  │  OUR CUSTOM ROOT FILES (not OpenClaw convention, but loaded during boot)            │   ║
║  │  └─────────────────────────────────────────────────────────────────────────────────────┘   ║
║  │                                                                                            ║
║  ├── SECURITY.md ────────── ✅ Trust hierarchy, hard rules, injection defense.                  ║
║  │                          Loaded in boot step 2. Non-negotiable constraints.                ║
║  │                                                                                            ║
║  ├── CONFIG.md ──────────── ⚠️ Contacts, phone numbers, DB IDs, credential paths.              ║
║  │                          "Where do I find things?" reference card.                         ║
║  │                                                                                            ║
║  ├── TOOLS.md ───────────── ⚠️ Tool-specific notes, gotchas, CLI commands.                     ║
║  │                          "How do I use things?" reference card.                            ║
║  │                                                                                            ║
║  ├── MEMORY.md ──────────── ⚠️ Pointers only! "For X, see 10_memory/semantic/X.md"            ║
║  │                          NOT a memory dump. Redirects to the right tier.                   ║
║  │                                                                                            ║
║  ├── CUSTOMERS.md ───────── 📎 Customer quick reference. Synced from CRM.                      ║
║  │                                                                                            ║
║  ├── WORKLOG.md ─────────── ✅ Session history. Appended after every session.                   ║
║  │                          "What did I do?" — loaded in boot step 4.                        ║
║  │                                                                                            ║
║  ├── TODO.md ────────────── ✅ Current action items. Updated every session.                     ║
║  │                          "What do I need to do?" — loaded in boot step 5.                 ║
║  │                                                                                            ║
║  │  ┌─────────────────────────────────────────────────────────────────────────────────────┐   ║
║  │  │  NUMBERED FOLDERS (our convention, OpenClaw doesn't care about these)               │   ║
║  │  │  Numbers give visual sort order. No functional meaning to OpenClaw.                 │   ║
║  │  └─────────────────────────────────────────────────────────────────────────────────────┘   ║
║  │                                                                                            ║
║  ├── 00_context/ ────────── ⚠️ Company & identity context documents                            ║
║  │   ├── company-history.md                                                                   ║
║  │   ├── tech-stack.md                                                                        ║
║  │   └── [other context docs]                                                                 ║
║  │                                                                                            ║
║  ├── 10_memory/ ─────────── ✅ THREE-TIER MEMORY SYSTEM                                        ║
║  │   ├── episodic/ ──────── ✅ Tier 1: What happened (daily logs, YYYY-MM-DD.md)               ║
║  │   │                                                                                        ║
║  │   ├── semantic/ ──────── ⚠️ Tier 2: Permanent extracted knowledge                           ║
║  │   │   ├── lessons-learned.md  (operational mistakes + fixes)                               ║
║  │   │   ├── projects.md         (active project status)                                      ║
║  │   │   ├── procedures.md       (how-to knowledge)                                           ║
║  │   │   └── directives.md       (ALL CAPS permanent rules from human)                        ║
║  │   │                                                                                        ║
║  │   ├── transcripts/ ───── 📎 Meeting transcripts (from Granola, Otter, etc.)                 ║
║  │   │                                                                                        ║
║  │   └── archive/ ───────── ⚠️ Old episodic logs (>90 days) and one-off files                  ║
║  │                                                                                            ║
║  ├── 30_agents/ ─────────── 📎 Sub-agent workspaces                                            ║
║  │   ├── [sub-agent]/ ───── Sub-agent's full workspace (own AGENTS, SOUL, skills, memory)    ║
║  │   └── shared/                                                                              ║
║  │       └── tasks.md ───── File-based task handoffs (the "task board")                       ║
║  │                                                                                            ║
║  ├── 40_customers/ ──────── 📎 Symlinks to customer repositories                               ║
║  │   └── [customer] → ~/github/[customer-repo]                                               ║
║  │                                                                                            ║
║  ├── 50_tools/ ──────────── ⚠️ Scripts, automation, projects                                   ║
║  │   ├── scripts/                                                                             ║
║  │   │   ├── weekly-audit.sh   (cron job: diff golden vs live)                                ║
║  │   │   ├── qmd-guard.sh      (QMD index update with retry/backoff)                          ║
║  │   │   ├── memory-refresh.sh (memory system maintenance)                                    ║
║  │   │   ├── session-end.sh    (session logging wrapper)                                      ║
║  │   │   └── health-check.sh   (system health verification)                                   ║
║  │   └── dashboard/            (optional web dashboard)                                       ║
║  │                                                                                            ║
║  ├── 60_life/ ───────────── 📎 PARA knowledge graph                                            ║
║  │   ├── projects/           Active projects with deadlines                                   ║
║  │   ├── areas/              Ongoing responsibilities (people, companies)                     ║
║  │   ├── resources/          Reference materials                                              ║
║  │   └── archives/           Completed/inactive items                                         ║
║  │                                                                                            ║
║  ├── 80_reference/ ──────── ⚠️ Golden record + research archive                                ║
║  │   └── golden/ ────────── Audit baseline ("source of truth" copies)                         ║
║  │       ├── AGENTS.md       (known-good version)                                             ║
║  │       ├── HEARTBEAT.md    (known-good version)                                             ║
║  │       ├── SECURITY.md     (known-good version)                                             ║
║  │       ├── TOOLS.md        (known-good version)                                             ║
║  │       └── CONFIG.md       (known-good version)                                             ║
║  │                                                                                            ║
║  ├── 90_state/ ──────────── ✅ Runtime state files (JSON/logs, not for humans)                  ║
║  │   ├── heartbeat-state.json       (rotation index, last run time)                           ║
║  │   ├── processed-transcripts.json (transcript pipeline tracking)                            ║
║  │   ├── qmd-guard.log              (QMD index update log)                                    ║
║  │   └── memory-refresh.log         (memory system refresh log)                               ║
║  │                                                                                            ║
║  └── 99_archive/ ────────── 📎 Old backups, experiments, deprecated files                      ║
║                                                                                               ║
║                                                                                               ║
║  ═══════════════════════════════════════════════════════════════════════════════════════════   ║
║   WHAT OPENCLAW CARES ABOUT vs. WHAT'S OURS                                                  ║
║  ═══════════════════════════════════════════════════════════════════════════════════════════   ║
║                                                                                               ║
║   ┌──────────────────────────────────┐    ┌──────────────────────────────────┐                ║
║   │  🔒 OPENCLAW REQUIRES             │    │  🔧 OUR CUSTOM (safe from updates)│                ║
║   │  (don't rename, don't move)      │    │  (OpenClaw ignores these)        │                ║
║   │                                  │    │                                  │                ║
║   │  • AGENTS.md (at root)           │    │  • 00_context/                   │                ║
║   │  • IDENTITY.md (at root)         │    │  • 10_memory/ (3-tier)           │                ║
║   │  • SOUL.md (at root)             │    │  • 30_agents/ (numbered)         │                ║
║   │  • USER.md (at root)             │    │  • 40_customers/                 │                ║
║   │  • HEARTBEAT.md (at root)        │    │  • 50_tools/                     │                ║
║   │  • skills/ (lowercase, at root)  │    │  • 60_life/                      │                ║
║   │  • SKILL.md (YAML frontmatter)   │    │  • 80_reference/                 │                ║
║   │  • ~/.openclaw/openclaw.json     │    │  • 90_state/                     │                ║
║   │                                  │    │  • 99_archive/                   │                ║
║   │                                  │    │  • SECURITY.md, WORKLOG.md, etc. │                ║
║   │                                  │    │  • CONFIG.md, TOOLS.md, etc.     │                ║
║   └──────────────────────────────────┘    └──────────────────────────────────┘                ║
║                                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════════════════════╝
```

## What Goes Where (Quick Reference)

| I need to store... | Put it in... |
|---------------------|-------------|
| Today's work log | `10_memory/episodic/YYYY-MM-DD.md` |
| A lesson I learned | `10_memory/semantic/lessons-learned.md` |
| A permanent rule from my human | `10_memory/semantic/directives.md` |
| A new project | `10_memory/semantic/projects.md` |
| A meeting transcript | `10_memory/transcripts/` |
| A new contact's info | `60_life/areas/people/[name].md` |
| A company profile | `60_life/areas/companies/[name].md` |
| A task for a sub-agent | `30_agents/shared/tasks.md` |
| A customer symlink | `40_customers/[name] → repo` |
| A utility script | `50_tools/scripts/` |
| A known-good file copy | `80_reference/golden/` |
| Something old/deprecated | `99_archive/` |
