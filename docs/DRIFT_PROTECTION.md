# Drift Protection

Drift is what happens when your agent configuration slowly changes over time without intentional updates. Drift protection detects and flags these changes.

## What is Drift?

### Example 1: The Slowly Changing Prompt
```markdown
# Original SECURITY.md
- Never share customer details
```

Two months later:
```markdown
# Current SECURITY.md  
- Try not to share customer details unless it's important
```

**Drift detected:** The rule weakened over time.

### Example 2: The Growing AGENTS.md
```markdown
# Original AGENTS.md - 50 lines
1. Read SOUL.md
2. Read USER.md
...
```

Two months later:
```markdown
# Current AGENTS.md - 500 lines
1. Read SOUL.md
2. Read USER.md
3. Read 15 other files...
4. Check 8 databases...
5. Run 12 verification scripts...
```

**Drift detected:** The boot sequence became bloated.

### Example 3: The Missing Rule
Original `SECURITY.md` had 5 rules. Current version has 3. Two rules disappeared.

**Drift detected:** Security rules were lost.

---

## The Golden Record

Drift protection works by comparing current files against a "golden record" — immutable baseline files that define how the agent should operate.

### Golden Record Location
```
80_reference/golden/
├── AGENTS.md      # Boot sequence
├── CONFIG.md      # Contacts and references
├── SECURITY.md    # Rules of engagement
├── TOOLS.md       # Tool usage guides
└── HEARTBEAT.md   # Proactive monitoring
```

### Why These Files?

These files define the agent's **operating system**. They should change rarely and intentionally.

| File | Why Golden? |
|------|-------------|
| AGENTS.md | Changes to boot sequence are high-impact |
| CONFIG.md | Contact info shouldn't drift |
| SECURITY.md | Security rules must stay consistent |
| TOOLS.md | Tool usage should be stable |
| HEARTBEAT.md | Monitoring protocol shouldn't change often |

### What Makes Them "Golden"

1. **Intentional Changes Only** — Only update when you deliberately want to change behavior
2. **Version Controlled** — Track changes in git
3. **Reviewed** — Major changes get reviewed (by human or self-check)
4. **Audited** — Weekly automated comparison

---

## The Weekly Audit

Every week, run `scripts/weekly-audit.sh` to detect drift.

### What the Audit Checks

```bash
#!/bin/bash
# weekly-audit.sh

GOLDEN_DIR="80_reference/golden"
ROOT_DIR="."

# Files to check
FILES=("AGENTS.md" "CONFIG.md" "SECURITY.md" "TOOLS.md" "HEARTBEAT.md")

for file in "${FILES[@]}"; do
    if ! diff -q "$GOLDEN_DIR/$file" "$ROOT_DIR/$file" > /dev/null 2>&1; then
        echo "⚠️  DRIFT DETECTED: $file"
        echo "   Run: diff $GOLDEN_DIR/$file $ROOT_DIR/$file"
    fi
done
```

### Audit Output

```
✅ AGENTS.md — No drift
✅ CONFIG.md — No drift
⚠️  SECURITY.md — DRIFT DETECTED
   Run: diff 80_reference/golden/SECURITY.md ./SECURITY.md
✅ TOOLS.md — No drift
✅ HEARTBEAT.md — No drift
```

### When Drift is Detected

**Step 1: Understand the drift**
```bash
diff 80_reference/golden/SECURITY.md ./SECURITY.md
```

**Step 2: Decide intentional or accidental**
- **Accidental:** Revert to golden version
- **Intentional:** Update golden version to match

**Step 3: Document the change**
```bash
# If intentional
cp ./SECURITY.md 80_reference/golden/SECURITY.md
git add 80_reference/golden/SECURITY.md
git commit -m "Update SECURITY.md: Added rule about X"
```

---

## Drift vs. Evolution

Not all change is bad. The key is **intention**.

| Drift (Bad) | Evolution (Good) |
|-------------|------------------|
| Happens accidentally | Happens deliberately |
| Not documented | Committed with message |
| Weakens constraints | Improves functionality |
| No review | Considered and approved |

### Acceptable Changes to Golden Files

**AGENTS.md:**
- ✅ Adding a new critical file to boot sequence
- ✅ Removing a step that's no longer needed
- ❌ Adding "just in case" steps

**CONFIG.md:**
- ✅ Adding a new team member
- ✅ Updating a phone number
- ❌ Adding temporary contacts

**SECURITY.md:**
- ✅ Adding a new security rule
- ✅ Clarifying existing rules
- ❌ Weakening existing rules

**TOOLS.md:**
- ✅ Adding a new tool guide
- ✅ Updating tool syntax
- ❌ Adding draft/incomplete guides

---

## Setting Up Drift Protection

### 1. Create Golden Directory
```bash
mkdir -p 80_reference/golden
```

