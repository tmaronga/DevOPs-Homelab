#!/bin/bash
# Track Bandit Progress

BANDIT_DIR="$HOME/devops-practice/bandit"
LOG_FILE="$BANDIT_DIR/notes/bandit-practice-log.md"

echo "========================================"
echo "   BANDIT PROGRESS TRACKER"
echo "========================================"
echo ""

# Count completed levels
if [ -f "$LOG_FILE" ]; then
    COMPLETED=$(grep -c "### Password for Next Level" "$LOG_FILE" 2>/dev/null || echo "0")
    echo "📊 Levels Completed: $COMPLETED/34"
else
    COMPLETED=0
    echo "📊 Levels Completed: 0/34"
    echo "⚠️  No practice log found yet!"
fi

echo ""

# Calculate progress percentage
PERCENT=$((COMPLETED * 100 / 34))
echo "📈 Progress: $PERCENT%"
echo ""

# Show progress bar
FILLED=$((PERCENT / 2))
BAR=""
for ((i=0; i<50; i++)); do
    if [ $i -lt $FILLED ]; then
        BAR="${BAR}█"
    else
        BAR="${BAR}░"
    fi
done
echo "[$BAR] $PERCENT%"
echo ""

# Recent activity
if [ -f "$LOG_FILE" ]; then
    LAST_DATE=$(grep "^**Date:**" "$LOG_FILE" | tail -1 | cut -d' ' -f2-)
    echo "📅 Last Practice: $LAST_DATE"
fi

echo ""
echo "🎯 Quick Actions:"
echo "  1. Start practice session: ./bandit-session.sh"
echo "  2. Update log: nano $LOG_FILE"
echo "  3. View reference: cat $BANDIT_DIR/bandit-commands-reference.md"
echo ""
echo "========================================"
