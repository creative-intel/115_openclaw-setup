# Memory Systems

OpenClaw agents have **two separate memory systems** that serve different purposes. Understanding this is critical for proper operation.

## TL;DR

| System | Purpose | Command | Refresh |
|--------|---------|---------|---------|
| **QMD** | Search workspace files | `qmd search "query"` | Daily via launchd |
| **OpenClaw Memory** | Session recall | Automatic | `openclaw memory index` |

They don't sync. They serve different purposes.

---

## 1. QMD (Quick Markdown Search)

**What it is:** Local semantic search over your workspace markdown files.

**How it works:**
- Indexes all `.md` files in configured collections
- Creates vector embeddings for semantic search
- Stores in `~/.cache/qmd/index.sqlite`

**Collections (typical setup):**
```
workspace (qmd://workspace/)
  Pattern:  **/*.md
  Files:    1700+ (your entire clawd/ directory)

memory (qmd://memory/)
  Pattern:  **/*.md
  Files:    80+ (10_memory/ subdirectory)
```

**Commands:**
```bash
qmd search "query"           # Full-text search
qmd vsearch "query"          # Vector similarity search
qmd query "query"            # Combined with reranking
qmd status                   # Check index health
qmd update                   # Re-index (use qmd-guard.sh instead)
qmd embed                    # Create embeddings
```

**Refresh:** Daily at 2am via `memory-refresh.sh` (launchd)

**Guard script:** Always use `qmd-guard.sh both` instead of raw `qmd update` — handles retries and error logging.

### QMD Collection Setup

```bash
# Add a collection
qmd collection add ~/clawd --name workspace --mask "**/*.md"

# Add memory-specific collection
qmd collection add ~/clawd/10_memory --name memory --mask "**/*.md"

# List collections
qmd collection list

# Remove orphaned collection
qmd collection remove <name>
```

---

## 2. OpenClaw Memory (Session-Based)

**What it is:** Embeddings of session content for cross-session recall.

**How it works:**
- Indexes files in `10_memory/` directory
- Also indexes session transcripts (main agent only)
- Creates embeddings via Gemini
- Stores in `~/.openclaw/memory/<agent>.sqlite`

**Per-agent indexes:**
```
main.sqlite  — 64 files, 2298 chunks (includes sessions)
lite.sqlite  — 16 files, 41 chunks (memory only, no sessions)
```

**Note:** The `lite` agent has no session memory by design — it's for isolated execution tasks.

**Commands:**
```bash
openclaw memory status              # Check both indexes
openclaw memory index               # Refresh main agent
openclaw memory index --agent lite  # Refresh lite agent
```

**Refresh:** Daily at 2am via `memory-refresh.sh`

**Config in openclaw.json:**
```json
{
  "agents": {
    "defaults": {
      "memorySearch": {
        "enabled": true,
        "sources": ["memory", "sessions"]
      }
    }
  }
}
```

---

## 3. memory_search Tool (BLOCKED)

There's a third thing: the `memory_search` tool that some AI providers offer.

**Status:** BLOCKED via `tools.deny` in openclaw.json

```json
{
  "tools": {
    "deny": ["memory_search"]
  }
}
```

**Why blocked:** Forces the agent to use QMD first, which is faster and more reliable for workspace search.

**Note:** This is different from OpenClaw's built-in memory search (`memorySearch.enabled: true`), which is still active for session recall.

---

## 4. Daily Refresh Flow

The `memory-refresh.sh` script runs at 2am via launchd:

```
┌─────────────────────────────────────────┐
│  memory-refresh.sh (2am daily)          │
├─────────────────────────────────────────┤
│  1. qmd-guard.sh both                   │
│     └─ qmd update (re-index files)      │
│     └─ qmd embed (create vectors)       │
│                                         │
│  2. openclaw memory index --agent lite  │
│     └─ Refresh Kimi index               │
└─────────────────────────────────────────┘
```

**LaunchAgent:** `~/Library/LaunchAgents/ai.openclaw.memory-refresh.plist`

**Logs:** `~/clawd/90_state/memory-refresh.log`

---

## 5. When to Use Which

| Scenario | Use |
|----------|-----|
| "Find files about X" | `qmd search "X"` |
| "What did we discuss about Y?" | OpenClaw memory (automatic) |
| "Search customer info" | `qmd search "customer name" -c workspace` |
| "Recall last session" | OpenClaw memory (automatic) |

**Rule in AGENTS.md:** "QMD FIRST, always"

This means: before loading full files, search QMD to find relevant snippets.

---

## 6. Troubleshooting

### QMD index stale
```bash
# Check status
qmd status

# Safe refresh
~/clawd/50_tools/qmd-guard.sh both
```

### OpenClaw memory dirty
```bash
# Check status
openclaw memory status

# Refresh
openclaw memory index
openclaw memory index --agent lite
```

### Collection pointing to wrong path
```bash
# List collections
qmd collection list

# Remove and re-add
qmd collection remove <name>
qmd collection add /correct/path --name <name> --mask "**/*.md"
```

---

*Updated: March 2026*
