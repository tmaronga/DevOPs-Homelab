# ⚡ Daily Homelab Commands - Quick Reference

## 🏃 FAST MORNING CHECK (2 minutes)

```bash
# The "Big 5" - Run these every morning
kubectl get nodes                                    # Cluster up?
kubectl get pods -A | grep -v Running               # Any issues?
docker ps                                           # Containers running?
df -h / && free -h                                  # Resources OK?
git status                                          # Uncommitted work?
```

---

## 📊 DETAILED HEALTH CHECK (5 minutes)

```bash
# Run the comprehensive check script
~/devops-practice/scripts/daily-homelab-check.sh

# Or manually:
systemctl status k3s                               # K3s service
kubectl cluster-info                               # Cluster info
kubectl top nodes                                  # Resource usage
kubectl get events -A --sort-by='.lastTimestamp' | tail -10
```

---

## 🔍 TROUBLESHOOTING COMMANDS

### When Things Break

```bash
# 1. Check what's wrong
kubectl get pods -A                                # All pod status
kubectl describe pod -n <namespace> <pod-name>     # Detailed info
kubectl logs -n <namespace> <pod-name>            # Pod logs
kubectl logs -n <namespace> <pod-name> --previous # Crashed pod logs

# 2. Check events
kubectl get events -A --sort-by='.lastTimestamp' | tail -20

# 3. Check service status
systemctl status k3s                               # K3s
systemctl status docker                            # Docker
journalctl -u k3s -n 50                           # K3s logs
journalctl -u docker -n 50                        # Docker logs

# 4. Restart if needed
kubectl delete pod -n <namespace> <pod-name>       # Restart pod
sudo systemctl restart k3s                         # Restart K3s
docker restart <container-name>                    # Restart container
```

---

## 🎯 BY COMPONENT

### **Kubernetes Cluster**
```bash
# Quick status
kubectl get nodes -o wide
kubectl get ns
kubectl get all -A

# Resource usage
kubectl top nodes
kubectl top pods -A

# Specific namespace
kubectl get all -n monitoring
kubectl get all -n argocd
kubectl get all -n kube-system
```

### **Pods & Deployments**
```bash
# List all pods
kubectl get pods -A
kubectl get pods -A -o wide                        # With node info

# Watch pods in real-time
kubectl get pods -A -w

# Describe specific pod
kubectl describe pod -n <namespace> <pod-name>

# Get pod logs
kubectl logs -n <namespace> <pod-name>
kubectl logs -n <namespace> <pod-name> -f          # Follow logs
kubectl logs -n <namespace> <pod-name> --tail=50   # Last 50 lines
```

### **Services & Networking**
```bash
# List all services
kubectl get svc -A

# Check ingress
kubectl get ingress -A

# Port forwarding
kubectl port-forward -n argocd svc/argocd-server 8081:443
kubectl port-forward -n monitoring svc/grafana 3000:80
kubectl port-forward -n monitoring svc/prometheus-server 9090:80

# Test connectivity
kubectl run -it --rm debug --image=busybox --restart=Never -- sh
# Then inside: nslookup kubernetes.default
```

### **Storage**
```bash
# Check volumes
kubectl get pv
kubectl get pvc -A

# Check storage usage
df -h
du -sh /var/lib/rancher/k3s/storage/*
```

### **Docker Containers**
```bash
# List containers
docker ps                                          # Running
docker ps -a                                       # All

# Check logs
docker logs jenkins
docker logs jenkins --tail 50
docker logs jenkins -f                            # Follow

# Container stats
docker stats                                       # Real-time
docker stats --no-stream                          # Snapshot

# Manage containers
docker restart jenkins
docker stop jenkins
docker start jenkins
```

### **ArgoCD**
```bash
# Get password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo

# Check ArgoCD apps
kubectl get applications -n argocd

# Port forward
kubectl port-forward svc/argocd-server -n argocd 8081:443

# Sync an application
kubectl patch application <app-name> -n argocd --type merge -p '{"operation":{"sync":{}}}'
```

### **Monitoring (Prometheus/Grafana)**
```bash
# Check Prometheus
kubectl get pods -n monitoring -l app.kubernetes.io/name=prometheus
kubectl port-forward -n monitoring svc/prometheus-server 9090:80

# Check Grafana
kubectl get pods -n monitoring -l app.kubernetes.io/name=grafana
kubectl port-forward -n monitoring svc/grafana 3000:80

# Get Grafana password
kubectl get secret -n monitoring grafana -o jsonpath="{.data.admin-password}" | base64 -d && echo
```

