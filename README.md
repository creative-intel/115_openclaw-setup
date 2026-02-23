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

Then follow [`docs/SETUP_GUIDE.md`](docs/SETUP_GUIDE.md) for full configuration.

## Directory Layout

| Directory | Purpose |
|-----------|---------|
| `docs/` | Concept documentation |
| `scripts/` | Ready-to-use automation scripts |
| `examples/` | Sample config files (copy these to your workspace) |

## Documentation Index

### Getting Started
| Doc | Purpose |
|-----|---------|
| [`SETUP_GUIDE.md`](docs/SETUP_GUIDE.md) | **Start here** — Complete from-zero setup checklist |

### Core Concepts
| Doc | Purpose |
|-----|---------|
| [`BOOT_SEQUENCE.md`](docs/BOOT_SEQUENCE.md) | AGENTS.md brevity principle — why shorter is better |
| [`SKILLS.md`](docs/SKILLS.md) | Three skill categories and when to use each |
| [`SLASH_COMMANDS.md`](docs/SLASH_COMMANDS.md) | Building `/health` and other slash commands |

### Configuration
| Doc | Purpose |
|-----|---------|
| [`MESSAGING.md`](docs/MESSAGING.md) | iMessage + Telegram setup and routing |
| [`QMD_SETUP.md`](docs/QMD_SETUP.md) | Semantic search configuration and guard scripts |
| [`MULTI_AGENT.md`](docs/MULTI_AGENT.md) | Lite agent setup and index management |

### Operations
| Doc | Purpose |
|-----|---------|
| [`AUTOMATION.md`](docs/AUTOMATION.md) | launchd vs cron vs heartbeat decision guide |
| [`HEARTBEAT.md`](examples/HEARTBEAT.md) | Example proactive monitoring protocol |
| [`COST_MANAGEMENT.md`](docs/COST_MANAGEMENT.md) | Model routing and Haiku configuration |

### Production Hardening
| Doc | Purpose |
|-----|---------|
| [`REAL_FAILURES.md`](docs/REAL_FAILURES.md) | 7 actual production failures + fixes |
| [`DRIFT_PROTECTION.md`](docs/DRIFT_PROTECTION.md) | Preventing configuration drift |

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

See [`docs/REAL_FAILURES.md`](docs/REAL_FAILURES.md) for actual production failures and what fixed them.

**The biggest ones:**
- Run heartbeats on Haiku, not Sonnet — 4x cheaper, same quality for monitoring
- Use `qmd-guard.sh` not raw `qmd update` — catches silent failures
- Index your lite agent separately — it won't share your main index
- `anthropic/claude-haiku-4-5` is the correct model name, not `claude-haiku-4`
