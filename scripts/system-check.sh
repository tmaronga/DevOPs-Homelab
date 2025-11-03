#!/bin/bash
# System Health Check Script
# Created: Day 1 of DevOps Journey

echo "=================================="
echo "   SYSTEM HEALTH CHECK"
echo "=================================="
echo ""
echo "📅 Date and Time:"
date
echo ""

echo "💻 System Information:"
echo "  Hostname: $(hostname)"
echo "  OS: $(lsb_release -d | cut -f2)"
echo "  Kernel: $(uname -r)"
echo ""

echo "🧠 CPU Information:"
echo "  Model: $(lscpu | grep 'Model name' | cut -d':' -f2 | xargs)"
echo "  Cores: $(nproc)"
echo ""

echo "💾 Memory Usage:"
free -h | grep Mem | awk '{print "  Total: " $2 "\n  Used: " $3 "\n  Free: " $4 "\n  Available: " $7}'
echo ""

echo "💿 Disk Usage:"
df -h / | tail -1 | awk '{print "  Total: " $2 "\n  Used: " $3 " (" $5 ")\n  Available: " $4}'
echo ""

echo "🌐 Network Information:"
echo "  IP Address: $(hostname -I | awk '{print $1}')"
echo "  Gateway: $(ip route | grep default | awk '{print $3}')"
echo ""

echo "📊 Top 5 Processes by Memory:"
ps aux --sort=-%mem | head -6 | tail -5 | awk '{printf "  %-20s %s%%\n", $11, $4}'
echo ""

echo "🔌 Network Connectivity:"
if ping -c 1 google.com &> /dev/null; then
    echo "  ✅ Internet connection: OK"
else
    echo "  ❌ Internet connection: FAILED"
fi
echo ""

echo "=================================="
echo "Health check completed!"
echo "=================================="