### **Jenkins**
```bash
# Check status
docker ps | grep jenkins

# Get password
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword

# View logs
docker logs jenkins --tail 100

# Restart
docker restart jenkins
```

---

## 🚨 EMERGENCY COMMANDS

### Quick Fixes
```bash
# Restart everything
sudo systemctl restart k3s
docker restart $(docker ps -q)

# Clear disk space
docker system prune -a                            # ⚠️ Removes unused images
kubectl delete pod -n <namespace> <pod-name>      # Restart stuck pod

# Reset networking
sudo systemctl restart NetworkManager

# Force sync time (if time drift)
sudo timedatectl set-ntp off && sudo timedatectl set-ntp on
```

### Recovery Commands
```bash
# Export cluster state
kubectl get all -A -o yaml > cluster-backup.yaml

# Check cluster certificates
sudo k3s check-config

# View all container logs
for pod in $(kubectl get pods -A -o name); do
    echo "=== $pod ===" 
    kubectl logs $pod 2>/dev/null | tail -5
done
```

---

## 📋 DAILY WORKFLOW

### **Morning Routine (Start of Day)**
```bash
# 1. System check
df -h && free -h

# 2. Services check
systemctl status k3s docker

# 3. Cluster check
kubectl get nodes
kubectl get pods -A | grep -v Running

# 4. Port forwards (in separate terminals)
kubectl port-forward svc/argocd-server -n argocd 8081:443 &
kubectl port-forward -n monitoring svc/grafana 3000:80 &
kubectl port-forward -n monitoring svc/prometheus-server 9090:80 &
```

### **During Work**
```bash
# Monitor in real-time
watch -n 5 'kubectl get pods -A'                  # Auto-refresh every 5s
kubectl get events -A -w                          # Watch events

# Check logs while working
kubectl logs -n <namespace> <pod-name> -f         # Follow logs
docker logs jenkins -f                            # Follow Jenkins
```

### **End of Day**
```bash
# 1. Commit your work
cd ~/devops-practice
git status
git add .
git commit -m "Day X: <what you did>"
git push

# 2. Take screenshots
# - Grafana dashboards
# - ArgoCD applications
# - Prometheus metrics

# 3. Document learnings
nano DAILY-LOG.md

# 4. Kill port forwards
pkill -f port-forward

# 5. Optional: Stop services to save resources
docker stop jenkins
# K3s keeps running
```

---

## 🎯 ONE-LINER HEALTH CHECK

```bash
# Copy-paste this single command for instant overview
echo "=== CLUSTER ===" && kubectl get nodes && \
echo -e "\n=== PODS ===" && kubectl get pods -A | grep -v Running | head -5 && \
echo -e "\n=== RESOURCES ===" && kubectl top nodes && \
echo -e "\n=== DOCKER ===" && docker ps && \
echo -e "\n=== DISK ===" && df -h / | tail -1
```

---

## 💾 SAVE THESE ALIASES

Add to `~/.bashrc` or `~/.bash_aliases`:

```bash
# Kubernetes shortcuts
alias k='kubectl'
alias kgp='kubectl get pods -A'
alias kgs='kubectl get svc -A'
alias kgn='kubectl get nodes'
alias kd='kubectl describe'
alias kl='kubectl logs'
alias kpf='kubectl port-forward'

# Homelab specific
alias homelab-check='~/devops-practice/scripts/daily-homelab-check.sh'
alias argocd-fwd='kubectl port-forward svc/argocd-server -n argocd 8081:443'
alias grafana-fwd='kubectl port-forward -n monitoring svc/grafana 3000:80'
alias prom-fwd='kubectl port-forward -n monitoring svc/prometheus-server 9090:80'

# Quick status
alias status='kubectl get nodes && kubectl get pods -A | grep -v Running'
alias health='systemctl is-active k3s docker && echo "Services OK"'

# Git shortcuts
alias gst='git status'
alias gp='git push'
alias gc='git commit -m'
```

Then run: `source ~/.bashrc`

---

## 📱 MOBILE/REMOTE ACCESS

If accessing remotely:

```bash
# SSH tunnel from remote machine
ssh -L 8081:localhost:8081 user@your-homelab-ip
ssh -L 3000:localhost:3000 user@your-homelab-ip
ssh -L 9090:localhost:9090 user@your-homelab-ip

# Then access locally at:
# https://localhost:8081 (ArgoCD)
# http://localhost:3000 (Grafana)
# http://localhost:9090 (Prometheus)
```

---

**💡 Pro Tip:** Run `homelab-check` every morning and review the summary. It takes 30 seconds and catches 95% of issues!
