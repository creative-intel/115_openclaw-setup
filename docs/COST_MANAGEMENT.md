# Cost Management

Running an AI agent 24/7 gets expensive fast. Here's how to keep costs reasonable.

## The Problem

A Claude Sonnet agent running heartbeats every 30 minutes loads a full context window each time. At ~48k tokens per heartbeat × 48 heartbeats/day × $3/MTok = ~$7/day just for heartbeats. Add active work sessions and you're at $50/day easily.

## Model Routing

Use the right model for each job:

| Task | Model | Why |
|------|-------|-----|
| Judgment, customer comms, writing | Sonnet (main) | Quality matters |
| Heartbeat checks | Haiku | Monitoring doesn't need Sonnet |
| Isolated cron jobs | Haiku | Same — mechanical tasks |
| Bulk execution (files, scripts, APIs) | Kimi K2.5 (lite) | Fast, cheap, capable |

**The rule:** If a task involves more than ~20 file operations OR repetitive scripting, spawn it to the lite agent.

## Configure Heartbeat Model

```json5
{
  agents: {
    defaults: {
      heartbeat: {
        every: "30m",
        model: "anthropic/claude-haiku-4-5"  // NOT claude-haiku-4 (wrong name)
      }
    }
  }
}
```

## Configure Lite Agent

```json5
{
  agents: {
    list: [
      {
        id: "lite",
        workspace: "/Users/you/clawd",
        model: { primary: "moonshot/kimi-k2.5" }
      }
    ]
  }
}
```

Add Haiku to allowed models (required for isolated cron sessions):
```json5
{
  agents: {
    defaults: {
      models: {
        "anthropic/claude-haiku-4-5": {}
      }
    }
  }
}
```

⚠️ If you omit this, isolated cron jobs using Haiku will fail with `model not allowed`.

## Cron vs Heartbeat vs launchd

| Mechanism | LLM involved | Cost | Use for |
|-----------|-------------|------|---------|
| Heartbeat | Yes (main model) | Per check | Monitoring needing judgment |
| OpenClaw cron (isolated) | Yes (configurable) | Per run | Scheduled tasks needing LLM |
| macOS launchd | No | Free | Pure shell jobs |

**Key insight:** QMD refresh and memory index updates are pure shell. Use launchd, not cron. Zero LLM cost.
