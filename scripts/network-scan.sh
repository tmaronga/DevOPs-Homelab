#!/bin/bash
# network-scan.sh - Quick network discovery and port scanning

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo -e "\n${BLUE}=== $1 ===${NC}"
}

print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

# Get local subnet
LOCAL_SUBNET=$(ip route | grep -E "192\.168\.[0-9]+\.0" | awk '{print $1}' | head -1)

if [ -z "$LOCAL_SUBNET" ]; then
    echo "Could not determine local subnet"
    exit 1
fi

print_header "NETWORK DISCOVERY"
echo "Scanning subnet: $LOCAL_SUBNET"

if ! command -v nmap &> /dev/null; then
    echo "Installing nmap..."
    sudo apt update && sudo apt install -y nmap
fi

# Host discovery
echo
print_status "Active hosts:"
nmap -sn "$LOCAL_SUBNET" | grep -E "Nmap scan report" | while read -r line; do
    echo "  $line"
done

# Port scan on discovered hosts
echo
print_status "Port scanning active hosts..."
for ip in $(nmap -sn "$LOCAL_SUBNET" | grep -oE "192\.168\.[0-9]+\.[0-9]+" | head -5); do
    echo
    echo "Scanning $ip:"
    nmap -p 22,80,443,8080,6443 "$ip" 2>/dev/null | grep -E "^[0-9]+" | head -10
done
