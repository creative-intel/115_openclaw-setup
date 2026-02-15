# QMD: Semantic Search for Your Workspace

QMD (Quick Markdown) is local semantic search for markdown files. It reduces API token usage by finding relevant snippets instead of loading entire files.

## Why QMD?

### The Problem
You need to find information in your workspace:
- "What was that customer's pricing model?"
- "How did I set up that integration?"
- "What did we decide about X?"

**Without QMD:**
1. Load entire files into context
2. Use thousands of API tokens
3. Still might miss the relevant section

**With QMD:**
1. Search locally, get snippets
2. Use zero API tokens
3. Find exactly what you need

### Token Savings Example

| Method | Files Loaded | Tokens Used | Time |
|--------|--------------|-------------|------|
| Load everything | 50 files × 500 lines | ~100,000 | Slow |
| QMD search | 3 snippets × 5 lines | 0 | Fast |

**Result:** 99% reduction in token usage for searches.

---

## Installation

### Option 1: Install Script (Recommended)
```bash
curl -fsSL https://qmd.dev/install.sh | bash
```

This installs to `~/.bun/bin/qmd` and requires Bun runtime.

### Option 2: Manual Install
```bash
# Install Bun first
curl -fsSL https://bun.sh/install | bash

# Clone and build QMD
git clone https://github.com/tobi/qmd.git
cd qmd
bun install
bun run build
ln -s $(pwd)/qmd ~/.local/bin/qmd
```

### Verify Installation
```bash
qmd --version
# Should output version info
```

---

## Setup

### 1. Initialize QMD
```bash
cd ~/clawd
qmd init
```

This creates:
- `~/.cache/qmd/index.sqlite` — Search index
- `~/.cache/qmd/models/` — ML models (~2GB)

### 2. Add Collections

Collections are directories QMD will index.

```bash
# Add workspace collection
qmd collection add ~/clawd --name workspace --mask "**/*.md"

# Add memory collection
qmd collection add ~/clawd/10_memory --name memory --mask "**/*.md"

# Add life collection (PARA)
qmd collection add ~/clawd/60_life --name life --mask "**/*.md"
```

### 3. Build Index
```bash
qmd update
```

This scans all collections and builds the search index.

**First run:** Takes 5-10 minutes (downloads models)
**Subsequent runs:** Takes 30-60 seconds

---

## Usage

### Basic Search
```bash
# Search all collections
qmd search "customer pricing model"

# Search specific collection
qmd search "deployment issues" -c memory

# Get 10 results instead of 5
qmd search "integration setup" -n 10
```

**Output:**
```
File: memory/2026-02-10.md:45-50
Score: 0.89
---
Deployed Atlas customer portal yesterday. 
Pricing model is $5k/month + $2k setup.
Need to document this properly.
---

File: customers/atlas.md:23-28
Score: 0.76
---
Atlas Headrest
- Pricing: $5k/month + $2k setup
- Contact: Andrew Foley
- Start date: Jan 2026
---
```

### Semantic Search (Vector)
```bash
# Find conceptually similar content
qmd vsearch "how do I handle customer complaints"

# Good for: finding related ideas, not just keyword matches
```

### Hybrid Search (Best Results)
```bash
# Combines keyword + semantic + reranking
qmd query "deployment strategy for new customers"

# Slowest but highest quality results
```

### Get Specific Document
```bash
# Get full document
qmd get "memory/2026-02-10.md"

# Get specific lines
qmd get "memory/2026-02-10.md:45-50"
```

### Update Index
```bash
# After adding new files
qmd update

# Force re-index everything
qmd update --force

# Update embeddings (if using vsearch)
qmd embed
```

---

## Integration with AGENTS.md

### Boot Sequence Check
Add to your `AGENTS.md`:

```markdown
## Boot Sequence

6. Verify QMD: `qmd --version` (if fails, log warning)
```

### Search Rule
Add to your `AGENTS.md`:

```markdown
## Tool Usage Rules

- Search: **QMD FIRST, always** (`qmd search "query"`)
- memory_search is FORBIDDEN when QMD is available
- Token budget: QMD snippet > loading full files
```

### Why This Rule?

QMD is:
- **Free** — No API tokens
- **Fast** — Local search
- **Precise** — Returns relevant snippets
- **Scalable** — Works with thousands of files

