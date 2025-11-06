# Log Analyzer Script
# Analyzes log files for errors, warnings, and statistics

echo "========================================"
echo "        LOG FILE ANALYZER"
echo "========================================"
echo ""

# Check if log file provided
if [ $# -eq 0 ]; then
    echo "❌ Usage: $0 <logfile>"
    echo "Example: $0 /var/log/syslog"
    exit 1
fi

LOGFILE=$1

# Check if file exists
if [ ! -f "$LOGFILE" ]; then
    echo "❌ Error: File '$LOGFILE' not found!"
    exit 1
fi

echo "📁 Analyzing: $LOGFILE"
echo "📅 Analysis Date: $(date)"
echo ""

# Basic statistics
echo "📊 BASIC STATISTICS"
echo "===================="
TOTAL_LINES=$(wc -l < "$LOGFILE")
echo "Total lines: $TOTAL_LINES"
echo ""

# Error analysis
echo "🔴 ERROR ANALYSIS"
echo "=================="
ERROR_COUNT=$(grep -ic "error" "$LOGFILE")
echo "Total errors: $ERROR_COUNT"

if [ $ERROR_COUNT -gt 0 ]; then
    echo ""
    echo "Last 5 errors:"
    grep -i "error" "$LOGFILE" | tail -5
fi
echo ""

# Warning analysis
echo "⚠️  WARNING ANALYSIS"
echo "===================="
WARNING_COUNT=$(grep -ic "warning" "$LOGFILE")
echo "Total warnings: $WARNING_COUNT"

if [ $WARNING_COUNT -gt 0 ]; then
    echo ""
    echo "Last 5 warnings:"
    grep -i "warning" "$LOGFILE" | tail -5
fi
echo ""

# Critical analysis
echo "🚨 CRITICAL ISSUES"
echo "=================="
CRITICAL_COUNT=$(grep -ic "critical\|fatal\|panic" "$LOGFILE")
echo "Total critical issues: $CRITICAL_COUNT"

if [ $CRITICAL_COUNT -gt 0 ]; then
    echo ""
    echo "Critical entries:"
    grep -iE "critical|fatal|panic" "$LOGFILE" | tail -5
fi
echo ""

# Summary
echo "📋 SUMMARY"
echo "=========="
echo "Total lines analyzed: $TOTAL_LINES"
echo "Errors found: $ERROR_COUNT"
echo "Warnings found: $WARNING_COUNT"
echo "Critical issues: $CRITICAL_COUNT"

# Calculate percentages if possible
if [ $TOTAL_LINES -gt 0 ]; then
    ERROR_PERCENT=$(awk "BEGIN {printf \"%.2f\", ($ERROR_COUNT/$TOTAL_LINES)*100}")
    echo "Error rate: $ERROR_PERCENT%"
fi

echo ""
echo "========================================"
echo "✅ Analysis complete!"
echo "========================================"
