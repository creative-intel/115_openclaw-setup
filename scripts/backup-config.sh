#!/usr/bin/env bash
# backup-config.sh - Backup OpenClaw config with timestamp
# Run before any major config changes or weekly via cron

set -euo pipefail

CONFIG_FILE="$HOME/.openclaw/openclaw.json"
BACKUP_DIR="$HOME/.openclaw/backups"
TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
BACKUP_FILE="$BACKUP_DIR/openclaw.json.$TIMESTAMP.bak"

# Create backup directory if needed
mkdir -p "$BACKUP_DIR"

# Check if config exists
if [ ! -f "$CONFIG_FILE" ]; then
  echo "ERROR: Config file not found: $CONFIG_FILE"
  exit 1
fi

# Create backup
cp "$CONFIG_FILE" "$BACKUP_FILE"
echo "✅ Backup created: $BACKUP_FILE"

# Prune old backups (keep last 10)
cd "$BACKUP_DIR"
ls -t openclaw.json.*.bak 2>/dev/null | tail -n +11 | xargs -r rm -f
BACKUP_COUNT=$(ls -1 openclaw.json.*.bak 2>/dev/null | wc -l | tr -d ' ')
echo "📁 Total backups: $BACKUP_COUNT (keeping last 10)"

# Show recent backups
echo ""
echo "Recent backups:"
ls -lt openclaw.json.*.bak 2>/dev/null | head -5
