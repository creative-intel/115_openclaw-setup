# Messaging Setup

OpenClaw supports multiple messaging channels simultaneously. This document explains how to configure and use iMessage and Telegram together — each for different purposes.

## TL;DR: Use Both

| Channel | Use For | Why |
|---------|---------|-----|
| **iMessage** | Personal contacts, casual check-ins | Already on your phone, natural for friends/family |
| **Telegram** | Operations, work, customer comms | Markdown support, topics, reliable group routing |

They're not competitors. Run both.

---

## iMessage

### What Works

**Direct messages:** Perfect. Text anyone in your contacts:
```bash
imsg send --to "+16165551234" "Running late, be there in 10"
```

**Plain text only:** No markdown, no bullets, no backticks. Write like you're texting a friend:
```
Good: "The meeting is at 3pm. I'll bring the report."
Bad: "The meeting is at *3pm*. I'll bring the `report`."
```

### The Group Chat Problem

**`imsg send` silently fails for group chats.** No error message, no indication of failure — the message just doesn't go through.

**The workaround:** Use the `message` tool with `chat_id:N`:
```bash
message action=send channel=imessage to=chat_id:5 message="Hello group"
```

### Finding Group Chat IDs

```bash
imsg chats --limit 20 --json
```

Look for entries like:
```json
{
  "id": 5,
  "chat_identifier": "chat970024608330610355",
  "display_name": "Cort + Andrew"
}
```

The `id` (5) is what you use with `chat_id:5`. The `chat_identifier` is Apple's internal ID and changes between sessions.

### Document Your Group Chats

Add this table to `AGENTS.md`:

```markdown
## Group Chats — `message` tool only (NOT `imsg send`)

| Name | chat_id |
|------|---------|
| Cort + Andrew | 5 |
| Family | 12 |
| Dev team | 8 |
```

### Multi-Contact Routing Failure Mode

When multiple people message you in the same session, iMessage sessions can collapse into one stream. The agent may send replies to the wrong person.

**Prevention:** When more than one contact is active, always use explicit targeting:
```bash
imsg send --to "+16164023426" "Message for Cort specifically"
```

---

## Telegram

### Why Telegram Was Added

| Feature | iMessage | Telegram |
|---------|----------|----------|
| Markdown | ❌ | ✅ |
| Code blocks | ❌ | ✅ |
| Topic threads | ❌ | ✅ |
| Group routing | Confusing (chat_id mapping) | Explicit (chatId + threadId) |
| Cross-platform history | macOS only | All devices |
| Bot API | Limited | Full-featured |

Telegram handles operations communication better. iMessage handles personal communication naturally.

### Setup

**Step 1: Create a Bot**

Message @BotFather on Telegram:
```
/newbot
MyClawBot
myclaw_bot
```

BotFather replies with a token:
```
Use this token to access the HTTP API:
123456789:ABCdefGHIjklMNOpqrsTUVwxyz
```

**Step 2: Add Token to Config**

Edit `~/.openclaw/openclaw.json`:
```json
{
  "channels": {
    "telegram": {
      "token": "123456789:ABCdefGHIjklMNOpqrsTUVwxyz",
      "dmPolicy": "pairing"
    }
  }
}
```

**Step 3: Pair Your Account**

1. Restart OpenClaw gateway: `openclaw gateway restart`
2. Message your bot any text
3. Check the gateway logs for a pairing code:
   ```bash
   grep "pairing code" ~/.clawdbot/logs/gateway.log
   ```
4. Send the pairing code to the bot
5. You're paired

### Group Topics (Customer Threads)

Telegram groups support **topics** — threaded conversations within a group. Perfect for one-topic-per-customer ops.

**Setup:**

1. Create a Telegram group
2. Enable Topics: Group Info → Topics → Enable
3. Add your bot as admin (required to create topics)
4. Create topics manually or via API

**Routing:**
```
<chatId>:topic:<messageThreadId>
```

Example:
```bash
# Get the chatId
message action=send channel=telegram to="-1001234567890" message="test"
# Check logs for the actual chatId used

# Send to a specific topic
message action=send channel=telegram to="-1001234567890:topic:15" message="Customer update"
```

**Finding topic IDs:**

When someone posts in a topic, the gateway logs show the thread ID. Or create topics via Bot API:
```bash
curl -X POST "https://api.telegram.org/bot<TOKEN>/createForumTopic" \
  -d "chat_id=-1001234567890" \
  -d "name=Customer: Acme Corp"
```

---

## Running Both Channels

### Architecture

```
┌─────────────┐     ┌─────────────┐
│   iMessage  │     │   Telegram  │
│  (personal) │     │   (ops/work)│
└──────┬──────┘     └──────┬──────┘
       │                   │
       └─────────┬─────────┘
                 │
          ┌──────▼──────┐
          │  OpenClaw   │
          │   Gateway   │
          └──────┬──────┘
                 │
            ┌────▼────┐
            │  Agent  │
            └─────────┘
```

Both channels route to the same agent. The agent decides how to respond based on context.

### Response Routing

**From iMessage:** Reply to iMessage (same channel)
**From Telegram:** Reply to Telegram (same channel)

If you need to cross-post, do it explicitly:
```bash
# Message arrives on iMessage from Cort
# You want to also notify Telegram ops channel

message action=send channel=telegram to="-1001234567890" message="Cort said: [summary]"
message action=send channel=imessage to="+16164023426" message="Got it, posted to ops channel"
```

### Config Example

```json
{
  "channels": {
    "imessage": {
      "enabled": true
    },
    "telegram": {
      "token": "123456789:ABCdef...",
      "dmPolicy": "pairing",
      "allowedChatIds": ["-1001234567890"],
      "threadMapping": {
        "acme-corp": "-1001234567890:topic:15",
        "widgetco": "-1001234567890:topic:22"
      }
    }
  }
}
```

---

## Best Practices

### iMessage

- Plain text only — no markdown
- Use explicit `--to` targeting when multiple contacts active
- Document group chat IDs in AGENTS.md
- Use `message` tool (not `imsg send`) for groups
- Casual tone, emoji OK

### Telegram

- Markdown OK (bold, italic, code blocks)
- Use topics for customer threads
- Pin important messages
- Use for anything needing formatting
- Professional but friendly tone

### Both

- Never mention being AI in external comms
- Draft sensitive messages → get approval → send once
- When in doubt, prefer explicit routing over implicit session routing

---

## Troubleshooting

### iMessage not receiving
```bash
# Check if the gateway sees messages
openclaw gateway logs | grep imessage

# Verify iMessage is enabled in config
openclaw config get channels.imessage.enabled
```

### Telegram not receiving
```bash
# Test the bot manually
curl "https://api.telegram.org/bot<TOKEN>/getMe"

# Should return bot info. If 401 Unauthorized, token is wrong.
```

### Group chat messages not sending (iMessage)
- Are you using `imsg send`? → Switch to `message` tool with `chat_id:N`
- Is the chat_id correct? → Re-run `imsg chats --json`

### Topics not working (Telegram)
- Is the bot an admin? → Check group settings
- Are topics enabled? → Group Info → Topics
- Is the threadId correct? → Check gateway logs for actual IDs used
