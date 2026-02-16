# Skill: Session End

After ANY work session, follow this procedure. No exceptions.

## Steps

### 1. Append to WORKLOG.md

```markdown
## YYYY-MM-DD HH:MM - [Brief Title]
- What you did
- Key decisions made
- Problems encountered
- Files changed
```

### 2. Update TODO.md

- Mark completed items with `[x]`
- Add new items discovered during work
- Re-prioritize if needed

### 3. Update Today's Episodic Log

File: `10_memory/episodic/YYYY-MM-DD.md`

- What was accomplished
- Decisions made and why
- Problems encountered
- Context for tomorrow's session

### 4. Commit Changes (if applicable)

```bash
git add -A
git commit -m "[type]: brief description of what changed"
```

---

*Every session must be logged. This is how you persist across sessions.*
