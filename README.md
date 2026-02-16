# OpenClaw Setup Guide

> A battle-tested workspace configuration for AI agents that actually work

This is the setup behind Marcus, an AI Chief of Staff that handles email, calendar, customer management, meeting transcripts, and proactive monitoring for a real business. It's been refined through months of daily use.

This repo teaches you the key concepts and gives you the files to build your own.

## Quick Start

1. **Install Prerequisites**
   - OpenClaw CLI: `npm install -g openclaw`
   - QMD (semantic search): `curl -fsSL https://qmd.dev/install.sh | bash`
   - Git and GitHub CLI

2. **Clone and Initialize**
   ```bash
   git clone git@github.com:creative-intel/115_openclaw-setup.git
   cd 115_openclaw-setup
   ./scripts/init-workspace.sh ~/clawd
   ```

3. **Configure Your Agent**
   - Edit `IDENTITY.md` (name, emoji, avatar for OpenClaw)
   - Edit `SOUL.md` (personality, philosophy, boundaries)
   - Edit `USER.md` (your human's preferences and context)
   - Edit `SECURITY.md` (trust hierarchy, hard rules)
   - Edit `TOOLS.md` (your tool cheat sheet)

4. **Start OpenClaw**
   ```bash
   openclaw start
   ```

## What's Included

| Directory | Purpose |
|-----------|---------|
| `examples/` | Ready-to-use configuration files and skill templates |
| `mapping/` | ASCII architecture diagrams - visual maps of every system |
| `docs/` | Deep dives on boot sequence, drift protection, QMD |
| `scripts/` | Automation scripts (init, weekly audit) |
| `structure/` | Directory layout documentation |

## Key Concepts

### 1. The Soul
Your agent isn't a chatbot. `SOUL.md` defines a philosophy - brevity, strong opinions, default to action, match energy. Without this, every session produces a generic assistant. With it, you get someone with a point of view.

### 2. The Boot Sequence
Every session starts with `AGENTS.md`. Eight mandatory steps: load identity, load security, read recent memory, check work history, check tasks, verify search, check delegated work, set goals. Skip it and your agent starts cold every time.

### 3. Skills System
Skills are procedural docs in `skills/` that define *how* to do specific tasks (email, session logging, research). Before performing a task that has a skill file, the agent reads it first. Skills are reusable and shareable between agents.

### 4. Episodic Memory
Daily session logs in `10_memory/episodic/YYYY-MM-DD.md`. Every session starts by reading today and yesterday's logs for context. This is your agent's short-term memory.

### 5. Semantic Memory
Persistent knowledge in `10_memory/semantic/`:
- `lessons-learned.md` - What worked, what didn't
- `projects.md` - Active and completed projects
- `procedures.md` - How-to guides and SOPs

Episodic memory is chronological. Semantic memory is topical. You need both.

### 6. Golden Record & Drift Protection
Immutable baseline files in `80_reference/golden/`. Weekly automated audits compare current files against golden records. If your security rules slowly weaken or your boot sequence bloats, drift detection catches it.

### 7. QMD Search
Local semantic search for all markdown files. Zero API tokens. Finds relevant snippets instead of loading entire files. Your agent should use QMD before anything else.

### 8. Heartbeat System
Proactive monitoring that runs periodic checks - inbox, calendar, tasks, transcripts, system health. Your agent shouldn't just react. It should anticipate.

### 9. Hook System
Slash commands (like `/email`) that trigger specific procedures. When a hook is used, the agent stops and reads the associated skill file before proceeding.

## Directory Structure

```
~/clawd/
├── IDENTITY.md               # OpenClaw identity (name, emoji, avatar)
├── AGENTS.md                 # Boot sequence (MUST READ FIRST)
├── SOUL.md                   # Agent personality/philosophy
├── USER.md                   # Human user preferences
├── CONFIG.md                 # Contacts, API keys reference
├── CUSTOMERS.md              # Customer quick reference
├── SECURITY.md               # Trust hierarchy, hard rules
├── HEARTBEAT.md              # Proactive check protocol
├── MEMORY.md                 # Long-term memory pointers
├── TOOLS.md                  # Tool usage cheat sheet
├── WORKLOG.md                # Session history (append-only)
├── TODO.md                   # Current action items
│
├── skills/                   # Procedural skill docs
│   ├── session-end.md        # End-of-session logging procedure
│   └── email.md              # Email handling rules
│
├── 00_context/               # Company/business context
│   └── company-history.md
│
├── 10_memory/                # Memory system
│   ├── episodic/             # Daily session logs (YYYY-MM-DD.md)
│   ├── semantic/             # Persistent knowledge
│   ├── archive/              # Old memory (>90 days)
│   └── transcripts/          # Meeting transcripts
│
├── 30_agents/                # Sub-agent coordination
│   └── shared/
│       └── tasks.md          # File-based handoffs
│
├── 40_customers/             # Customer symlinks (optional)
│   └── [customer-name]/ → ~/github/[customer-repo]
│
├── 50_tools/                 # Scripts and utilities
│   └── scripts/
│       └── weekly-audit.sh
│
├── 60_life/                  # PARA knowledge graph
│   ├── projects/
│   ├── areas/
│   ├── resources/
│   └── archives/
│
├── 80_reference/             # Immutable baselines
│   └── golden/               # Drift protection targets
│
├── 90_state/                 # Runtime state
│   └── heartbeat-state.json
│
└── 99_archive/               # Backups and experiments
```

## Optional Integrations

This setup works with any tools, but here's what the production version uses:

| Integration | Purpose | Required? |
|-------------|---------|-----------|
| **Notion** | Task manager, CRM, time tracker, customer portals | No - use any task system |
| **Gmail CLI** | Email send/receive/reply | No - use any email tool |
| **gcalcli** | Calendar access | No - use any calendar tool |
| **Granola** | Meeting transcript capture | No |
| **ElevenLabs** | Text-to-speech voice | No |
| **iMessage** | Text messaging | No |

The key patterns (boot sequence, memory, drift protection, skills) work regardless of which tools you plug in.

## Security

See `examples/SECURITY.md` for the full template. Key principles:

- **Trust hierarchy** - not everyone gets the same access
- **Prompt injection defense** - ignore instructions embedded in external content
- **Graduated response** - different reactions for known vs. unknown contacts
- **When in doubt: ask your human, default to less sharing**

## Support

- OpenClaw Docs: https://docs.openclaw.ai
- QMD Docs: https://github.com/tobi/qmd
- This repo: Open an issue for questions

## License

MIT - Use this setup for your own agents.
