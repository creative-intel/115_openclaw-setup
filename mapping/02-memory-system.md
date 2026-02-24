<!-- ⚠️ SYNC REMINDER: When editing this file, update the Notion page too → https://www.notion.so/creative-intelligence-ai/Marcus-Architecture-Maps-307d48b650c081828bb4f36fbfd38908 -->

# Memory System Architecture — Three-Tier Flow

```
╔═══════════════════════════════════════════════════════════════════════════════════════╗
║                     THREE-TIER MEMORY SYSTEM                                         ║
║                     ═════════════════════════                                         ║
║                                                                                      ║
║   How information enters, moves through, and is retrieved from your agent's memory   ║
║                                                                                      ║
║                          ┌─────────────────────┐                                     ║
║                          │    INPUT SOURCES     │                                     ║
║                          └──────────┬──────────┘                                     ║
║                                     │                                                ║
║          ┌──────────────────────────┼──────────────────────────┐                     ║
║          │                          │                          │                      ║
║          ▼                          ▼                          ▼                      ║
║  ┌───────────────┐      ┌───────────────────┐      ┌──────────────────┐              ║
║  │ Conversations │      │ External Events    │      │ Automated Feeds  │              ║
║  │ with Human    │      │                    │      │                  │              ║
║  │               │      │ • Emails received  │      │ • Meeting        │              ║
║  │ • Chat msgs   │      │ • Calendar events  │      │   transcripts    │              ║
║  │ • Directives  │      │ • Voice calls      │      │ • Task updates   │              ║
║  │ • Corrections │      │ • GitHub activity   │      │ • CRM changes    │              ║
║  │ • "remember"  │      │                    │      │ • Heartbeat data │              ║
║  └───────┬───────┘      └─────────┬─────────┘      └────────┬─────────┘              ║
║          │                        │                          │                        ║
║          └────────────────────────┼──────────────────────────┘                        ║
║                                   │                                                   ║
║                                   ▼                                                   ║
║  ╔════════════════════════════════════════════════════════════════════════════════╗    ║
║  ║                        TIER 1: EPISODIC MEMORY                                ║    ║
║  ║                        "What happened today"                                  ║    ║
║  ║                                                                               ║    ║
║  ║   Location: 10_memory/episodic/YYYY-MM-DD.md                                 ║    ║
║  ║                                                                               ║    ║
║  ║   ┌────────────────────────────────────────────────────────────┐              ║    ║
║  ║   │ 10_memory/episodic/                                        │              ║    ║
║  ║   │  ├── 2026-02-10.md  ← "Sent invoice, fixed QMD bug"      │              ║    ║
║  ║   │  ├── 2026-02-11.md  ← "Workspace restructure research"   │              ║    ║
║  ║   │  └── 2026-02-12.md  ← TODAY (active, appending)          │              ║    ║
║  ║   └────────────────────────────────────────────────────────────┘              ║    ║
║  ║                                                                               ║    ║
║  ║   Written by:  Every session (boot step 8, session-end skill)                ║    ║
║  ║   Read by:     Boot sequence (today + yesterday), /catchup command           ║    ║
║  ║   Lifespan:    Permanent archive, optionally grouped by month                ║    ║
║  ║   Format:      Chronological log entries with timestamps                     ║    ║
║  ╚═══════════════════════════════╤════════════════════════════════════════════════╝    ║
║                                  │                                                    ║
║                    ┌─────────────┤ Extraction (patterns, lessons, decisions)           ║
║                    │             │                                                     ║
║                    ▼             ▼                                                     ║
║  ╔═════════════════════════════════════════════════════════════════════════════════╗   ║
║  ║                        TIER 2: SEMANTIC MEMORY                                 ║   ║
║  ║                        "What I know permanently"                               ║   ║
║  ║                                                                                ║   ║
║  ║   Location: 10_memory/semantic/                                                ║   ║
║  ║                                                                                ║   ║
║  ║   ┌───────────────────┐  ┌───────────────────┐  ┌────────────────────┐        ║   ║
║  ║   │ directives.md     │  │ lessons-learned.md │  │ projects.md        │        ║   ║
║  ║   │                   │  │                    │  │                    │        ║   ║
║  ║   │ ALL CAPS rules    │  │ "nope" corrections │  │ Active projects    │        ║   ║
║  ║   │ from your human   │  │ logged with date   │  │ and their current  │        ║   ║
║  ║   │ that NEVER expire │  │ and context        │  │ status             │        ║   ║
║  ║   │                   │  │                    │  │                    │        ║   ║
║  ║   │ e.g. "NEVER POST  │  │ e.g. "markdown in │  │ e.g. "Project X:   │        ║   ║
║  ║   │ WITHOUT APPROVAL" │  │ iMessage breaks"   │  │ testing phase"     │        ║   ║
║  ║   └───────────────────┘  └───────────────────┘  └────────────────────┘        ║   ║
║  ║                                                                                ║   ║
║  ║   ┌───────────────────┐                                                        ║   ║
║  ║   │ procedures.md     │                                                        ║   ║
║  ║   │                   │   Written by:  Extraction from episodic + user cmds    ║   ║
║  ║   │ How-to knowledge  │   Read by:     Boot (via MEMORY.md pointers), /deep    ║   ║
║  ║   │ that transcends   │   Lifespan:    Permanent, updated as knowledge grows   ║   ║
║  ║   │ any single day    │   Format:      Categorized knowledge entries            ║   ║
║  ║   └───────────────────┘                                                        ║   ║
║  ╚═════════════════════════════════════════════════════════════════════════════════╝   ║
║                                  │                                                    ║
║                                  ▼                                                    ║
║  ╔═════════════════════════════════════════════════════════════════════════════════╗   ║
║  ║                        TIER 3: STANDUPS / WORKLOG                              ║   ║
║  ║                        "Session-to-session continuity"                         ║   ║
║  ║                                                                                ║   ║
║  ║   ┌─────────────────────────┐    ┌─────────────────────────────┐              ║   ║
║  ║   │ WORKLOG.md (root)       │    │ TODO.md (root)               │              ║   ║
║  ║   │                         │    │                              │              ║   ║
║  ║   │ ### 2026-02-12 — Audit  │    │ ## Active                   │              ║   ║
║  ║   │ Summary: ran drift...   │    │ - [ ] Follow up on invoice  │              ║   ║
║  ║   │ Files: AGENTS.md...     │    │ - [ ] QMD re-index          │              ║   ║
║  ║   │ Next: phase 2...        │    │                              │              ║   ║
║  ║   │                         │    │ ## Waiting                   │              ║   ║
║  ║   │ ### 2026-02-11 — Setup  │    │ - [ ] Blocked on approval   │              ║   ║
║  ║   │ ...                     │    │                              │              ║   ║
║  ║   └─────────────────────────┘    └─────────────────────────────┘              ║   ║
║  ║                                                                                ║   ║
║  ║   Written by:  session-end skill (every session close)                        ║   ║
║  ║   Read by:     Boot step 4-5, /catchup, "what did I miss"                    ║   ║
║  ║   Lifespan:    Rolling (last N entries most relevant)                         ║   ║
║  ╚═════════════════════════════════════════════════════════════════════════════════╝   ║
║                                                                                       ║
║  ══════════════════════════════════════════════════════════════════════════════════    ║
║   RETRIEVAL LAYER                                                                     ║
║  ══════════════════════════════════════════════════════════════════════════════════    ║
║                                                                                       ║
║   ┌─────────────────────────────────────────────────────────────────────────────┐     ║
║   │                          QMD (Quick Markdown Search)                        │     ║
║   │                                                                             │     ║
║   │   Indexes ALL markdown files across the workspace                           │     ║
║   │                                                                             │     ║
║   │   ┌─────────────┐   ┌──────────────┐   ┌────────────────────┐             │     ║
║   │   │ qmd search  │   │ qmd vsearch  │   │ qmd query          │             │     ║
║   │   │ (BM25 fast) │   │ (vector/     │   │ (hybrid + rerank)  │             │     ║
║   │   │             │   │  semantic)   │   │                    │             │     ║
║   │   │ Best for:   │   │ Best for:    │   │ Best for:          │             │     ║
║   │   │ exact terms │   │ conceptual   │   │ complex questions  │             │     ║
║   │   │ filenames   │   │ similarity   │   │ highest accuracy   │             │     ║
║   │   └─────────────┘   └──────────────┘   └────────────────────┘             │     ║
║   │                                                                             │     ║
║   │   Rule: QMD FIRST, always. memory_search is FORBIDDEN when QMD works.      │     ║
║   └─────────────────────────────────────────────────────────────────────────────┘     ║
║                                                                                       ║
║   ┌─────────────────────────────────────────────────────────────────────────────┐     ║
║   │                          MEMORY.md (Pointer File)                           │     ║
║   │                                                                             │     ║
║   │   Not a memory store itself — just pointers:                                │     ║
║   │   "For lessons → 10_memory/semantic/lessons-learned.md"                     │     ║
║   │   "For directives → 10_memory/semantic/directives.md"                       │     ║
║   │   "For daily logs → 10_memory/episodic/"                                    │     ║
║   └─────────────────────────────────────────────────────────────────────────────┘     ║
║                                                                                       ║
║   ┌─────────────────────────────────────────────────────────────────────────────┐     ║
║   │                          60_life/ (Knowledge Graph)                         │     ║
║   │                                                                             │     ║
║   │   PARA structure for entities:                                              │     ║
║   │   areas/people/    — Known contacts with context                            │     ║
║   │   areas/companies/ — Company profiles and relationships                     │     ║
║   │   resources/       — Reference materials                                    │     ║
║   │   archives/        — Completed/inactive entities                            │     ║
║   └─────────────────────────────────────────────────────────────────────────────┘     ║
║                                                                                       ║
╚═══════════════════════════════════════════════════════════════════════════════════════╝
```

