#!/bin/bash
# Install Prometheus & Grafana Monitoring Stack
# Uses Helm for easy installation and management

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "========================================"
echo "  📊 INSTALLING MONITORING STACK"
echo "========================================"
echo ""

# Check if Helm is installed
if ! command -v helm &> /dev/null; then
    echo -e "${YELLOW}⚠️  Helm not found. Installing...${NC}"
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
fi

echo -e "${GREEN}✅ Helm installed: $(helm version --short)${NC}"
echo ""

# Create monitoring namespace
echo -e "${BLUE}Creating monitoring namespace...${NC}"
kubectl create namespace monitoring 2>/dev/null || echo "Namespace already exists"

# Add Prometheus Helm repo
echo -e "${BLUE}Adding Prometheus community Helm repo...${NC}"
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Installing Prometheus...${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Install Prometheus
helm upgrade --install prometheus prometheus-community/prometheus \
  --namespace monitoring \
  --set alertmanager.persistentVolume.enabled=false \
  --set server.persistentVolume.enabled=false \
  --set pushgateway.persistentVolume.enabled=false \
  --set server.service.type=ClusterIP \
  --set server.resources.requests.memory=512Mi \
  --set server.resources.limits.memory=1Gi \
  --wait --timeout 5m

echo ""
echo -e "${GREEN}✅ Prometheus installed successfully!${NC}"
echo ""

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Installing Grafana...${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Add Grafana Helm repo
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Install Grafana with Prometheus datasource pre-configured
helm upgrade --install grafana grafana/grafana \
  --namespace monitoring \
  --set persistence.enabled=false \
  --set service.type=ClusterIP \
  --set adminPassword=admin123 \
  --set datasources."datasources\.yaml".apiVersion=1 \
  --set datasources."datasources\.yaml".datasources[0].name=Prometheus \
  --set datasources."datasources\.yaml".datasources[0].type=prometheus \
  --set datasources."datasources\.yaml".datasources[0].url=http://prometheus-server \
  --set datasources."datasources\.yaml".datasources[0].access=proxy \
  --set datasources."datasources\.yaml".datasources[0].isDefault=true \
  --wait --timeout 5m

echo ""
echo -e "${GREEN}✅ Grafana installed successfully!${NC}"
echo ""

# Wait for pods to be ready
echo -e "${BLUE}Waiting for pods to be ready...${NC}"
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=prometheus -n monitoring --timeout=120s 2>/dev/null || true
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=grafana -n monitoring --timeout=120s 2>/dev/null || true

echo ""
echo "========================================"
echo -e "${GREEN}✅ MONITORING STACK INSTALLED!${NC}"
echo "========================================"
echo ""

# Get pod status
echo "📦 Pod Status:"
kubectl get pods -n monitoring
echo ""

# Get services
echo "🌐 Services:"
kubectl get svc -n monitoring
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📝 ACCESS INFORMATION"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "🔍 Prometheus:"
echo "   kubectl port-forward -n monitoring svc/prometheus-server 9090:80"
echo "   Then open: http://localhost:9090"
echo ""

echo "📊 Grafana:"
echo "   kubectl port-forward -n monitoring svc/grafana 3000:80"
echo "   Then open: http://localhost:3000"
echo "   Username: admin"
echo "   Password: admin123"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📚 NEXT STEPS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "1. Port forward Grafana:"
echo "   kubectl port-forward -n monitoring svc/grafana 3000:80 &"
echo ""
echo "2. Import Kubernetes dashboards in Grafana:"
echo "   Dashboard ID: 15760 (Kubernetes Cluster Monitoring)"
echo "   Dashboard ID: 315 (Kubernetes Cluster)"
echo "   Dashboard ID: 1860 (Node Exporter Full)"
echo ""
echo "3. Run health check:"
echo "   homelab-check"
echo ""

echo "========================================"
echo "Installation completed at $(date '+%H:%M:%S')"
echo "========================================"
