# OpenClaw Setup Guide

> Production-ready OpenClaw workspace configuration for AI agent operations

This repository contains a complete, battle-tested setup for running OpenClaw agents in a professional environment. It includes directory structures, boot sequences, memory management, drift protection, and automation scripts.

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
   - Copy `examples/SOUL.md` to your workspace root
   - Edit to match your agent's personality and role
   - Set up `USER.md` with your human's preferences

4. **Start OpenClaw**
   ```bash
   openclaw start
   ```

## What's Included

| Directory | Purpose |
|-----------|---------|
| `setup/` | Step-by-step installation guides |
| `structure/` | Directory layout documentation |
| `prompts/` | Ready-to-use setup prompts |
| `scripts/` | Automation and utility scripts |
| `docs/` | Detailed concept documentation |
| `examples/` | Sample configuration files |
| `research/` | Academic/practical research backing our choices |

## Core Concepts

### 1. Episodic Memory
Daily session logs in `10_memory/episodic/YYYY-MM-DD.md`. Every session starts by reading today and yesterday's logs for context.

### 2. Semantic Memory
Persistent knowledge in `10_memory/semantic/`:
- `lessons-learned.md` — What worked, what didn't
- `projects.md` — Active and completed projects
- `procedures.md` — How-to guides and SOPs

### 3. Golden Record
Immutable baseline files in `80_reference/golden/`:
- `AGENTS.md` — Boot sequence and operating manual
- `CONFIG.md` — Contacts and credentials reference
- `SECURITY.md` — Rules of engagement
- `TOOLS.md` — Tool usage guides
- `HEARTBEAT.md` — Proactive monitoring protocol

### 4. Drift Protection
Weekly automated audits compare current files against golden records. Changes are flagged for review.

### 5. QMD Search
Local semantic search for all markdown files. Reduces API token usage by finding relevant snippets instead of loading entire files.

## Directory Structure

```
~/clawd/
├── AGENTS.md                 # Boot sequence (MUST READ FIRST)
├── SOUL.md                   # Agent identity/personality
├── USER.md                   # Human user preferences
├── CONFIG.md                 # Contacts, API keys reference
├── SECURITY.md               # Security rules
├── HEARTBEAT.md              # Proactive check protocol
├── MEMORY.md                 # Long-term memory pointers
├── TOOLS.md                  # Tool usage guides
├── WORKLOG.md                # Session history
├── TODO.md                   # Current action items
│
├── 00_context/               # Company/customer context
│   └── company-history.md
│
├── 10_memory/                # Memory system
│   ├── episodic/             # Daily session logs
│   ├── semantic/             # Persistent knowledge
│   ├── archive/              # Old memory
│   └── transcripts/          # Meeting transcripts
│
├── 30_agents/                # Sub-agent coordination
│   └── shared/
│       └── tasks.md          # File-based handoffs
│
├── 40_customers/             # Customer symlinks
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

## Research & Rationale

See `research/` directory for:
- Why episodic memory matters (cognitive science)
- PARA method for knowledge management
- Drift detection in AI systems
- Token optimization strategies

## Security Rules

**CRITICAL: Never share:**
- Customer names or details
- Calendar events with others
- Financial data
- Personal details
- API keys or credentials

When in doubt, share less. Ask your human if uncertain.

## Support

- OpenClaw Docs: https://docs.openclaw.ai
- QMD Docs: https://github.com/tobi/qmd
- This repo: Open an issue for questions

## License

MIT — Use this setup for your own agents and customers.
