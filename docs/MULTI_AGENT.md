# Multi-Agent Setup

OpenClaw supports multiple agents on the same machine. The main pattern: a primary agent (Sonnet) for judgment and a lite agent (Kimi) for execution.

## Why Two Agents

- **Main agent:** Orchestration, customer comms, decisions, writing
- **Lite agent:** File processing, bulk operations, API batching, scripting

If a task involves more than ~20 file operations, spawn to lite. The SubZero image processing job (333 files) should have been lite. Don't repeat that mistake.

## Configuration

```json5
{
  agents: {
    list: [
      {
        id: "main",
        workspace: "/Users/you/clawd",
        subagents: { allowAgents: ["main", "lite"] }
      },
      {
        id: "lite",
        workspace: "/Users/you/clawd",
        model: { primary: "moonshot/kimi-k2.5" }
      }
    ]
  }
}
```

## Critical: Index Each Agent Separately

Each agent has its own memory index. They do NOT share.

```bash
# Index main agent
openclaw memory index

# Index lite agent (DO THIS — easy to forget)
openclaw memory index --agent lite
```

**Production failure:** Kimi ran execution tasks for weeks with a completely empty index (0/64 files). No errors — just degraded output because it couldn't look anything up. The fix is one command. Include it in your nightly refresh.

## Spawning Lite Agent

```python
sessions_spawn(
    agentId="lite",
    mode="run",
    task="Your detailed task here with all context needed"
)
```

Give lite thorough task descriptions. It won't ask clarifying questions mid-run.

## Memory Index Refresh

Both indexes need regular updates. Add to nightly launchd job:

```bash
~/.bun/bin/qmd update && ~/.bun/bin/qmd embed
openclaw memory index          # main
openclaw memory index --agent lite  # lite
```
