# Cost Management

Running an AI agent 24/7 gets expensive fast. Here's how to keep costs reasonable.

## The Solution: Kimi K2.5 Primary

As of March 2026, we run **Kimi K2.5 as the primary model** for everything. This dropped costs from ~$50/day to nearly zero (Kimi free tier).

## Model Routing (Current)

| Task | Model | Why |
|------|-------|-----|
| All tasks (primary) | Kimi K2.5 | Free, fast, capable enough |
| Fallback only | Haiku | When Kimi is down |
| Heartbeats | Kimi K2.5 | Same as primary |

**Previous approach (deprecated):** Sonnet for judgment, Haiku for heartbeats, Kimi for bulk. This was complex and expensive. Kimi handles everything adequately.

## When to Use Sonnet

Only if you need:
- Complex multi-step reasoning
- Sensitive customer communications requiring nuance
- Tasks where Kimi consistently fails

For most operations, Kimi is sufficient.

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
