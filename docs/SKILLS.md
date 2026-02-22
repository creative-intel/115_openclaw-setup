# Skills and Slash Commands

OpenClaw has three categories of automation. Understanding the difference matters.

## Category 1: Reference Skills (text-only)

SKILL.md files that inject instructions into the system prompt. The LLM reads them and decides when to follow them.

**Use for:** Formatting rules, communication guidelines, reference documentation.

**Failure mode:** LLM ignores them under pressure. Fix: make rules shorter, not longer.

**Example:** `skills/imessage.md` — "plain text only, write like texting"

---

## Category 2: Hook-Triggered Script Skills

SKILL.md wrapper around an actual script. LLM decides WHEN, script handles HOW.

**Use for:** Multi-step workflows that always follow the same steps (Granola sync, index refresh).

**Pattern:**
```markdown
# /sync
Run: `bash /path/to/sync.sh`
Report the output.
```

**Example:** `granola-sync` skill — LLM triggers `/sync`, script fetches transcripts deterministically.

---

## Category 3: Command-Dispatch Skills (most deterministic)

Skills with `command-dispatch: tool` frontmatter bypass the LLM entirely. The slash command executes as a direct tool call.

**Use for:** Fixed-format outputs that must never drift (WORKLOG entries, health checks).

**SKILL.md frontmatter:**
```yaml
---
name: session-end
description: Log this session to WORKLOG.md
user-invocable: true
command-dispatch: tool
command-tool: exec
---
```

**Current limitation:** `exec` tool requires a command string parameter. Zero-argument dispatch doesn't work cleanly without a custom plugin. Workaround: hardcode the script path in the skill instructions so the model's only job is "run this one script."

---

## Slash Commands

On Telegram/Discord, skills with `user-invocable: true` (default) register as native slash commands.

Key system slash commands:
- `/health` — system health check
- `/sync` — Granola transcript sync
- `/session-end` — log session to WORKLOG.md
- `/context detail` — see what's loading into your context window
- `/status` — agent status
