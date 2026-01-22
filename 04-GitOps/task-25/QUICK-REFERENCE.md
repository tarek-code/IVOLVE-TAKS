# Lab 25 - Quick Reference Card

Quick commands and steps for Lab 25: GitOps Workflow with ArgoCD

---

## 🔑 GitHub Personal Access Token

**Create Token:**
- URL: https://github.com/settings/tokens
- Scopes: `repo` (all sub-options)
- Save token: `ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`

**Add to Jenkins:**
- Jenkins → Manage Jenkins → Credentials → Global
- Kind: `Username with password`
- Username: `tarek-code`
- Password: `<your-token>`
- ID: `github-credentials`

---

## 🚀 ArgoCD Installation Commands

```bash
# 1. Create namespace
kubectl create namespace argocd

# 2. Install ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# 3. Wait for pods
kubectl wait --for=condition=ready pod --all -n argocd --timeout=300s

# 4. Get admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
echo

# 5. Port forward (access UI)
kubectl port-forward svc/argocd-server -n argocd 8080:443

# 6. Create gitops namespace
kubectl create namespace gitops
```

**Access ArgoCD UI:**
- URL: `https://localhost:8080`
- Username: `admin`
- Password: `<from-step-4>`

---

## ⚙️ ArgoCD GUI Configuration

### Connect Repository:
1. Settings → Repositories → Connect Repo
2. URL: `https://github.com/tarek-code/IVOLVE-TAKS.git`
3. Username: `tarek-code`
4. Password: `<your-github-token>`
5. Skip Server Verification: ✅

### Create Application:
1. Applications → + New App
2. **General:**
   - Name: `jenkins-app-gitops`
   - Project: `default`
   - Auto-Create Namespace: ✅
   - Auto-Sync: ✅
   - Self-Heal: ✅
   - Prune Resources: ✅
3. **Source:**
   - Repository: `https://github.com/tarek-code/IVOLVE-TAKS.git`
   - Revision: `main`
   - Path: `04-GitOps/task-25`
4. **Destination:**
   - Cluster: `https://kubernetes.default.svc`
   - Namespace: `gitops`
5. Create

---

## 🔧 Jenkins Pipeline Configuration

**Create Pipeline:**
- Name: `gitops-pipeline`
- Type: Pipeline
- Definition: Pipeline script from SCM
- SCM: Git
- Repository: `https://github.com/tarek-code/IVOLVE-TAKS.git`
- Branch: `*/main`
- Script Path: `04-GitOps/task-25/Jenkinsfile`

---

## ✅ Verification Commands

```bash
# Check ArgoCD pods
kubectl get pods -n argocd

# Check ArgoCD application
kubectl get application -n argocd

# Check deployment
kubectl get deployment jenkins-app -n gitops

# Check pods
kubectl get pods -n gitops -l app=jenkins-app

# Check image tag
kubectl get deployment jenkins-app -n gitops -o jsonpath='{.spec.template.spec.containers[0].image}'
```

---

## 🐛 Quick Troubleshooting

**Jenkins push fails:**
- Check credentials ID: `github-credentials`
- Verify token has `repo` scope
- Check token hasn't expired

**ArgoCD can't connect:**
- Verify token in repository settings
- Check "Skip Server Verification" is enabled
- Test: `git clone https://github.com/tarek-code/IVOLVE-TAKS.git`

**Application not syncing:**
- Click "Sync" button in ArgoCD UI
- Check path: `04-GitOps/task-25`
- Verify `deployment.yaml` exists in repo

---

## 📝 File Paths

- **Jenkinsfile**: `04-GitOps/task-25/Jenkinsfile`
- **deployment.yaml**: `04-GitOps/task-25/deployment.yaml`
- **ArgoCD App**: `04-GitOps/task-25/argocd-application.yaml`

---

## 🔗 Important URLs

- **GitHub Repo**: https://github.com/tarek-code/IVOLVE-TAKS.git
- **GitHub Tokens**: https://github.com/settings/tokens
- **ArgoCD UI**: https://localhost:8080 (after port-forward)

---

**For detailed instructions, see [SETUP-GUIDE.md](SETUP-GUIDE.md)**
