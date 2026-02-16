# TOOLS.md - Local Notes

Skills define *how* tools work. This file is for *your* specifics - the stuff that's unique to your setup.

---

## What I Have Access To

A complete inventory of your integrations and access:

| Service | Account(s) | Notes |
|---------|-----------|-------|
| **Email** | [your email] | [how you access it - CLI, API, etc.] |
| **Calendar** | [your calendar] | [tool name, e.g., gcalcli] |
| **Task Manager** | [Notion, Todoist, etc.] | [API access? manual?] |
| **GitHub** | [org name] | [via gh CLI, API, etc.] |
| **Messaging** | [iMessage, Slack, etc.] | [tool/plugin name] |

---

## Email

**Tool:** [your email CLI or API]
**Account:** [your email address]

```bash
# List messages
[your-email-tool] list --max 10

# Read a message
[your-email-tool] read <message-id>

# Send a message
[your-email-tool] send --to "recipient@example.com" --subject "Subject" --body "Message body"

# Reply to a message (USE THIS for threaded responses!)
[your-email-tool] reply <message-id> --body "Reply text"
```

**Rules:**
- Don't add manual signatures (your email client handles this)
- Always use `reply` for responses (threads properly), `send` only for NEW topics
- Never mention being AI in external emails

---

## Calendar

**Tool:** [your calendar tool]

```bash
# View upcoming events
[your-calendar-tool] agenda

# Quick add event
[your-calendar-tool] quick "Meeting tomorrow 2pm"
```

**Security:** Only report free/busy times externally, never event details.

---

## QMD (Quick Markdown Search)

**Purpose:** Local semantic search for markdown files - reduces API token usage by finding relevant snippets instead of loading entire files.

**Install:** `~/.bun/bin/qmd` (requires Bun runtime)

```bash
# Fast keyword search (BM25)
qmd search "query" -n 5

# Semantic vector search
qmd vsearch "natural language question" -n 5

# Hybrid search with reranking (best quality, slower)
qmd query "complex question" -n 5

# Search specific collection
qmd search "query" -c memory

# Get specific document
qmd get "memory/2026-01-30.md"

# Update index after new files added
qmd update
```

**When to use:**
- Before reading entire files to find specific info
- Searching across memory/notes for past decisions
- Finding relevant context without burning tokens

**Source:** https://github.com/tobi/qmd

---

## Task Manager

**Tool:** [Notion, Linear, Todoist, etc.]

| Database | ID |
|----------|-----|
| Tasks | [your database ID] |
| Time Tracker | [your database ID] |
| CRM | [your database ID] |

> **Note:** Notion is optional. Use whatever task system works for you. The key is having ONE source of truth for tasks, not the specific tool.

---

## Messaging

### iMessage (if configured)

**Group chats need the `message` tool, NOT individual send.**

```bash
# Find chat_id
imsg chats --limit 20 --json

# Send to group chat
message action=send channel=imessage to=chat_id:5 message="text"
```

### Known Group Chats
| Name | chat_id | Identifier |
|------|---------|------------|
| [Group Name] | [id] | [chat identifier] |

---

## What Goes Here

Things like:
- API tool commands and syntax
- Account names and access methods
- Preferred voices for TTS
- Device nicknames
- SSH hosts and aliases
- Anything environment-specific

## Why Separate from Skills?

Skills are shared and reusable. Your setup is yours. Keeping them apart means you can update skills without losing your notes, and share skills without leaking your infrastructure.

---

*Add whatever helps you do your job. This is your cheat sheet.*
