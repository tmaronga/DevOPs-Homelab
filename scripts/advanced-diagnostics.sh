#!/bin/bash
# advanced-diagnostics.sh - Comprehensive homelab health check

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

print_header() { echo -e "\n${BLUE}=== $1 ===${NC}"; }
print_status() { echo -e "${GREEN}✓${NC} $1"; }
print_info() { echo -e "${CYAN}ℹ${NC} $1"; }

echo -e "${CYAN}╔═══════════════════════════════╗${NC}"
echo -e "${CYAN}║   DevOps Homelab Diagnostics  ║${NC}"
echo -e "${CYAN}╚═══════════════════════════════╝${NC}"
echo "Timestamp: $(date)"
echo "Hostname: $(hostname)"
echo

# System Information
print_header "SYSTEM STATUS"
echo "OS: $(lsb_release -d | cut -f2)"
echo "Uptime: $(uptime -p)"
echo "Memory: $(free -h | awk '/^Mem:/ {print $3 "/" $2}')"
echo "Disk: $(df -h / | awk 'NR==2 {print $3 "/" $2 " (" $5 " used)"}')"

# Network Discovery
print_header "NETWORK DISCOVERY"
LOCAL_IP=$(ip route get 1 | awk '{print $7; exit}')
print_info "Local IP: $LOCAL_IP"

if command -v nmap &> /dev/null; then
    LOCAL_SUBNET=$(ip route | grep -E "192\.168\.[0-9]+\.0" | awk '{print $1}' | head -1)
    print_info "Scanning $LOCAL_SUBNET"
    nmap -sn "$LOCAL_SUBNET" 2>/dev/null | grep "Nmap scan report"
else
    print_info "Install nmap for network scanning: sudo apt install nmap"
fi

# K3s Status
print_header "KUBERNETES CLUSTER"
if command -v kubectl &> /dev/null; then
    if kubectl cluster-info &> /dev/null; then
        print_status "Cluster connectivity: OK"
        kubectl get nodes --no-headers | while read line; do
            echo "  Node: $line"
        done
        
        running_pods=$(kubectl get pods --all-namespaces --no-headers | grep Running | wc -l)
        total_pods=$(kubectl get pods --all-namespaces --no-headers | wc -l)
        print_info "Pods: $running_pods/$total_pods running"
        
        if kubectl top nodes &> /dev/null; then
            print_info "Resource usage:"
            kubectl top nodes | tail -n +2
        fi
    else
        print_info "Cluster not accessible"
    fi
else
    print_info "kubectl not found"
fi

# Docker Status
print_header "DOCKER STATUS"
if command -v docker &> /dev/null && docker info &> /dev/null; then
    print_status "Docker running"
    container_count=$(docker ps -q | wc -l)
    print_info "Running containers: $container_count"
else
    print_info "Docker not running or not accessible"
fi

print_header "SUMMARY"
print_status "Homelab diagnostics completed"
print_info "For issues, check: kubectl logs -n kube-system [pod-name]"
