#!/usr/bin/env bash
# session-end.sh — Append a structured WORKLOG entry template
# Called by /session-end command-dispatch skill.
# Writes the template to WORKLOG.md and opens it for the agent to fill in.

set -euo pipefail

WORKSPACE="/Users/you/clawd"
WORKLOG="$WORKSPACE/WORKLOG.md"
DATE=$(date '+%Y-%m-%d')
DAY=$(date '+%A')

TEMPLATE="
---
## $DATE ($DAY)

**Completed:**
- 

**Files Changed:**
- 

**Decisions:**
- 

**Lessons:**
- 

**Tasks Created:** 

**Open Blockers:**
- 
"

echo "$TEMPLATE" >> "$WORKLOG"
echo "Template appended to WORKLOG.md for $DATE. Fill in the fields above."
