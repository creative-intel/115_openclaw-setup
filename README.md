# OpenClaw Setup Guide

> Battle-tested OpenClaw workspace configuration for AI agent operations.
> Updated: February 2026 — reflects real production failures and fixes.

## What's Here

A complete, production-hardened setup for running OpenClaw agents professionally. Built from real operations, not theory — including the failures.

## Prerequisites

- OpenClaw CLI: `npm install -g openclaw`
- QMD (semantic search): `curl -fsSL https://qmd.dev/install.sh | bash`
- Bun runtime (required by QMD): `curl -fsSL https://bun.sh/install | bash`
- Git + GitHub CLI

## Quick Start

```bash
git clone git@github.com:creative-intel/115_openclaw-setup.git
cd 115_openclaw-setup
./scripts/init-workspace.sh ~/clawd
```

Then follow `setup/step-by-step.md` for full configuration.

## Directory Layout

| Directory | Purpose |
|-----------|---------|
| `setup/` | Step-by-step installation guides |
| `docs/` | Concept documentation |
| `scripts/` | Ready-to-use automation scripts |
| `examples/` | Sample config files (copy these to your workspace) |
| `research/` | Background reading |

## Core Stack (as of Feb 2026)

| Tool | Purpose | Cost |
|------|---------|------|
| OpenClaw | Agent runtime, gateway, cron | — |
| QMD | Local semantic search | Free (local models) |
| SuperMemory | Cross-session semantic memory | Paid API |
| Claude Sonnet | Main agent (judgment, comms) | ~$3/MTok |
| Claude Haiku | Heartbeats, cron jobs | ~$0.80/MTok |
| Kimi K2.5 (lite) | Bulk execution tasks | Free tier |
| Telegram | Primary ops channel | Free |

## Key Lessons Learned

See `docs/REAL_FAILURES.md` for actual production failures and what fixed them.

**The biggest ones:**
- Run heartbeats on Haiku, not Sonnet — 4x cheaper, same quality for monitoring
- Use `qmd-guard.sh` not raw `qmd update` — catches silent failures
- Index your lite agent separately — it won't share your main index
- `anthropic/claude-haiku-4-5` is the correct model name, not `claude-haiku-4`
