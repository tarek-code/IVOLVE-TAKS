# How to Access ArgoCD UI from Your Laptop

When `kubectl port-forward` binds to `127.0.0.1`, it's only accessible from the VM itself. Here are solutions to access ArgoCD from your laptop.

---

## Solution 1: SSH Port Forwarding (Recommended)

**From your laptop**, create an SSH tunnel to the VM:

```bash
ssh -L 8080:localhost:8080 root@192.168.2.133
```

**Then in the VM**, run:
```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

**Access from laptop:**
- URL: `https://localhost:8080`
- Username: `admin`
- Password: (from `kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d`)

**Keep both terminals open:**
- Terminal 1: SSH tunnel (on laptop)
- Terminal 2: Port forward (on VM)

---

## Solution 2: Port Forward to All Interfaces

**On the VM**, bind to all interfaces (0.0.0.0):

```bash
kubectl port-forward --address 0.0.0.0 svc/argocd-server -n argocd 8080:443
```

**Access from laptop:**
- URL: `https://192.168.2.133:8080`
- Username: `admin`
- Password: (from secret)

**Note:** You may need to accept SSL certificate warning.

---

## Solution 3: Expose via NodePort (Permanent)

**On the VM**, change ArgoCD service to NodePort:

```bash
# Patch the service
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort"}}'

# Get the NodePort
kubectl get svc argocd-server -n argocd
```

**Example output:**
```
NAME            TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE
argocd-server   NodePort   10.96.xxx.xxx   <none>        80:3xxxx/TCP,443:3xxxx/TCP   5m
```

**Access from laptop:**
- URL: `https://192.168.2.133:<NodePort>` (use the 443 port number, e.g., 3xxxx)
- Username: `admin`
- Password: (from secret)

**Note:** The NodePort will be a high number (30000-32767).

---

## Solution 4: Expose via LoadBalancer (If Available)

If your cluster supports LoadBalancer:

```bash
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

# Get the external IP
kubectl get svc argocd-server -n argocd
```

**Access from laptop:**
- URL: `https://<EXTERNAL-IP>:443`
- Username: `admin`
- Password: (from secret)

---

## Quick Commands Reference

### Get ArgoCD Admin Password:
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
echo
```

### Check ArgoCD Service:
```bash
kubectl get svc argocd-server -n argocd
```

### Check ArgoCD Pods:
```bash
kubectl get pods -n argocd
```

---

## Troubleshooting

### Connection Refused
- **Problem:** Can't connect from laptop
- **Solution:** Use Solution 1 (SSH port forwarding) or Solution 2 (bind to 0.0.0.0)

### SSL Certificate Warning
- **Problem:** Browser shows "Not Secure" warning
- **Solution:** Click "Advanced" → "Proceed to localhost" (or the IP address)

### Port Already in Use
- **Problem:** `Error: unable to listen on any of the requested ports`
- **Solution:** 
  ```bash
  # Kill existing port-forward
  pkill -f "port-forward.*argocd-server"
  
  # Or use different port
  kubectl port-forward svc/argocd-server -n argocd 8443:443
  ```

### Firewall Blocking
- **Problem:** Connection timeout
- **Solution:** 
  ```bash
  # On VM, check firewall
  firewall-cmd --list-ports
  
  # Allow port 8080 (if using NodePort, allow that port)
  firewall-cmd --add-port=8080/tcp --permanent
  firewall-cmd --reload
  ```

---

## Recommended: Solution 2 (Simplest)

For quick access, use Solution 2:

```bash
# On VM
kubectl port-forward --address 0.0.0.0 svc/argocd-server -n argocd 8080:443
```

Then access from laptop: `https://192.168.2.133:8080`

**Note:** Keep the terminal open while using ArgoCD UI.
