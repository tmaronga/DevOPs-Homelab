#!/bin/bash
# ========================================
# PHASE 1 HEALTH CHECK
# DevOps Homelab - CZ → ZM
# ========================================

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Counters
PASS=0
WARN=0
FAIL=0

increment() {
    case $1 in
        pass) ((PASS++)) ;;
        warn) ((WARN++)) ;;
        fail) ((FAIL++)) ;;
    esac
}

echo "========================================"
echo " PHASE 1 HEALTH CHECK"
echo " DevOps Homelab - CZ → ZM"
echo "========================================"
echo "📅 Date: $(date +"%a %b %d %I:%M:%S %p %Z")"
echo "🖥️  Host: $(hostname)"
echo ""

# -------------------------------
# 1️⃣ SYSTEM BASICS
# -------------------------------
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "1️⃣ SYSTEM BASICS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
OS_NAME=$(lsb_release -d | awk -F'\t' '{print $2}')
KERNEL=$(uname -r)
echo "OS: $OS_NAME"
echo "Kernel: $KERNEL"

disk_used=$(df -h / | awk 'NR==2 {print $3 " / " $2 " (" $5 ")"}')
echo -e "\nDisk:\n  Used: $disk_used"

mem_used=$(free -h | awk 'NR==2 {print $3 " / " $2}')
echo -e "\nMemory:\n  Used: $mem_used\n"

increment pass

# -------------------------------
# 2️⃣ CORE TOOLS
# -------------------------------
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "2️⃣ CORE TOOLS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

check_cmd() {
    local cmd=$1
    if command -v $cmd &>/dev/null; then
        echo -e "✅ $cmd installed"
        increment pass
    else
        echo -e "${RED}❌ $cmd not installed${NC}"
        increment fail
    fi
}

for tool in docker git kubectl helm terraform az; do
    check_cmd $tool
done
echo ""

# -------------------------------
# 3️⃣ K3S CLUSTER
# -------------------------------
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "3️⃣ K3S CLUSTER"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if systemctl is-active --quiet k3s; then
    echo -e "✅ k3s service running"
    increment pass
else
    echo -e "${RED}❌ k3s service not running${NC}"
    increment fail
fi

if kubectl cluster-info &>/dev/null; then
    echo -e "✅ kubectl access OK"
    increment pass
else
    echo -e "${RED}❌ kubectl cannot access cluster${NC}"
    increment fail
fi

kubectl get nodes
kubectl get pods --all-namespaces
echo ""

# -------------------------------
# 4️⃣ DOCKER
# -------------------------------
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "4️⃣ DOCKER"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if systemctl is-active --quiet docker; then
    echo -e "✅ Docker service running"
    running=$(docker ps -q | wc -l)
    echo "Running containers: $running"
    increment pass
else
    echo -e "${RED}❌ Docker service not running${NC}"
    increment fail
fi
echo ""

# -------------------------------
# 5️⃣ CI/CD
# -------------------------------
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "5️⃣ CI/CD"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Argo CD
if kubectl get namespace argocd &>/dev/null; then
    READY=$(kubectl get pods -n argocd --no-headers | awk -F'/' '{split($1,a,"/"); if(a[1]==a[2] && a[2]>0) print "✅"; else print "⚠️"}' | grep -c "✅")
    TOTAL=$(kubectl get pods -n argocd --no-headers | wc -l)
    if [ $READY -eq $TOTAL ]; then
        echo -e "✅ Argo CD healthy ($READY/$TOTAL)"
        increment pass
    else
        echo -e "${YELLOW}⚠️ Argo CD not fully ready ($READY/$TOTAL)${NC}"
        increment warn
    fi
else
    echo -e "${RED}❌ Argo CD namespace missing${NC}"
    increment fail
fi

# Jenkins
if docker ps --filter "name=jenkins" --format '{{.Names}}' | grep -q jenkins; then
    echo -e "✅ Jenkins running (Docker)"
    increment pass
else
    echo -e "${RED}❌ Jenkins not running${NC}"
    increment fail
fi
echo ""

# -------------------------------
# 6️⃣ MONITORING
# -------------------------------
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "6️⃣ MONITORING"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

check_monitoring_pod() {
    local pod_label=$1
    local ns=$2
    if kubectl get pods -n $ns -l "$pod_label" &>/dev/null; then
        READY=$(kubectl get pods -n $ns -l "$pod_label" --no-headers | awk -F'/' '{split($1,a,"/"); if(a[1]==a[2] && a[2]>0) print "✅"; else print "⚠️"}' | grep -c "✅")
        TOTAL=$(kubectl get pods -n $ns -l "$pod_label" --no-headers | wc -l)
        if [ $READY -eq $TOTAL ]; then
            echo -e "✅ $pod_label ready ($READY/$TOTAL)"
            increment pass
        else
            echo -e "${YELLOW}⚠️ $pod_label not fully ready ($READY/$TOTAL)${NC}"
            increment warn
        fi
    else
        echo -e "${RED}❌ $pod_label not found in $ns${NC}"
        increment fail
    fi
}

check_monitoring_pod "app.kubernetes.io/name=prometheus" monitoring
check_monitoring_pod "app.kubernetes.io/name=grafana" monitoring
echo ""

# -------------------------------
# 7️⃣ AZURE
# -------------------------------
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "7️⃣ AZURE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if az account show &>/dev/null; then
    echo -e "✅ Azure CLI authenticated"
    az account list --output table
    increment pass
else
    echo -e "${RED}❌ Azure CLI not authenticated${NC}"
    increment fail
fi
echo ""

# -------------------------------
# 8️⃣ GIT
# -------------------------------
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "8️⃣ GIT"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if git rev-parse --is-inside-work-tree &>/dev/null; then
    echo -e "✅ Inside Git repository"
    increment pass
else
    echo -e "❌ Not inside Git repository"
    increment warn
fi
echo ""

# -------------------------------
# 9️⃣ NETWORK
# -------------------------------
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "9️⃣ NETWORK"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if ping -c1 8.8.8.8 &>/dev/null; then
    echo -e "✅ Internet reachable"
    increment pass
else
    echo -e "${RED}❌ Internet unreachable${NC}"
    increment fail
fi

if nslookup google.com &>/dev/null; then
    echo -e "✅ DNS working"
    increment pass
else
    echo -e "${RED}❌ DNS not working${NC}"
    increment fail
fi
echo ""

# -------------------------------
# SUMMARY
# -------------------------------
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 SUMMARY"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "✅ PASS: $PASS"
echo -e "${YELLOW}⚠️ WARN: $WARN${NC}"
echo -e "${RED}❌ FAIL: $FAIL${NC}"
echo ""
echo "Health check completed: $(date +"%a %b %d %I:%M:%S %p %Z")"

