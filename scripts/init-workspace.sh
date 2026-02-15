#!/bin/bash
# init-workspace.sh
# Initialize a new OpenClaw workspace with full directory structure

set -e

WORKSPACE_DIR="${1:-$HOME/clawd}"
echo "🚀 Initializing OpenClaw workspace at: $WORKSPACE_DIR"
echo ""

# Create directory structure
echo "📁 Creating directory structure..."
mkdir -p "$WORKSPACE_DIR"/{00_context,10_memory/{episodic,semantic,archive,standups,transcripts},30_agents/shared,40_customers,50_tools/scripts,60_life/{projects,areas,resources,archives},80_reference/golden,90_state,99_archive}

echo "✅ Directories created"
echo ""

# Create empty files
echo "📄 Creating initial files..."

touch "$WORKSPACE_DIR/WORKLOG.md"
touch "$WORKSPACE_DIR/TODO.md"

cat > "$WORKSPACE_DIR/MEMORY.md" << 'EOF'
# MEMORY.md — Long-Term Memory Pointers

> This file contains pointers to source-of-truth locations.

## Quick Pointers

| Topic | Location |
|-------|----------|
| Identity & personality | `SOUL.md` |
| Company context | `00_context/company-history.md` |
| Daily logs | `10_memory/episodic/YYYY-MM-DD.md` |
| Lessons learned | `10_memory/semantic/lessons-learned.md` |
| Projects | `10_memory/semantic/projects.md` |
| Procedures | `10_memory/semantic/procedures.md` |
| Customer info | `CUSTOMERS.md` |
| Contacts | `CONFIG.md` |
| Security rules | `SECURITY.md` |

## Key Notion Pages (if applicable)

| Document | Page ID |
|----------|---------|
| Task Manager | [Your Notion DB ID] |
| CRM | [Your Notion DB ID] |

---

*Update this file as your system evolves.*
EOF

echo "✅ Initial files created"
echo ""

# Copy examples if they exist
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXAMPLES_DIR="$SCRIPT_DIR/../examples"

if [ -d "$EXAMPLES_DIR" ]; then
    echo "📋 Copying example files..."
    
    if [ -f "$EXAMPLES_DIR/SOUL.md" ]; then
        cp "$EXAMPLES_DIR/SOUL.md" "$WORKSPACE_DIR/SOUL.md"
        echo "   ✅ SOUL.md"
    fi
    
    if [ -f "$EXAMPLES_DIR/USER.md" ]; then
        cp "$EXAMPLES_DIR/USER.md" "$WORKSPACE_DIR/USER.md"
        echo "   ✅ USER.md"
    fi
    
    if [ -f "$EXAMPLES_DIR/AGENTS.md" ]; then
        cp "$EXAMPLES_DIR/AGENTS.md" "$WORKSPACE_DIR/AGENTS.md"
        echo "   ✅ AGENTS.md"
    fi
    
    if [ -f "$EXAMPLES_DIR/SECURITY.md" ]; then
        cp "$EXAMPLES_DIR/SECURITY.md" "$WORKSPACE_DIR/SECURITY.md"
        echo "   ✅ SECURITY.md"
    fi
    
    if [ -f "$EXAMPLES_DIR/CONFIG.md" ]; then
        cp "$EXAMPLES_DIR/CONFIG.md" "$WORKSPACE_DIR/CONFIG.md"
        echo "   ✅ CONFIG.md"
    fi
    
    if [ -f "$EXAMPLES_DIR/HEARTBEAT.md" ]; then
        cp "$EXAMPLES_DIR/HEARTBEAT.md" "$WORKSPACE_DIR/HEARTBEAT.md"
        echo "   ✅ HEARTBEAT.md"
    fi
    
    if [ -f "$EXAMPLES_DIR/TOOLS.md" ]; then
        cp "$EXAMPLES_DIR/TOOLS.md" "$WORKSPACE_DIR/TOOLS.md"
        echo "   ✅ TOOLS.md"
    fi
else
    echo "⚠️  Examples directory not found at $EXAMPLES_DIR"
    echo "   You'll need to create SOUL.md, USER.md, AGENTS.md manually"
fi

echo ""

# Copy scripts
if [ -d "$SCRIPT_DIR" ]; then
    echo "🔧 Copying utility scripts..."
    
    if [ -f "$SCRIPT_DIR/weekly-audit.sh" ]; then
        cp "$SCRIPT_DIR/weekly-audit.sh" "$WORKSPACE_DIR/50_tools/scripts/"
        chmod +x "$WORKSPACE_DIR/50_tools/scripts/weekly-audit.sh"
        echo "   ✅ weekly-audit.sh"
    fi
    
    if [ -f "$SCRIPT_DIR/qmd-update.sh" ]; then
        cp "$SCRIPT_DIR/qmd-update.sh" "$WORKSPACE_DIR/50_tools/scripts/"
        chmod +x "$WORKSPACE_DIR/50_tools/scripts/qmd-update.sh"
        echo "   ✅ qmd-update.sh"
    fi
fi

echo ""

# Create .gitignore
cat > "$WORKSPACE_DIR/.gitignore" << 'EOF'
# Credentials and sensitive files
.env
*.env
.token
*.key
*.pem
credentials.json
token.json

# OS files
.DS_Store
Thumbs.db

# Backup files
*.bak
*.backup
*.swp
*.swo
*~

# Node modules (if using any node tools)
node_modules/

# QMD cache (large, can be rebuilt)
# Uncomment if you don't want to commit QMD index:
# .cache/qmd/

# Temporary files
tmp/
temp/
*.tmp
EOF

echo "✅ .gitignore created"
echo ""

# Initialize git
echo "🔧 Initializing git repository..."
cd "$WORKSPACE_DIR"
git init

# Create initial commit if files exist
if [ -f "$WORKSPACE_DIR/SOUL.md" ]; then
    git add .
    git commit -m "Initial OpenClaw workspace setup" || echo "⚠️  Git commit skipped (possibly empty)"
fi

echo "✅ Git repository initialized"
echo ""

# Summary
echo "═══════════════════════════════════════════════════════════════"
echo "  ✅ OpenClaw Workspace Initialized!"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "Next steps:"
echo ""
echo "1. 🔧 Edit your identity files:"
echo "   - $WORKSPACE_DIR/SOUL.md      (Who you are)"
echo "   - $WORKSPACE_DIR/USER.md      (Who your human is)"
echo ""
echo "2. 🔐 Review security settings:"
echo "   - $WORKSPACE_DIR/SECURITY.md"
echo ""
echo "3. 📇 Add your contacts:"
echo "   - $WORKSPACE_DIR/CONFIG.md"
echo ""
echo "4. 🔍 Set up QMD (semantic search):"
echo "   curl -fsSL https://qmd.dev/install.sh | bash"
echo "   cd $WORKSPACE_DIR"
echo "   qmd init"
echo "   qmd collection add $WORKSPACE_DIR --name workspace --mask '**/*.md'"
echo "   qmd update"
echo ""
echo "5. 🚀 Start OpenClaw:"
echo "   openclaw start"
echo ""
echo "📖 Documentation: https://docs.openclaw.ai"
echo "═══════════════════════════════════════════════════════════════"
