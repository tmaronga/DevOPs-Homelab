# Homelab Interview Guide - Quick Reference

## 🎤 Interview Questions & Answers

### Q: "Tell me about your Kubernetes setup"

**Answer:**
"I run a single-node K3s cluster on Ubuntu with a production-grade monitoring stack. The cluster hosts 21 pods across 4 namespaces:
- **ArgoCD** (7 pods) for GitOps continuous deployment
- **Monitoring stack** (6 pods) - Prometheus and Grafana
- **System pods** (5 pods) - CoreDNS, Traefik, Metrics Server
- **Applications** (3 pods) - deployed via GitOps

The cluster has been running stable for 9+ days with automatic recovery after reboots."

---

### Q: "How do you monitor your infrastructure?"

**Answer:**
"I use the **Prometheus + Grafana stack**:

**Prometheus** collects metrics from:
- **Node Exporter** (DaemonSet) - host-level metrics (CPU, RAM, disk, network)
- **Kube State Metrics** - Kubernetes object metrics (pods, deployments, services)
- **cAdvisor** (built into kubelet) - container-level metrics

**Grafana** provides visualization with imported dashboards showing:
- Cluster health and resource usage
- Pod performance metrics
- Node capacity planning
- Real-time alerts

The entire stack is deployed via **Helm** with configurations in Git for GitOps workflow."

---

### Q: "Explain your GitOps workflow"

**Answer:**
"I use **ArgoCD** for continuous deployment with a Git-based workflow:

1. **Source of Truth:** All configs stored in GitHub (`DevOps-Homelab` repo)
2. **Automatic Sync:** ArgoCD monitors the repo and deploys changes automatically
3. **Self-healing:** If someone manually changes a resource, ArgoCD reverts it to match Git
4. **Rollback:** Can roll back to any previous Git commit
5. **Declarative:** All infrastructure defined as YAML manifests

Example: I deployed an nginx application by pushing Kubernetes manifests to Git. ArgoCD detected the change and deployed it within seconds."

---

### Q: "How do you handle pod failures?"

**Answer:**
"Kubernetes provides built-in self-healing through **ReplicaSets** and **Deployments**:

- **Readiness Probes:** Kubernetes checks if pods are ready to serve traffic
- **Liveness Probes:** Detects hung processes and restarts them
- **Restart Policy:** Automatically recreates failed pods
- **ReplicaSets:** Maintain desired number of replicas

Example from my monitoring stack: Grafana has **2 restarts** due to system reboots, but the Deployment ensured it came back automatically. I can see this with:
```bash
kubectl describe pod grafana-xxx -n monitoring
```

For debugging failures, I use:
```bash
kubectl logs <pod> -n <namespace>
kubectl describe pod <pod> -n <namespace>
kubectl get events -n <namespace>
```"

---

### Q: "What's the difference between Deployment and StatefulSet?"

**Answer:**
"**Deployments** are for stateless apps:
- Pods are interchangeable
- Can be deleted/recreated in any order
- Use random names (grafana-7656ff8d4-2gg8l)
- Example: Grafana, Prometheus Server

**StatefulSets** are for stateful apps:
- Pods have stable identities (alertmanager-0, alertmanager-1)
- Created/deleted in order (0 → 1 → 2)
- Each pod gets unique persistent storage
- Stable DNS names for clustering
- Example: AlertManager (can run clustered), databases

In my setup, AlertManager uses StatefulSet even though I run 1 replica - this allows me to scale to 3 replicas for high availability without code changes."

---

### Q: "Explain Kubernetes Services"

**Answer:**
"Services provide **stable networking** for pods. I use three types:

**1. ClusterIP** (most common in my setup):
```
service/grafana  ClusterIP  10.43.101.152  80/TCP
```
- Only accessible within cluster
- Virtual IP load-balances to healthy pods
- Used for: Grafana, Prometheus, all internal services

**2. Headless Service** (for StatefulSets):
```
service/prometheus-alertmanager-headless  ClusterIP  None
```
- No load balancing - returns individual pod IPs
- Enables direct pod-to-pod communication
- Required for StatefulSet clustering

**3. LoadBalancer/NodePort** (not shown - for external access):
- I use `kubectl port-forward` for local access
- In production, I'd use an Ingress controller with TLS

Service discovery works via Kubernetes DNS:
- `grafana.monitoring.svc.cluster.local` resolves to Grafana pods
- Pods can find each other without hardcoded IPs"

---

### Q: "How do you access services running in the cluster?"

**Answer:**
"Three methods depending on use case:

**1. Port Forwarding** (my current method):
```bash
kubectl port-forward svc/grafana -n monitoring 3000:80
```
- Secure tunnel from localhost to cluster
- Good for development/testing
- No external exposure

**2. Ingress Controller** (production):
- Traefik is already running in my cluster
- Would configure Ingress resources with TLS
- Single entry point with path-based routing:
  - grafana.homelab.local → Grafana
  - argocd.homelab.local → ArgoCD

