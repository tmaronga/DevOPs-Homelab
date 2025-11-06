#!/bin/bash
# System Information Script
# Author: Tendayi Maronga
# Purpose: Display basic system information

echo "=================================="
echo "   SYSTEM INFORMATION"
echo "=================================="
echo ""

echo "Hostname: $(hostname)"
echo "OS: $(lsb_release -d | cut -f2)"
echo "Kernel: $(uname -r)"
echo "Uptime: $(uptime -p)"
echo ""

echo "--- CPU Information ---"
echo "CPU: $(lscpu | grep 'Model name' | cut -d':' -f2 | xargs)"
echo "Cores: $(nproc)"
echo ""

echo "--- Memory Information ---"
free -h | awk 'NR==2{printf "Total: %s | Used: %s | Free: %s\n", $2, $3, $4}'
echo ""

echo "--- Disk Information ---"
df -h / | awk 'NR==2{printf "Total: %s | Used: %s | Available: %s | Use: %s\n", $2, $3, $4, $5}'
echo ""

echo "=================================="
echo "Script completed successfully!"
echo "=================================="
