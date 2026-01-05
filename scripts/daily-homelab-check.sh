#!/bin/bash
# Daily Homelab Health Check
# Run this every morning before starting work

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "========================================"
echo "  🏠 DAILY HOMELAB HEALTH CHECK"
echo "  $(date '+%A, %B %d, %Y - %H:%M')"
echo "========================================"
echo ""

# Function to print section headers
section() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

# Function for status checks
check_status() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ $1${NC}"
        return 0
    else
        echo -e "${RED}❌ $1${NC}"
        return 1
    fi
}

# ============================================
# 1. SYSTEM RESOURCES
# ============================================
section "1️⃣  SYSTEM RESOURCES"

echo "💻 Hostname: $(hostname)"
echo "🕐 Uptime: $(uptime -p)"
echo ""

echo "💾 Memory Usage:"
free -h | grep Mem | awk '{
    used=$3; 
    total=$2; 
    percent=($3/$2)*100;
    printf "  Used: %s / %s (%.1f%%)\n", used, total, percent
}'

MEMORY_PERCENT=$(free | grep Mem | awk '{print ($3/$2) * 100}')
if (( $(echo "$MEMORY_PERCENT > 80" | bc -l) )); then
    echo -e "${RED}⚠️  HIGH MEMORY USAGE!${NC}"
fi
echo ""

echo "💿 Disk Usage:"
df -h / | tail -1 | awk '{
    print "  Used: " $3 " / " $2 " (" $5 ")"
}'

DISK_PERCENT=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
if [ "$DISK_PERCENT" -gt 80 ]; then
    echo -e "${RED}⚠️  LOW DISK SPACE!${NC}"
fi
echo ""

echo "🔥 CPU Load Average:"
uptime | awk -F'load average:' '{print "  " $2}'

# ============================================
# 2. KUBERNETES CLUSTER STATUS
# ============================================
section "2️⃣  KUBERNETES CLUSTER"

echo "🎯 Cluster Info:"
kubectl cluster-info 2>/dev/null | head -2
echo ""

echo "📊 Node Status:"
kubectl get nodes -o wide 2>/dev/null
NODE_STATUS=$?
echo ""

if [ $NODE_STATUS -ne 0 ]; then
    echo -e "${RED}❌ Cannot connect to Kubernetes cluster!${NC}"
    echo "Run: sudo systemctl status k3s"
else
    echo -e "${GREEN}✅ Cluster accessible${NC}"
fi
echo ""

echo "🏃 Running Pods by Namespace:"
kubectl get pods -A --field-selector=status.phase=Running 2>/dev/null | awk '
    NR>1 {count[$1]++} 
    END {for (ns in count) printf "  %-20s %d pods\n", ns, count[ns]}
' | sort
echo ""

echo "🚨 Pod Issues (Not Running/Ready):"
PROBLEM_PODS=$(kubectl get pods -A 2>/dev/null | grep -v "Running\|Completed" | grep -v "NAMESPACE" | wc -l)
if [ "$PROBLEM_PODS" -gt 0 ]; then
    echo -e "${RED}⚠️  Found $PROBLEM_PODS pods with issues:${NC}"
    kubectl get pods -A 2>/dev/null | grep -v "Running\|Completed" | grep -v "NAMESPACE"
else
    echo -e "${GREEN}✅ All pods healthy${NC}"
fi

# ============================================
# 3. CRITICAL SERVICES STATUS
# ============================================
section "3️⃣  CRITICAL SERVICES"

# K3s Service
echo -n "K3s Service: "
systemctl is-active --quiet k3s 2>/dev/null
check_status "Running" || echo "  Fix: sudo systemctl start k3s"

# Docker Service
echo -n "Docker Service: "
systemctl is-active --quiet docker 2>/dev/null
check_status "Running" || echo "  Fix: sudo systemctl start docker"

# CoreDNS
echo -n "CoreDNS: "
kubectl get pods -n kube-system -l k8s-app=kube-dns 2>/dev/null | grep -q "Running"
check_status "Running" || echo "  Check: kubectl describe pod -n kube-system -l k8s-app=kube-dns"

# Traefik (Ingress)
echo -n "Traefik Ingress: "
kubectl get pods -n kube-system -l app.kubernetes.io/name=traefik 2>/dev/null | grep -q "Running"
check_status "Running" || echo "  Check: kubectl get pods -n kube-system -l app.kubernetes.io/name=traefik"

