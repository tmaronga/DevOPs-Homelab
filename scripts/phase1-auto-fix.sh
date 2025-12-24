#!/bin/bash
# Phase 1 Auto-Fix Script
# Fixes K3s, CI/CD, Helm, Monitoring

echo "========================================"
echo "  PHASE 1 AUTO-FIX START"
echo "========================================"
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# -------------------------------
# 1️⃣ Fix K3s / kubectl access
# -------------------------------
K3S_CONFIG="/etc/rancher/k3s/k3s.yaml"
if [ -f "$K3S_CONFIG" ]; then
    echo "Fixing K3s kubeconfig permissions..."
    sudo chmod 644 $K3S_CONFIG
    export KUBECONFIG=$K3S_CONFIG
    echo -e "${GREEN}✅ K3s access fixed${NC}"
else
    echo -e "${RED}❌ K3s config not found at $K3S_CONFIG${NC}"
fi
echo ""

# -------------------------------
# 2️⃣ Install Helm
# -------------------------------
if ! command -v helm &>/dev/null; then
    echo "Installing Helm..."
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
    echo -e "${GREEN}✅ Helm installed${NC}"
else
    echo -e "${GREEN}✅ Helm already installed${NC}"
fi
echo ""

# -------------------------------
# 3️⃣ Deploy Argo CD
# -------------------------------
if ! kubectl get namespace argocd &>/dev/null; then
    echo "Deploying Argo CD..."
    kubectl create namespace argocd
    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
    echo -e "${GREEN}✅ Argo CD deployed${NC}"
else
    echo -e "${GREEN}✅ Argo CD namespace exists${NC}"
fi
echo ""

# -------------------------------
# 4️⃣ Deploy Prometheus + Grafana
# -------------------------------
echo "Adding Helm repos..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
echo ""

# Prometheus
if ! helm list -n monitoring | grep -q prometheus; then
    echo "Installing Prometheus..."
    kubectl create namespace monitoring 2>/dev/null
    helm install prometheus prometheus-community/prometheus -n monitoring
    echo -e "${GREEN}✅ Prometheus installed${NC}"
else
    echo -e "${GREEN}✅ Prometheus already installed${NC}"
fi

# Grafana
if ! helm list -n monitoring | grep -q grafana; then
    echo "Installing Grafana..."
    helm install grafana grafana/grafana -n monitoring
    echo -e "${GREEN}✅ Grafana installed${NC}"
else
    echo -e "${GREEN}✅ Grafana already installed${NC}"
fi
echo ""

# -------------------------------
# 5️⃣ Start Jenkins (Docker)
# -------------------------------
if ! docker ps -q --filter "name=jenkins" | grep -q .; then
    echo "Starting Jenkins in Docker..."
    docker run -d -p 8080:8080 --name jenkins jenkins/jenkins:lts
    echo -e "${GREEN}✅ Jenkins started on port 8080${NC}"
else
    echo -e "${GREEN}✅ Jenkins already running${NC}"
fi
echo ""

echo "========================================"
echo "  PHASE 1 AUTO-FIX COMPLETED"
echo "========================================"
echo "✅ Next: Re-run ./phase1-health-check.sh to confirm all fixes applied."