**3. NodePort** (expose on node IP):
- Exposes service on every node's IP
- Less secure, mainly for testing

For my homelab, port-forward is sufficient. In production, I'd use Ingress with cert-manager for automatic TLS certificates."

---

### Q: "What happens when you reboot the system?"

**Answer:**
"My setup has automatic recovery:

**What Persists:**
- K3s starts via systemd (enabled)
- Docker starts automatically
- All pods restart (K3s manages this)
- Deployments recreate pods in correct state
- StatefulSets recreate with same identities

**What Doesn't Persist:**
- Port forwards (kubectl commands don't survive reboot)
- In-memory data (unless using PersistentVolumes)

**My Solution:**
I created a systemd service that:
1. Waits for K3s to be ready
2. Waits for pods to start
3. Automatically restarts port forwards

Current uptime: 5h15m since last reboot, all services healthy."

---

## 📊 Key Metrics to Mention

**Infrastructure:**
- **Cluster Age:** 9 days
- **Uptime:** 99.9% (only down during planned reboots)
- **Pod Count:** 21 pods across 4 namespaces
- **All pods healthy:** 21/21 Running

**Monitoring:**
- **Metrics Scraped:** Every 15 seconds
- **Retention:** 15 days in Prometheus
- **Dashboards:** 3 imported Kubernetes dashboards
- **Alerting:** AlertManager configured (ready for Slack/email)

**Resource Usage:**
- **Memory:** 5.9Gi / 14Gi (42%)
- **CPU:** Load average ~1.5 (4 cores available)
- **Disk:** 39G / 233G (18%)
- **Efficient:** Running full stack on single node

---

## 🛠️ Common Commands to Demonstrate

### Monitoring
```bash
# Get all resources in monitoring namespace
kubectl get all -n monitoring

# View pod logs
kubectl logs grafana-xxx -n monitoring

# Check resource usage
kubectl top nodes
kubectl top pods -n monitoring

# View pod details
kubectl describe pod grafana-xxx -n monitoring
```

### GitOps (ArgoCD)
```bash
# List applications
kubectl get applications -n argocd

# Check ArgoCD status
kubectl get pods -n argocd

# View application details
kubectl get application nginx-gitops -n argocd -o yaml
```

### Troubleshooting
```bash
# View recent events
kubectl get events -A --sort-by='.lastTimestamp' | tail -20

# Check service endpoints
kubectl get endpoints grafana -n monitoring

# Test service connectivity
kubectl run -it --rm debug --image=busybox --restart=Never -- sh
  # Inside pod: wget -O- http://grafana.monitoring.svc.cluster.local
```

---

## 🎯 Project Highlights for Resume

**Project:** Production-Grade Kubernetes Homelab
**Duration:** 9+ days uptime, 6+ days monitoring stack
**Technologies:** K3s, Helm, ArgoCD, Prometheus, Grafana, Docker

**Achievements:**
- Deployed 21-pod Kubernetes cluster with 99.9% uptime
- Implemented GitOps workflow with ArgoCD for automated deployments
- Built comprehensive monitoring with Prometheus + Grafana (6 components)
- Configured self-healing infrastructure with automatic recovery
- Documented entire setup for portfolio and interviews

**Technical Skills Demonstrated:**
- Container orchestration (Kubernetes/K3s)
- Infrastructure as Code (Helm charts, YAML manifests)
- GitOps (ArgoCD)
- Monitoring & Observability (Prometheus, Grafana)
- Networking (Services, DNS, port forwarding)
- Troubleshooting (logs, events, metrics)
- Linux administration (systemd, networking)

---

## 🔄 Shutdown & Restart Commands

### Graceful Shutdown
```bash
# Stop port forwards
pkill -f port-forward

# Stop Docker containers
docker stop jenkins portainer

# K3s keeps running (recommended)
```

### Full Shutdown
```bash
pkill -f port-forward
docker stop $(docker ps -q)
sudo systemctl stop k3s
sudo shutdown -h now
```

### Quick Start
```bash
# If K3s stopped
sudo systemctl start k3s

# Start containers
docker start jenkins portainer

# Start port forwards
homelab-start
```

### Health Check
```bash
homelab-check
```

---

## 💡 Interview Tips

1. **Be Specific:** Reference actual pod names, metrics, commands from your setup
2. **Show Problem-Solving:** Mention troubleshooting you did (e.g., port-forward after reboot)
3. **Explain Why:** Always explain why you chose specific tools (industry standard, scalable, etc.)
4. **Production Mindset:** Mention what you'd do differently in production (Ingress, HA, backups)
5. **Continuous Learning:** Emphasize you're actively learning and improving the setup

---

**Last Updated:** January 12, 2026  
**Cluster Age:** 9 days  
**Health Score:** 90% (9/10)  
**Status:** Production Ready ✅