# Metrics Server
echo -n "Metrics Server: "
kubectl get pods -n kube-system -l k8s-app=metrics-server 2>/dev/null | grep -q "Running"
check_status "Running" || echo "  Check: kubectl top nodes"

echo ""

# ============================================
# 4. APPLICATION WORKLOADS
# ============================================
section "4️⃣  APPLICATION WORKLOADS"

# ArgoCD
echo -n "ArgoCD: "
ARGOCD_PODS=$(kubectl get pods -n argocd 2>/dev/null | grep -c "Running")
ARGOCD_TOTAL=$(kubectl get pods -n argocd 2>/dev/null | grep -v "NAME" | wc -l)
if [ "$ARGOCD_PODS" -eq "$ARGOCD_TOTAL" ] && [ "$ARGOCD_TOTAL" -gt 0 ]; then
    echo -e "${GREEN}✅ $ARGOCD_PODS/$ARGOCD_TOTAL pods running${NC}"
else
    echo -e "${YELLOW}⚠️  $ARGOCD_PODS/$ARGOCD_TOTAL pods running${NC}"
fi

# Prometheus
echo -n "Prometheus: "
kubectl get pods -n monitoring -l app.kubernetes.io/name=prometheus 2>/dev/null | grep -q "Running"
check_status "Running"

# Grafana
echo -n "Grafana: "
kubectl get pods -n monitoring -l app.kubernetes.io/name=grafana 2>/dev/null | grep -q "Running"
check_status "Running"

# Jenkins (Docker)
echo -n "Jenkins: "
docker ps 2>/dev/null | grep -q jenkins
check_status "Running (Docker)"

# ============================================
# 5. RESOURCE CONSUMPTION
# ============================================
section "5️⃣  RESOURCE CONSUMPTION"

echo "📈 Top 5 Pods by Memory:"
kubectl top pods -A 2>/dev/null | sort -k4 -rh | head -6 | tail -5 | awk '{printf "  %-30s %-20s %s\n", $2, $1, $4}'
echo ""

echo "📈 Top 5 Pods by CPU:"
kubectl top pods -A 2>/dev/null | sort -k3 -rh | head -6 | tail -5 | awk '{printf "  %-30s %-20s %s\n", $2, $1, $3}'

# ============================================
# 6. RECENT EVENTS & LOGS
# ============================================
section "6️⃣  RECENT EVENTS (Last 10)"

kubectl get events -A --sort-by='.lastTimestamp' 2>/dev/null | tail -10

# ============================================
# 7. NETWORK CONNECTIVITY
# ============================================
section "7️⃣  NETWORK CONNECTIVITY"

echo -n "Internet: "
ping -c 1 -W 2 8.8.8.8 &>/dev/null
check_status "Reachable"

echo -n "DNS Resolution: "
ping -c 1 -W 2 google.com &>/dev/null
check_status "Working"

echo ""
echo "Active Network Interfaces:"
ip -br addr | grep -v "lo" | awk '{printf "  %-15s %s\n", $1, $3}'

# ============================================
# 8. DOCKER CONTAINERS
# ============================================
section "8️⃣  DOCKER CONTAINERS"

RUNNING=$(docker ps -q 2>/dev/null | wc -l)
TOTAL=$(docker ps -aq 2>/dev/null | wc -l)
echo "Running Containers: $RUNNING/$TOTAL"
echo ""

if [ "$RUNNING" -gt 0 ]; then
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null
fi

# ============================================
# 9. PERSISTENT VOLUMES
# ============================================
section "9️⃣  STORAGE & VOLUMES"

echo "Persistent Volumes:"
kubectl get pv 2>/dev/null | grep -v "NAME" | wc -l | xargs echo "  Total PVs:"

echo ""
echo "Persistent Volume Claims:"
kubectl get pvc -A 2>/dev/null | tail -n +2 | awk '{
    if ($4 == "Bound") 
        printf "  %-20s %-30s %s\n", $1, $2, "✅ Bound"
    else 
        printf "  %-20s %-30s %s\n", $1, $2, "❌ " $4
}'

# ============================================
# 10. SECURITY & UPDATES
# ============================================
section "🔟  SECURITY CHECKS"