---

## Collections Best Practices

### Workspace Collection
```bash
qmd collection add ~/clawd --name workspace --mask "**/*.md"
```

**Index:** All markdown files in your workspace
**Use for:** General searches across everything

### Memory Collection
```bash
qmd collection add ~/clawd/10_memory --name memory --mask "**/*.md"
```

**Index:** Just your memory files
**Use for:** Context searches, "what did I do yesterday"

### Life Collection (PARA)
```bash
qmd collection add ~/clawd/60_life --name life --mask "**/*.md"
```

**Index:** Your PARA knowledge graph
**Use for:** Knowledge retrieval, reference material

### Customer Collection (Optional)
```bash
qmd collection add ~/clawd/40_customers --name customers --mask "**/*.md"
```

**Index:** Customer-specific files
**Use for:** Customer context searches

---

## Automation

### Auto-Update on Commit
Add to `.git/hooks/post-commit`:

```bash
#!/bin/bash
# Update QMD index after commit
qmd update > /dev/null 2>&1 &
```

### Scheduled Updates
Add to crontab:
```bash
# Update QMD every hour
0 * * * * cd ~/clawd && qmd update > /dev/null 2>&1
```

### Heartbeat Check
Add to `HEARTBEAT.md`:

```markdown
### QMD Index Status
- Check if index is stale (>24h since last update)
- If stale: run `qmd update`
```

---

## Troubleshooting

### "qmd: command not found"
```bash
# Add to ~/.zshrc or ~/.bashrc
export PATH="$HOME/.bun/bin:$PATH"
```

### "Index is stale"
```bash
# Rebuild index
qmd update

# Force full rebuild
qmd update --force
```

### "No results found"
```bash
# Check collections exist
qmd collection list

# Check files are indexed
qmd ls workspace | head -20

# Rebuild if needed
qmd update --force
```

### "Out of memory"
QMD models use ~2GB RAM. If you get OOM errors:
```bash
# Close other applications
# Or reduce concurrent searches
# Or use smaller models (not currently configurable)
```

---

## Advanced Usage

### JSON Output
```bash
qmd search "deployment" --json | jq '.[].path'
```

### CSV Export
```bash
qmd search "customer" --csv > results.csv
```

### Filter by Score
```bash
qmd search "strategy" --min-score 0.8
```

### Search with Line Numbers
```bash
qmd search "TODO" --line-numbers
```

### Multi-Get
```bash
# Get multiple files at once
qmd multi-get "memory/2026-02-*.md" -l 50
```

---

## Research: Why Local Search Matters

### Token Economics
- API tokens cost money
- Large context windows are expensive
- Most context is irrelevant

### Latency
- API round-trip: 500ms-2s
- Local search: 50-100ms

### Privacy
- Search queries stay local
- No data sent to external services
- Sensitive info stays in your control

### Cognitive Science
- Humans don't remember everything
- We remember where to find things
- Snippets are more useful than full documents

QMD implements "transactive memory" — knowing where knowledge is stored, not necessarily holding it all in working memory.

---

## Migration from memory_search

If you're currently using `memory_search`:

### Step 1: Install QMD
```bash
curl -fsSL https://qmd.dev/install.sh | bash
```

### Step 2: Initialize and Index
```bash
cd ~/clawd
qmd init
qmd collection add ~/clawd --name workspace --mask "**/*.md"
qmd update
```

### Step 3: Update AGENTS.md
```markdown
## Tool Usage Rules

- Search: **QMD FIRST, always** (`qmd search "query"`)
- memory_search is FORBIDDEN when QMD is available
```

### Step 4: Test
```bash
qmd search "test query"
```

### Step 5: Monitor Token Usage
You should see significant reduction in API token consumption.

---

## QMD vs. memory_search

| Feature | QMD | memory_search |
|---------|-----|---------------|
| Cost | Free | Uses API tokens |
| Speed | Local (~100ms) | API round-trip (~1s) |
| Privacy | 100% local | Sends to OpenAI |
| Results | Snippets with paths | Snippets with paths |
| Setup | Install + index | Built-in |
| Maintenance | Weekly updates | None |

**Recommendation:** Use QMD for everything. Use memory_search only as fallback if QMD fails.
