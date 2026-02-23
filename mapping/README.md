# Architecture Maps

These files are the source of truth for Marcus agent architecture diagrams.

## ⚠️ SYNC RULE — READ BEFORE EDITING

**Whenever you update any file in this folder, you MUST also update the Notion page:**

> 📄 **Notion: Marcus Architecture Maps**
> https://www.notion.so/creative-intelligence-ai/Marcus-Architecture-Maps-307d48b650c081828bb4f36fbfd38908

The Notion page contains rendered versions of these maps for easy reference.
It will go stale if you forget to update it.

**Checklist when editing a map:**
- [ ] Edit the `.md` file here
- [ ] Copy updated diagram/content to the corresponding Notion sub-page
- [ ] Update "Last updated" date on the Notion index page
- [ ] Commit and push to this repo
- [ ] Mirror changes to `~/clawd/mapping/` (workspace copy)

---

## Maps Index

| File | Description | Notion Sub-page |
|------|-------------|-----------------|
| `01-openclaw-features.md` | Hook commands, heartbeat, cron jobs | Map 01 |
| `02-memory-system.md` | Three-tier memory + QMD retrieval | Map 02 |
| `03-boot-sequence.md` | 8-step mandatory session startup | Map 03 |
| `04-communication-routing.md` | Channel selection + format rules | Map 04 |
| `05-sub-agent-coordination.md` | Marcus ↔ Morgan task delegation | Map 05 |
| `06-tool-credential-map.md` | All integrations + auth locations | Map 06 |
| `07-directory-structure.md` | Post-restructure workspace layout | Map 07 |

**Last synced to Notion:** 2026-02-13 ⚠️ (may be out of date)
