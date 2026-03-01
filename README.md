# OpenClaw Setup Guide

> Battle-tested OpenClaw workspace configuration for AI agent operations.
> Updated: March 2026 — Kimi K2.5 primary, Telegram-only, weekly audits.

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
| [`MESSAGING.md`](docs/MESSAGING.md) | Telegram setup (iMessage deprecated) |
| [`QMD_SETUP.md`](docs/QMD_SETUP.md) | Semantic search configuration and guard scripts |
| [`MEMORY_SYSTEMS.md`](docs/MEMORY_SYSTEMS.md) | **QMD vs OpenClaw memory — critical to understand** |
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

## Core Stack (as of March 2026)

| Tool | Purpose | Cost |
|------|---------|------|
| OpenClaw | Agent runtime, gateway, cron | — |
| QMD | Local semantic search | Free (local models) |
| Kimi K2.5 | **Primary agent** (all tasks) | Free tier |
| Claude Haiku | Fallback only | ~$0.80/MTok |
| Telegram | **Primary messaging channel** | Free |

> **Note:** iMessage was disabled Feb 2026 due to routing instability. Telegram is now the sole messaging channel.

## Key Lessons Learned

See [`docs/REAL_FAILURES.md`](docs/REAL_FAILURES.md) for actual production failures and what fixed them.

**The biggest ones:**
- **Kimi K2.5 works as primary** — switched from Sonnet, massive cost savings
- **iMessage routing is unreliable** — disabled in favor of Telegram-only
- Use `qmd-guard.sh` not raw `qmd update` — catches silent failures
- Index your lite agent separately — it won't share your main index
- `anthropic/claude-haiku-4-5` is the correct model name, not `claude-haiku-4`
- **Weekly audits catch drift** — run `/audit` skill to detect config inconsistencies
