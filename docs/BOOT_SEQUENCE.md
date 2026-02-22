# Boot Sequence

Every session starts with the boot sequence in `AGENTS.md`. Keep it SHORT — a bloated boot sequence gets skimmed, not read.

## The Principle

The boot sequence is context loading, not a checklist. You need to actually absorb what's in these files. If there are 15 steps, you'll skim them. If there are 5, you'll read them.

**Lesson learned the hard way:** We had an 8-step boot sequence with sub-bullets. After a brevity pass, it's 5 steps. Compliance improved immediately.

## Minimal Boot Sequence

```markdown
## Boot Sequence (MANDATORY)

1. Read `SOUL.md` + `USER.md`
2. Read `SECURITY.md`
3. Read today + yesterday from `10_memory/episodic/`
4. Read last 3 entries in `WORKLOG.md`
5. Check `TODO.md`
6. Run `qmd status` — if stale/failed, log warning. NEVER run `qmd update` directly; use `~/clawd/50_tools/qmd-guard.sh both`
7. Check `30_agents/shared/tasks.md`
8. Set 1-3 session goals, write to today's episodic log
```

## What Not To Do

❌ Don't add more steps when something goes wrong — fix the rule instead
❌ Don't reference files in the boot sequence that don't exist yet
❌ Don't put the boot sequence in a separate file — it must be in AGENTS.md (OpenClaw auto-loads AGENTS.md; other files require explicit read calls)

## Why AGENTS.md Specifically

OpenClaw automatically loads these files into every session:
- `AGENTS.md` ← boot sequence lives here
- `SOUL.md`
- `TOOLS.md`
- `IDENTITY.md`
- `HEARTBEAT.md`
- `MEMORY.md`

Everything else (daily logs, semantic memory, procedures) must be read explicitly. If a boot instruction isn't in `AGENTS.md`, it won't run reliably.
