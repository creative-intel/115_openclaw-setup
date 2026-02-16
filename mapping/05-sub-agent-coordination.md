# Sub-Agent Coordination — Primary ↔ Sub-Agent

```
╔═══════════════════════════════════════════════════════════════════════════════════════════╗
║                     PRIMARY ↔ SUB-AGENT COORDINATION                                      ║
║                     ════════════════════════════════                                       ║
║                                                                                           ║
║   Primary agent = Main operations (comms, research, scheduling)                           ║
║   Sub-agent = Specialized domain (accounting, content, research)                          ║
║                                                                                           ║
║                                                                                           ║
║  ┌─────────────────────────────────────────────────────────────────────────────────────┐  ║
║  │                            PRIMARY AGENT                                            │  ║
║  │                                                                                     │  ║
║  │  Workspace: ~/clawd/                                                                │  ║
║  │  Identity:  SOUL.md + USER.md                                                       │  ║
║  │  Config:    ~/.openclaw/openclaw.json                                               │  ║
║  │                                                                                     │  ║
║  │  Responsibilities:                                                                  │  ║
║  │  • Email management              • Customer comms                                   │  ║
║  │  • Calendar management           • Research                                         │  ║
║  │  • Task management               • Meeting transcript sync                         │  ║
║  │  • Heartbeat monitoring          • Session logging                                  │  ║
║  │  • QMD search                    • Sub-agent coordination                           │  ║
║  │                                                                                     │  ║
║  └────────────────────────────┬────────────────────────────────────────────────────────┘  ║
║                               │                                                           ║
║                               │  DELEGATION FLOW                                          ║
║                               │                                                           ║
║              ┌────────────────┼────────────────┐                                          ║
║              │                │                │                                          ║
║              ▼                ▼                ▼                                          ║
║   ┌──────────────┐  ┌──────────────┐  ┌───────────────┐                                  ║
║   │ Human says:  │  │ Human says:  │  │ Primary finds │                                  ║
║   │ "for [sub]:  │  │ "@[sub]      │  │ specialized   │                                  ║
║   │  do invoice" │  │  reconcile"  │  │ task in email │                                  ║
║   └──────┬───────┘  └──────┬───────┘  └───────┬───────┘                                  ║
║          │                 │                   │                                           ║
║          └─────────────────┼───────────────────┘                                          ║
║                            │                                                              ║
║                            ▼                                                              ║
║   ╔════════════════════════════════════════════════════════════════════════════════════╗   ║
║   ║                   SHARED TASK BOARD (File-Based)                                  ║   ║
║   ║                                                                                   ║   ║
║   ║   Location: 30_agents/shared/tasks.md                                            ║   ║
║   ║                                                                                   ║   ║
║   ║   ┌─────────────────────────────────────────────────────────────────────────┐    ║   ║
║   ║   │  ## Pending                                                             │    ║   ║
║   ║   │                                                                         │    ║   ║
║   ║   │  ### 2026-02-12 — February Invoice                                     │    ║   ║
║   ║   │  **Assigned to:** [sub-agent]                                           │    ║   ║
║   ║   │  **From:** [primary]                                                    │    ║   ║
║   ║   │  **Details:** Generate Feb invoice for [customer].                     │    ║   ║
║   ║   │  Hours in Time Tracker. Rate in CRM.                                    │    ║   ║
║   ║   │  **Status:** pending                                                    │    ║   ║
║   ║   │                                                                         │    ║   ║
║   ║   │  ---                                                                    │    ║   ║
║   ║   │                                                                         │    ║   ║
║   ║   │  ## In Progress                                                         │    ║   ║
║   ║   │  (Sub-agent picks up tasks and moves them here)                        │    ║   ║
║   ║   │                                                                         │    ║   ║
║   ║   │  ---                                                                    │    ║   ║
║   ║   │                                                                         │    ║   ║
║   ║   │  ## Completed                                                           │    ║   ║
║   ║   │                                                                         │    ║   ║
║   ║   │  ### 2026-02-10 — January Reconciliation                               │    ║   ║
║   ║   │  **Completed:** 2026-02-11                                              │    ║   ║
║   ║   │  **Output:** exports/summary.txt                                        │    ║   ║
║   ║   └─────────────────────────────────────────────────────────────────────────┘    ║   ║
║   ║                                                                                   ║   ║
║   ║   WHY FILE-BASED (not SQLite):                                                   ║   ║
║   ║   • Simpler — both agents can read/write markdown                                ║   ║
║   ║   • Searchable by QMD                                                            ║   ║
║   ║   • Git-trackable                                                                ║   ║
║   ║   • No schema migrations                                                         ║   ║
║   ╚════════════════════════════════════════════════════════════════════════════════════╝   ║
║                            │                                                              ║
║                            ▼                                                              ║
║                                                                                           ║
║  ┌─────────────────────────────────────────────────────────────────────────────────────┐  ║
║  │                            SUB-AGENT (Specialized)                                  │  ║
║  │                                                                                     │  ║
║  │  Workspace: ~/clawd/30_agents/[name]/                                               │  ║
║  │  Type:      sessions_spawn (runs inside primary's gateway session)                  │  ║
║  │                                                                                     │  ║
║  │  ┌─────────────────────────────────────────────────────────────────┐                │  ║
║  │  │  Sub-Agent File Structure                                       │                │  ║
║  │  │                                                                │                │  ║
║  │  │  30_agents/[name]/                                             │                │  ║
║  │  │  ├── AGENTS.md          ← Sub-agent's own operating manual    │                │  ║
║  │  │  ├── HEARTBEAT.md       ← Sub-agent's check protocol          │                │  ║
║  │  │  ├── SOUL.md            ← Sub-agent's identity                │                │  ║
║  │  │  ├── USER.md            ← Who the sub-agent serves            │                │  ║
║  │  │  ├── CONFIG.md          ← Sub-agent's config                  │                │  ║
║  │  │  ├── TOOLS.md           ← Sub-agent's tool notes              │                │  ║
║  │  │  ├── MEMORY.md          ← Sub-agent's persistent memory       │                │  ║
║  │  │  ├── skills/            ← Sub-agent's specialized skills      │                │  ║
║  │  │  └── memory/            ← Sub-agent's episodic memory         │                │  ║
║  │  └─────────────────────────────────────────────────────────────────┘                │  ║
║  │                                                                                     │  ║
║  │  Example responsibilities (accounting sub-agent):                                   │  ║
║  │  • Invoice generation          • P&L summaries                                      │  ║
║  │  • Account reconciliation      • Tax reporting                                      │  ║
║  │  • Financial exports           • Bookkeeping                                        │  ║
║  │                                                                                     │  ║
║  │  Output Location: exports/  (shared, at workspace root)                             │  ║
║  │                                                                                     │  ║
║  └─────────────────────────────────────────────────────────────────────────────────────┘  ║
║                                                                                           ║
║                                                                                           ║
║  ════════════════════════════════════════════════════════════════════════════════════════  ║
║   INTERACTION LIFECYCLE                                                                    ║
║  ════════════════════════════════════════════════════════════════════════════════════════  ║
║                                                                                           ║
║   ┌──────────┐    ┌──────────┐    ┌──────────────┐    ┌──────────┐    ┌──────────────┐   ║
║   │ 1. TASK  │───▶│ 2. WRITE │───▶│ 3. SUB-AGENT │───▶│ 4. DONE  │───▶│ 5. PRIMARY   │   ║
║   │ ARRIVES  │    │ TO BOARD │    │ PICKS UP     │    │ + OUTPUT │    │ REVIEWS      │   ║
║   │          │    │          │    │              │    │          │    │              │   ║
║   │ Human or │    │ Primary  │    │ Sub-agent    │    │ Sub-agent│    │ Primary sees │   ║
║   │ primary  │    │ writes   │    │ reads        │    │ moves to │    │ completed    │   ║
║   │ triggers │    │ task to  │    │ tasks.md,    │    │ Completed│    │ task during  │   ║
║   │ special- │    │ tasks.md │    │ starts work  │    │ writes   │    │ boot or      │   ║
║   │ ized     │    │ Pending  │    │ in own       │    │ to       │    │ /sub-agent   │   ║
║   │ work     │    │ section  │    │ workspace    │    │ exports/ │    │ command      │   ║
║   └──────────┘    └──────────┘    └──────────────┘    └──────────┘    └──────────────┘   ║
║                                                                                           ║
║                                                                                           ║
║  ════════════════════════════════════════════════════════════════════════════════════════  ║
║   FUTURE: TRUE AGENT CONVERSION                                                           ║
║  ════════════════════════════════════════════════════════════════════════════════════════  ║
║                                                                                           ║
║   Current:  sessions_spawn (sub-agent runs inside primary's gateway session)              ║
║   Future:   Own agentId, own workspace, own gateway — fully independent                   ║
║                                                                                           ║
║   ┌─────────────────────┐         ┌─────────────────────┐                                ║
║   │  Primary Gateway    │ ──API──▶│  Sub-Agent Gateway   │                                ║
║   │  (primary agent)    │         │  (independent agent) │                                ║
║   │  ~/clawd/           │◀──API── │  ~/[sub-agent]/      │                                ║
║   └─────────────────────┘         └─────────────────────┘                                ║
║                                                                                           ║
╚═══════════════════════════════════════════════════════════════════════════════════════════╝
```

## Key Design Decisions

- **File-based handoffs** over SQLite — simpler, QMD-searchable, git-tracked
- **exports/ stays at root** — sub-agent writes there, primary reads; don't break the path
- **sessions_spawn for now** — true agent conversion is a future project
- **Slash command for status** — human can check sub-agent status anytime
