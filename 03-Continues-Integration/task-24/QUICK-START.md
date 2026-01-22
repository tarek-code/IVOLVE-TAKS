# Lab 24 - Quick Start Guide

This is a quick reference guide for setting up Lab 24: Multi Branch CI/CD Workflow.

---

## 🚀 Quick Setup (5 Steps)

### Step 1: Set Up Git Branches

**Important:** Push **only the Jenkins_App application code**, NOT the entire IVOLVE-TAKS repository.

```bash
# Clone the repository (should contain only application code)
git clone https://github.com/Ibrahim-Adel15/Jenkins_App.git
cd Jenkins_App

# Verify required files exist
ls -la
# Should see: Dockerfile, pom.xml, src/, Jenkinsfile

# Copy Jenkinsfile if not present
cp ../IVOLVE-TAKS/03-Continues-Integration/task-24/Jenkinsfile .

# Create branches
git checkout -b dev
git push -u origin dev
git checkout main
git checkout -b stag
git push -u origin stag
git checkout main
git checkout -b prod
git push -u origin prod
```

**Each branch should contain:**
- ✅ Dockerfile, Jenkinsfile, pom.xml, src/
- ❌ NOT task-22/, task-23/, task-24/ folders
- ❌ NOT entire IVOLVE-TAKS repository

### Step 2: Create Kubernetes Namespaces

```bash
# From task-24 directory
kubectl apply -f namespaces.yaml

# Verify
kubectl get namespace prod stag dev
```

### Step 3: Copy Jenkinsfile to Repository

```bash
# Copy Jenkinsfile to your repository root
cp task-24/Jenkinsfile Jenkins_App/
cd Jenkins_App
git add Jenkinsfile
git commit -m "Add Jenkinsfile for multi-branch pipeline"
git push origin main
git push origin dev
git push origin stag
git push origin prod
```

### Step 4: Create Multi Branch Pipeline in Jenkins

1. **Jenkins UI** → **New Item**
2. **Name**: `jenkins-app-multibranch`
3. **Type**: **Multibranch Pipeline** → **OK**
4. **Branch Sources** → **Add source** → **Git**
   - **Project Repository**: `https://github.com/Ibrahim-Adel15/Jenkins_App.git`
   - **Credentials**: Add if private
   - **Behaviors**:
     - **Discover branches**: All branches
     - **Filter by name**: Include `prod`, `stag`, `dev`, `main`
5. **Build Configuration**:
   - **Mode**: **by Jenkinsfile**
   - **Script Path**: `Jenkinsfile`
6. **Save**

### Step 5: Run Pipeline

1. Click **Scan Multibranch Pipeline Now**
2. Wait for branches to be detected
3. Click on a branch (e.g., `dev`)
4. Click **Build Now**
5. Verify deployment:
   ```bash
   kubectl get pods -n dev -l app=jenkins-app
   ```

---

## ✅ Verification

```bash
# Check all namespaces have deployments
kubectl get deployment jenkins-app -n prod
kubectl get deployment jenkins-app -n stag
kubectl get deployment jenkins-app -n dev

# Check pods
kubectl get pods -n prod -l app=jenkins-app
kubectl get pods -n stag -l app=jenkins-app
kubectl get pods -n dev -l app=jenkins-app
```

---

## 🔧 Prerequisites Checklist

- [ ] Jenkins Master running (Lab 22)
- [ ] Jenkins Agent configured (Lab 23)
- [ ] Shared Library configured (Lab 23)
- [ ] Docker Hub credentials in Jenkins
- [ ] Kubernetes cluster access
- [ ] Git repository with 3 branches (prod/stag/dev)

---

## 📝 Branch to Namespace Mapping

| Branch | Namespace | Image Tag Format |
|--------|-----------|------------------|
| `prod` | `prod`    | `prod-{BUILD_NUMBER}` |
| `stag` | `stag`    | `stag-{BUILD_NUMBER}` |
| `dev`  | `dev`     | `dev-{BUILD_NUMBER}` |
| Other  | `default` | `{BRANCH}-{BUILD_NUMBER}` |

---

## 🐛 Common Issues

**Branches not detected?**
- Check repository URL
- Verify branch filter settings
- Click "Scan Multibranch Pipeline Now"

**Wrong namespace?**
- Check `BRANCH_NAME` in console output
- Verify branch names match exactly (case-sensitive)

**Deployment fails?**
- Verify namespaces exist: `kubectl get namespace prod stag dev`
- Check RBAC permissions
- Review console logs

---

For detailed instructions, see [README.md](README.md)
