#!/bin/bash
# weekly-audit.sh
# Weekly drift detection audit
# Run this weekly to detect configuration drift

set -e

WORKSPACE_DIR="${1:-$(pwd)}"
GOLDEN_DIR="$WORKSPACE_DIR/80_reference/golden"
DRIFT_FOUND=0

echo "🔍 Weekly Drift Audit"
echo "═══════════════════════════════════════════════════════════════"
echo "Workspace: $WORKSPACE_DIR"
echo "Golden Record: $GOLDEN_DIR"
echo "Date: $(date)"
echo ""

# Check if golden directory exists
if [ ! -d "$GOLDEN_DIR" ]; then
    echo "❌ ERROR: Golden record directory not found!"
    echo "   Run: ./scripts/init-golden.sh to establish baseline"
    exit 1
fi

# Files to check
FILES=("AGENTS.md" "CONFIG.md" "SECURITY.md" "TOOLS.md" "HEARTBEAT.md")

echo "Checking golden files for drift..."
echo ""

for file in "${FILES[@]}"; do
    golden_file="$GOLDEN_DIR/$file"
    current_file="$WORKSPACE_DIR/$file"
    
    # Check if golden file exists
    if [ ! -f "$golden_file" ]; then
        echo "❌ MISSING: $file not found in golden record"
        DRIFT_FOUND=1
        continue
    fi
    
    # Check if current file exists
    if [ ! -f "$current_file" ]; then
        echo "❌ MISSING: $file not found in workspace root"
        DRIFT_FOUND=1
        continue
    fi
    
    # Compare files
    if diff -q "$golden_file" "$current_file" > /dev/null 2>&1; then
        echo "✅ $file"
    else
        echo "⚠️  DRIFT: $file has changed"
        echo "   Run: diff $GOLDEN_DIR/$file ./$file"
        DRIFT_FOUND=1
    fi
done

echo ""

# Check file sizes (AGENTS.md and SECURITY.md shouldn't grow too large)
echo "Checking file health..."
echo ""

if [ -f "$WORKSPACE_DIR/AGENTS.md" ]; then
    lines=$(wc -l < "$WORKSPACE_DIR/AGENTS.md")
    if [ $lines -gt 200 ]; then
        echo "⚠️  AGENTS.md is $lines lines (recommend < 200)"
        DRIFT_FOUND=1
    else
        echo "✅ AGENTS.md: $lines lines"
    fi
fi

if [ -f "$WORKSPACE_DIR/SECURITY.md" ]; then
    lines=$(wc -l < "$WORKSPACE_DIR/SECURITY.md")
    if [ $lines -gt 100 ]; then
        echo "⚠️  SECURITY.md is $lines lines (recommend < 100)"
        DRIFT_FOUND=1
    else
        echo "✅ SECURITY.md: $lines lines"
    fi
fi

# Check for QMD status
echo ""
echo "Checking QMD status..."
echo ""

if command -v qmd &> /dev/null; then
    if qmd status &> /dev/null; then
        index_age=$(stat -c %Y ~/.cache/qmd/index.sqlite 2>/dev/null || stat -f %m ~/.cache/qmd/index.sqlite 2>/dev/null)
        current_time=$(date +%s)
        age_days=$(( (current_time - index_age) / 86400 ))
        
        if [ $age_days -gt 7 ]; then
            echo "⚠️  QMD index is $age_days days old (recommend updating weekly)"
            echo "   Run: qmd update"
            DRIFT_FOUND=1
        else
            echo "✅ QMD index: $age_days days old"
        fi
    else
        echo "⚠️  QMD status check failed"
        DRIFT_FOUND=1
    fi
else
    echo "⚠️  QMD not installed"
    DRIFT_FOUND=1
fi

# Check for uncommitted changes
echo ""
echo "Checking git status..."
echo ""

cd "$WORKSPACE_DIR"

if [ -d ".git" ]; then
    uncommitted=$(git status --porcelain 2>/dev/null | wc -l)
    if [ $uncommitted -gt 0 ]; then
        echo "⚠️  $uncommitted uncommitted changes"
        echo "   Review and commit: git status"
        DRIFT_FOUND=1
    else
        echo "✅ No uncommitted changes"
    fi
    
    # Check last commit date
    last_commit=$(git log -1 --format=%ct 2>/dev/null || echo "0")
    current_time=$(date +%s)
    days_since_commit=$(( (current_time - last_commit) / 86400 ))
    
    if [ $days_since_commit -gt 7 ]; then
        echo "⚠️  Last commit was $days_since_commit days ago"
    else
        echo "✅ Last commit: $days_since_commit days ago"
    fi
else
    echo "⚠️  Not a git repository"
fi

# Summary
echo ""
echo "═══════════════════════════════════════════════════════════════"

if [ $DRIFT_FOUND -eq 0 ]; then
    echo "🎉 Audit passed! No drift detected."
    echo "═══════════════════════════════════════════════════════════════"
    exit 0
else
    echo "⚠️  Audit complete with warnings."
    echo ""
    echo "Action required:"
    echo "1. Review drifted files"
    echo "2. If intentional: update golden record"
    echo "3. If accidental: restore from golden record"
    echo "═══════════════════════════════════════════════════════════════"
    exit 1
fi
