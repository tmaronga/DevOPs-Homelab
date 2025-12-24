#!/bin/bash
# ========================================
# Phase 1 Troubleshooting Reference Script
# DevOps Homelab - CZ → ZM
# ========================================

# -------------------------------
# SYSTEM CHECKS
# -------------------------------
echo "📌 System Basics"
echo "OS: $(lsb_release -d | cut -f2)"
echo "Kernel: $(uname -r)"
echo "Disk Usage:"
df -h | grep -v tmpfs
echo "Memory Usage:"
free -h

# -------------------------------
# CORE TOOLS
# -------------------------------
echo "📌 Core Tools"
for tool in docker git kubectl helm terraform az; do
    if command -v $tool &>/dev/null; then
        echo "✅ $tool installed: $($tool version 2>/dev/null | head -n1)"
    else
        echo "❌ $tool NOT installed"
    fi
done

# -------------------------------
# K3S CLUSTER
# -------------------------------
echo "📌 K3s Cluster Status"
sudo systemctl status k3s --no-pager | head -n10
echo "Kubectl Nodes:"
kubectl get nodes -o wide
echo "All Pods:"
kubectl get pods -A

# -------------------------------
# DOCKER
# -------------------------------
echo "📌 Docker Status"
sudo systemctl status docker --no-pager | head -n10
docker ps

# -------------------------------
# CI/CD
# -------------------------------
echo "📌 Jenkins (Docker) Status"
docker ps | grep jenkins || echo "⚠️ Jenkins container not running"

echo "📌 ArgoCD Status"
kubectl get pods -n argocd

# -------------------------------
# MONITORING
# -------------------------------
echo "📌 Monitoring Stack Status"
kubectl get pods -n monitoring

# -------------------------------
# AZURE
# -------------------------------
echo "📌 Azure CLI Status"
az account show 2>/dev/null || echo "⚠️ Azure CLI not logged in"

# -------------------------------
# GIT
# -------------------------------
echo "📌 Git Status"
if [ -d ~/devops-practice/.git ]; then
    cd ~/devops-practice && git status
else
    echo "⚠️ Not inside Git repository"
fi

# -------------------------------
# NETWORK
# -------------------------------
echo "📌 Network Check"
ping -c 2 8.8.8.8
nslookup google.com

# -------------------------------
# LOGS (Quick Access)
# -------------------------------
echo "📌 Quick Log Check (Press Ctrl+C to exit)"
echo "K3s Logs:"
sudo journalctl -u k3s -n 50 --no-pager
echo "Docker Logs:"
sudo journalctl -u docker -n 50 --no-pager

echo "✅ Phase 1 Troubleshoot script completed!"