echo -n "Certificate Expiry (ArgoCD): "
if kubectl get secret -n argocd argocd-server-tls &>/dev/null; then
    CERT_DATA=$(kubectl get secret -n argocd argocd-server-tls -o jsonpath='{.data.tls\.crt}' | base64 -d)
    EXPIRY=$(echo "$CERT_DATA" | openssl x509 -noout -enddate 2>/dev/null | cut -d= -f2)
    if [ -n "$EXPIRY" ]; then
        echo "$EXPIRY"
    else
        echo "Using default cert"
    fi
else
    echo "Using default cert"
fi

echo ""
echo "System Updates Available:"
if command -v apt &>/dev/null; then
    UPDATES=$(apt list --upgradable 2>/dev/null | grep -c upgradable)
    if [ "$UPDATES" -gt 0 ]; then
        echo -e "  ${YELLOW}⚠️  $UPDATES updates available${NC}"
        echo "  Run: sudo apt update && sudo apt upgrade"
    else
        echo -e "  ${GREEN}✅ System up to date${NC}"
    fi
fi

# ============================================
# 11. GIT REPOSITORY STATUS
# ============================================
section "1️⃣1️⃣  GIT REPOSITORY"

if [ -d ~/devops-practice/.git ]; then
    cd ~/devops-practice
    
    echo "Repository: $(pwd)"
    echo "Branch: $(git branch --show-current 2>/dev/null)"
    echo ""
    
    UNCOMMITTED=$(git status --porcelain 2>/dev/null | wc -l)
    if [ "$UNCOMMITTED" -gt 0 ]; then
        echo -e "${YELLOW}⚠️  $UNCOMMITTED uncommitted changes${NC}"
        echo ""
        git status --short
    else
        echo -e "${GREEN}✅ Working tree clean${NC}"
    fi
    
    echo ""
    echo "Last commit:"
    git log -1 --oneline 2>/dev/null
else
    echo -e "${RED}❌ Git repository not found${NC}"
fi

# ============================================
# SUMMARY
# ============================================
section "📊 HEALTH SUMMARY"

HEALTH_SCORE=0
TOTAL_CHECKS=10

# Calculate health score
systemctl is-active --quiet k3s && ((HEALTH_SCORE++))
systemctl is-active --quiet docker && ((HEALTH_SCORE++))
kubectl get nodes &>/dev/null && ((HEALTH_SCORE++))
[ "$PROBLEM_PODS" -eq 0 ] && ((HEALTH_SCORE++))
[ "$ARGOCD_PODS" -eq "$ARGOCD_TOTAL" ] && ((HEALTH_SCORE++))
kubectl get pods -n monitoring -l app.kubernetes.io/name=prometheus 2>/dev/null | grep -q "Running" && ((HEALTH_SCORE++))
kubectl get pods -n monitoring -l app.kubernetes.io/name=grafana 2>/dev/null | grep -q "Running" && ((HEALTH_SCORE++))
docker ps | grep -q jenkins && ((HEALTH_SCORE++))
ping -c 1 google.com &>/dev/null && ((HEALTH_SCORE++))
[ "$UNCOMMITTED" -eq 0 ] && ((HEALTH_SCORE++))

HEALTH_PERCENT=$((HEALTH_SCORE * 100 / TOTAL_CHECKS))

echo "Overall Health Score: $HEALTH_SCORE/$TOTAL_CHECKS ($HEALTH_PERCENT%)"
echo ""

if [ "$HEALTH_PERCENT" -ge 90 ]; then
    echo -e "${GREEN}🎉 EXCELLENT - Homelab is healthy!${NC}"
elif [ "$HEALTH_PERCENT" -ge 70 ]; then
    echo -e "${YELLOW}⚠️  GOOD - Minor issues detected${NC}"
else
    echo -e "${RED}❌ ATTENTION NEEDED - Multiple issues detected${NC}"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Quick Actions:"
echo "  • View pod logs: kubectl logs -n <namespace> <pod-name>"
echo "  • Restart pod: kubectl delete pod -n <namespace> <pod-name>"
echo "  • Port forward: kubectl port-forward -n <namespace> svc/<service> <port>:<port>"
echo "  • Check events: kubectl describe pod -n <namespace> <pod-name>"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Daily check completed at $(date '+%H:%M:%S')"
echo "========================================"
