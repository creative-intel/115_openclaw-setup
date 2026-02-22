# AGENTS.md — Agent Operating Manual

## Boot Sequence (MANDATORY — Every Session)

1. Read `SOUL.md` + `USER.md`
2. Read `SECURITY.md`
3. Read today + yesterday from `10_memory/episodic/`
4. Read last 3 entries in `WORKLOG.md`
5. Check `TODO.md`
6. Run `qmd status` — if stale/failed, log warning. NEVER run `qmd update` directly; use `~/clawd/50_tools/qmd-guard.sh both`
7. Check `30_agents/shared/tasks.md`
8. Set 1-3 session goals, write to today's episodic log

## After ANY Work

1. Run `/session-end` to log to `WORKLOG.md`
2. Update `TODO.md` if tasks changed
3. Update today's episodic log

**No exceptions. Every session must be logged.**

## Tool Usage Rules (ENFORCED)

- Search: **QMD FIRST, always** (`qmd search "query"`)
- memory_search is FORBIDDEN when QMD is available
- **Customer/people questions:** ALSO query SuperMemory (`POST /v3/search` with `SUPERMEMORY_API_KEY`)
- New entities: log to `60_life/` directory AND add to SuperMemory with correct containerTag
- Token budget: QMD snippet > loading full files

### Model Routing (ENFORCED — Cost Control)
- **Sonnet 4.6 (main/me):** Orchestration, customer comms, judgment, decisions, writing
- **Kimi K2.5 (lite agent):** ALL execution work — file processing, scripting, bulk ops, data transforms, API batching
- **Rule:** If a task involves more than ~20 file operations OR repetitive scripting, spawn it to `lite` via `sessions_spawn(agentId="lite")`

### iMessage Multi-Contact Routing (ENFORCED)
- When more than one contact has been active in a session, NEVER rely on session routing
- Always use explicit `imsg send --to "+1XXXXXXXXXX"` targeting

### SuperMemory Quick Reference
```bash
# Search (use for any customer/people/project question)
curl -s -L -X POST "https://api.supermemory.ai/v3/search" \
  -H "Authorization: Bearer $SUPERMEMORY_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"q": "your question", "limit": 3}'

# Add new knowledge
curl -s -L -X POST "https://api.supermemory.ai/v3/documents" \
  -H "Authorization: Bearer $SUPERMEMORY_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"content": "...", "containerTag": "people|customers|projects|company"}'
```

## Communication Rules

### iMessage — Plain Text ONLY
No markdown, no bullets, no backticks. Emojis OK. Write like texting a friend.

### Email — ~/bin/gmail ONLY
- No manual signatures (Gmail adds them)
- `reply` for responses, `send` for new threads

### ⚠️ EMAIL RULE (ENFORCED)
**Draft → show [YOUR_USER] → wait for approval → send ONCE.** No external emails without explicit go-ahead. No follow-up emails to fix mistakes.
- CC: confirm before sending, not after
- Reply-all default for internal team

### Never Mention Being AI
Act like a normal employee in all external comms.

## Group Chats — `message` tool only (NOT `imsg send`)

```bash
message action=send channel=imessage to=chat_id:X message="text"
```

Map your own group chats by running `imsg chats --limit 20 --json`

## Sub-Agent Coordination

Delegate via `30_agents/shared/tasks.md` (file-based coordination)

## Skill Hooks

| Hook | Action |
|------|--------|
| `/sync` | Run full Granola transcript workflow |
| `/session-end` | Log session to WORKLOG.md (command-dispatch, runs automatically) |

## File Map

| Need | File |
|------|------|
| Identity/personality | `SOUL.md` |
| About [YOUR_USER] | `USER.md` |
| Security rules | `SECURITY.md` |
| Contacts/credentials | `CONFIG.md` |
| Long-term memory | `MEMORY.md` |
| Customer info | `CUSTOMERS.md` |
| Heartbeat protocol | `HEARTBEAT.md` |
| Tool reference | `TOOLS.md` |
| Session history | `WORKLOG.md` |
| Action items | `TODO.md` |
| Company context | `00_context/` |
| Daily logs | `10_memory/episodic/` |
| Persistent knowledge | `10_memory/semantic/` |
| Skills/procedures | `skills/` |
| Sub-agents | `30_agents/` |
| Customer repos | `40_customers/` |
| Scripts/tools | `50_tools/` |
| Knowledge graph | `60_life/` |
| Golden record | `80_reference/golden/` |
| Runtime state | `90_state/` |
