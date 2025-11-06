#!/bin/bash
# Pre-Day 3 Checklist - Ensure everything is ready for Docker

echo "========================================"
echo "   PRE-DAY 3 READINESS CHECK"
echo "========================================"
echo ""

cd ~/devops-practice

echo "✓ Day 1 & 2 Completion Check"
echo "=============================="
echo ""

# Check scripts
echo "Scripts Created:"
[ -f scripts/system-check.sh ] && echo "  ✅ system-check.sh" || echo "  ❌ system-check.sh missing"
[ -f scripts/log-analyzer.sh ] && echo "  ✅ log-analyzer.sh" || echo "  ❌ log-analyzer.sh missing"
[ -f scripts/backup-script.sh ] && echo "  ✅ backup-script.sh" || echo "  ❌ backup-script.sh missing"
echo ""

# Check logs
echo "Learning Logs:"
[ -f logs/command-practice.log ] && echo "  ✅ command-practice.log" || echo "  ❌ command-practice.log missing"
[ -f logs/day2-process-management.log ] && echo "  ✅ day2-process-management.log" || echo "  ❌ day2-process-management.log missing"
[ -f logs/day2-text-processing.log ] && echo "  ✅ day2-text-processing.log" || echo "  ❌ day2-text-processing.log missing"
echo ""

# Check documentation
echo "Documentation:"
[ -f README.md ] && echo "  ✅ README.md" || echo "  ❌ README.md missing"
[ -f QUICK-REFERENCE.md ] && echo "  ✅ QUICK-REFERENCE.md" || echo "  ❌ QUICK-REFERENCE.md missing"
[ -f DAILY-LOG.md ] && echo "  ✅ DAILY-LOG.md" || echo "  ❌ DAILY-LOG.md missing"
echo ""

# Check screenshots
echo "Screenshots:"
DAY1_SCREENSHOTS=$(find screenshots/day1/ -name '*.png' 2>/dev/null | wc -l)
DAY2_SCREENSHOTS=$(find screenshots/day2/ -name '*.png' 2>/dev/null | wc -l)
echo "  Day 1: $DAY1_SCREENSHOTS screenshots"
echo "  Day 2: $DAY2_SCREENSHOTS screenshots"
if [ $DAY1_SCREENSHOTS -ge 4 ] && [ $DAY2_SCREENSHOTS -ge 4 ]; then
    echo "  ✅ Sufficient screenshots"
else
    echo "  ⚠️  Need more screenshots"
fi
echo ""

# Check Git status
echo "Git Repository Status:"
if [ -z "$(git status --porcelain)" ]; then
    echo "  ✅ All changes committed"
else
    echo "  ⚠️  Uncommitted changes detected"
    echo ""
    git status --short
fi
echo ""

# System readiness
echo "System Requirements for Docker:"
FREE_DISK=$(df -h ~ | tail -1 | awk '{print $4}')
FREE_RAM=$(free -h | grep Mem | awk '{print $7}')
echo "  Available disk: $FREE_DISK"
echo "  Available RAM: $FREE_RAM"
echo ""

# Skill checklist
echo "Skills Acquired (Day 1-2):"
SKILLS=(
    "Linux navigation (cd, ls, pwd)"
    "File operations (cat, cp, mv, rm)"
    "Permissions (chmod, chown)"
    "Process management (ps, top, htop, kill)"
    "Text processing (grep, sed, awk)"
    "Command piping (|)"
    "Git workflow (add, commit, push)"
    "Shell scripting basics"
    "System monitoring"
    "Service management (systemctl)"
)

for skill in "${SKILLS[@]}"; do
    echo "  ✅ $skill"
done
echo ""

# Final recommendation
echo "========================================"
echo "READINESS ASSESSMENT"
echo "========================================"

UNCOMMITTED=$(git status --porcelain | wc -l)
if [ $UNCOMMITTED -eq 0 ] && [ $DAY1_SCREENSHOTS -ge 3 ] && [ $DAY2_SCREENSHOTS -ge 3 ]; then
    echo "✅ READY FOR DAY 3: DOCKER!"
    echo ""
    echo "Tomorrow you'll learn:"
    echo "  🐳 Docker installation"
    echo "  📦 Container basics"
    echo "  🏗️  Building images"
    echo "  🚀 Running applications in containers"
else
    echo "⚠️  COMPLETE THESE TASKS FIRST:"
    [ $UNCOMMITTED -gt 0 ] && echo "  - Commit and push all changes"
    [ $DAY1_SCREENSHOTS -lt 3 ] && echo "  - Take Day 1 screenshots"
    [ $DAY2_SCREENSHOTS -lt 3 ] && echo "  - Take Day 2 screenshots"
fi

echo ""
echo "========================================"
echo "🔗 Repository: https://github.com/tmaronga/DevOPs-Homelab"
echo "========================================"