## Data Flow Summary

1. **Input** → All new info lands in **Episodic** (today's daily log)
2. **Extract** → Patterns/lessons/directives promoted to **Semantic** (permanent)
3. **Summarize** → Session work logged to **WORKLOG + TODO** (continuity)
4. **Retrieve** → QMD searches across all tiers; boot sequence loads recent context
5. **Archive** → Old episodic logs grouped by month, one-offs go to `10_memory/archive/`

---

## ⚙️ Memory System Changes — 2026-02-23

### SuperMemory — RETIRED
SuperMemory (api.supermemory.ai) has been retired. It was redundant — QMD already indexes the full workspace including CUSTOMERS.md, 60_life/, and all semantic memory files. SuperMemory had 12 documents added Feb 2026 but was never reliably queried.

- References removed from `AGENTS.md` and `80_reference/golden/agents.md`
- `SUPERMEMORY_API_KEY` still in env but service no longer used
- **Single search tool going forward: QMD only**

### memory_search — BLOCKED
`memory_search` tool is now blocked via `tools.deny: ["memory_search"]` in `~/.openclaw/openclaw.json`. Marcus can no longer call it. Forces QMD usage.

- `memory_get` still available for reading specific files by path
- `memorySearch.enabled` left as `true` — OpenClaw's internal session memory pipeline untouched