### 2. Copy Current Files as Baseline
```bash
cp AGENTS.md 80_reference/golden/
cp CONFIG.md 80_reference/golden/
cp SECURITY.md 80_reference/golden/
cp TOOLS.md 80_reference/golden/
cp HEARTBEAT.md 80_reference/golden/
```

### 3. Commit Baseline
```bash
git add 80_reference/golden/
git commit -m "Establish golden record baseline"
```

### 4. Add Audit Script
Save to `50_tools/scripts/weekly-audit.sh`:

```bash
#!/bin/bash
set -e

echo "🔍 Running Weekly Drift Audit..."
echo ""

GOLDEN_DIR="80_reference/golden"
ROOT_DIR="."
DRIFT_FOUND=0

FILES=("AGENTS.md" "CONFIG.md" "SECURITY.md" "TOOLS.md" "HEARTBEAT.md")

for file in "${FILES[@]}"; do
    if [ ! -f "$GOLDEN_DIR/$file" ]; then
        echo "❌ MISSING: $file not in golden record"
        DRIFT_FOUND=1
        continue
    fi
    
    if [ ! -f "$ROOT_DIR/$file" ]; then
        echo "❌ MISSING: $file not in root directory"
        DRIFT_FOUND=1
        continue
    fi
    
    if diff -q "$GOLDEN_DIR/$file" "$ROOT_DIR/$file" > /dev/null 2>&1; then
        echo "✅ $file"
    else
        echo "⚠️  DRIFT: $file has changed"
        DRIFT_FOUND=1
    fi
done

echo ""
if [ $DRIFT_FOUND -eq 0 ]; then
    echo "🎉 No drift detected. All golden files match."
else
    echo "⚠️  Drift detected. Review changes and update golden record if intentional."
    exit 1
fi
```

### 5. Make Executable and Test
```bash
chmod +x 50_tools/scripts/weekly-audit.sh
./50_tools/scripts/weekly-audit.sh
```

### 6. Schedule Weekly Runs

**Option A: Cron (Mac/Linux)**
```bash
# Run every Sunday at 9am
0 9 * * 0 cd ~/clawd && ./50_tools/scripts/weekly-audit.sh >> 10_memory/episodic/weekly-audit.log 2>&1
```

**Option B: Add to Heartbeat Protocol**
Add "Drift Audit" as a weekly check in `HEARTBEAT.md`.

---

## Handling Detected Drift

### Scenario 1: Accidental Drift

**What happened:** You accidentally deleted a security rule.

**Fix:**
```bash
# Restore from golden record
cp 80_reference/golden/SECURITY.md ./SECURITY.md

# Log the incident
echo "Restored SECURITY.md from golden record after accidental deletion" >> 10_memory/episodic/$(date +%Y-%m-%d).md
```

### Scenario 2: Intentional Change

**What happened:** You deliberately added a new team member to CONFIG.md.

**Fix:**
```bash
# Update golden record
cp ./CONFIG.md 80_reference/golden/CONFIG.md

# Commit the change
git add 80_reference/golden/CONFIG.md
git commit -m "Update CONFIG.md: Added Mark Glotzbach to contacts"
```

### Scenario 3: Uncertain Change

**What happened:** Drift detected, but you're not sure if it's intentional.

**Fix:**
```bash
# Check what changed
diff 80_reference/golden/AGENTS.md ./AGENTS.md

# If unsure, ask your human
# "I noticed AGENTS.md has drifted from golden record. 
#  The change is [X]. Was this intentional?"
```

---

## Advanced Drift Detection

### Content Drift (Not Just File Changes)

Sometimes the file is the same, but the content has drifted in meaning:

```bash
# Check for weakening language
if grep -q "try not to" SECURITY.md; then
    echo "⚠️  SECURITY.md may have weakened: contains 'try not to'"
fi

# Check for growing files
AGENTS_LINES=$(wc -l < AGENTS.md)
if [ $AGENTS_LINES -gt 200 ]; then
    echo "⚠️  AGENTS.md is $AGENTS_LINES lines (recommend < 200)"
fi
```

### Semantic Drift

Check if concepts are being redefined:

```bash
# Check if "never" is becoming "sometimes"
grep -n "never" 80_reference/golden/SECURITY.md > /tmp/golden_nevers.txt
grep -n "never" ./SECURITY.md > /tmp/current_nevers.txt

if ! diff -q /tmp/golden_nevers.txt /tmp/current_nevers.txt; then
    echo "⚠️  'Never' statements in SECURITY.md have changed"
fi
```

---

## Research: Why Drift Happens

Drift is a well-documented phenomenon in:

- **Software:** Configuration drift in production systems
- **Organizations:** Mission creep and scope expansion
- **Psychology:** Gradual normalization of deviant behavior
- **Aviation:** Checklists that get modified without review

Golden records and drift audits are standard practices in:
- NASA (software baselines)
- Banking (compliance audits)
- DevOps (infrastructure as code)
- Medicine (clinical protocol reviews)

Your agent's operating system deserves the same rigor.
