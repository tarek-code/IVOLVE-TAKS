# How the GitOps Workflow Works

This document explains exactly what happens when Jenkins runs the pipeline and how ArgoCD detects and deploys changes.

---

## 🔄 Complete Workflow Flow

```
┌─────────────────────────────────────────────────────────┐
│  Step 1: Jenkins Pipeline Runs                         │
│                                                          │
│  1. Checkout                                            │
│     ├─ Clones application source (Jenkins_App)         │
│     └─ Clones GitOps repo (IVOLVE-TAKS)                │
│                                                          │
│  2. BuildApp                                            │
│     └─ Builds the application                           │
│                                                          │
│  3. BuildImage                                          │
│     └─ Builds Docker image: your-username/jenkins-app:1│
│                                                          │
│  4. PushImage                                           │
│     └─ Pushes to Docker Hub                             │
│                                                          │
│  5. RemoveImageLocally                                  │
│     └─ Cleans up local image                            │
│                                                          │
│  6. UpdateDeploymentYaml ⭐ KEY STEP                    │
│     └─ Updates deployment.yaml:                         │
│        FROM: image: your-username/jenkins-app:latest    │
│        TO:   image: your-username/jenkins-app:1         │
│                                                          │
│  7. PushToGitHub ⭐ KEY STEP                            │
│     ├─ git add 04-GitOps/task-25/deployment.yaml       │
│     ├─ git commit -m "Update deployment image..."       │
│     └─ git push origin main                             │
│                                                          │
└─────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│  Step 2: GitHub Repository Updated                     │
│                                                          │
│  deployment.yaml now contains:                         │
│  image: your-username/jenkins-app:1                    │
│                                                          │
└─────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│  Step 3: ArgoCD Detects Change                         │
│                                                          │
│  ArgoCD polls Git (every 3 minutes by default)         │
│  OR receives webhook notification                       │
│                                                          │
│  Detects: deployment.yaml changed                      │
│  Compares: Git state vs Cluster state                  │
│  Result: OutOfSync detected                            │
│                                                          │
└─────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│  Step 4: ArgoCD Auto-Syncs                             │
│                                                          │
│  (If Auto-Sync is enabled)                             │
│  ├─ Applies deployment.yaml to Kubernetes              │
│  ├─ Updates Deployment resource                        │
│  ├─ Kubernetes creates new pods with new image        │
│  └─ Status: Synced ✅                                  │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

---

## 📝 What Jenkins Changes in deployment.yaml

### Before Jenkins Pipeline:

```yaml
spec:
  containers:
  - name: jenkins-app
    image: your-username/jenkins-app:latest  # Old image
```

### After Jenkins Pipeline (Build #1):

```yaml
spec:
  containers:
  - name: jenkins-app
    image: your-username/jenkins-app:1  # New image tag
```

### After Jenkins Pipeline (Build #2):

```yaml
spec:
  containers:
  - name: jenkins-app
    image: your-username/jenkins-app:2  # New image tag
```

---

## 🔍 Detailed Step-by-Step

### Stage 6: UpdateDeploymentYaml

**What happens:**
1. Jenkins reads `04-GitOps/task-25/deployment.yaml`
2. Uses `sed` command to find and replace:
   ```bash
   sed -i 's|image: .*/jenkins-app:.*|image: your-username/jenkins-app:1|g' deployment.yaml
   ```
3. This replaces ANY image tag with the new one
4. Verifies the change was made

**Example:**
- **Before:** `image: your-username/jenkins-app:latest`
- **After:** `image: your-username/jenkins-app:1`

### Stage 7: PushToGitHub

**What happens:**
1. Jenkins stages the updated file:
   ```bash
   git add 04-GitOps/task-25/deployment.yaml
   ```

2. Commits with descriptive message:
   ```bash
   git commit -m "Update deployment image to your-username/jenkins-app:1 (Build #1)"
   ```

3. Pushes to GitHub:
   ```bash
   git push origin main
   ```

4. **Result:** GitHub repository now has updated `deployment.yaml`

---

## ⚡ ArgoCD Detection

### How ArgoCD Detects Changes

**Option 1: Polling (Default)**
- ArgoCD polls Git every **3 minutes** by default
- Compares Git state with cluster state
- If different → marks as "OutOfSync"
- If Auto-Sync enabled → automatically syncs

**Option 2: Webhook (Faster)**
- GitHub sends webhook to ArgoCD on push
- ArgoCD detects change immediately
- Syncs within seconds

### What ArgoCD Sees

1. **Before Jenkins Push:**
   - Git: `image: your-username/jenkins-app:latest`
   - Cluster: `image: your-username/jenkins-app:latest`
   - Status: ✅ **Synced**

2. **After Jenkins Push:**
   - Git: `image: your-username/jenkins-app:1` (NEW)
   - Cluster: `image: your-username/jenkins-app:latest` (OLD)
   - Status: ⚠️ **OutOfSync**

3. **After ArgoCD Sync:**
   - Git: `image: your-username/jenkins-app:1`
   - Cluster: `image: your-username/jenkins-app:1` (UPDATED)
   - Status: ✅ **Synced**

---

## 🎯 Verification Steps

### 1. Check Jenkins Console Output

After pipeline runs, you should see:
```
Stage: UpdateDeploymentYaml
Updating deployment.yaml with image: your-username/jenkins-app:1
Updated deployment.yaml:
image: your-username/jenkins-app:1
Successfully updated 04-GitOps/task-25/deployment.yaml

Stage: PushToGitHub
Successfully pushed updated deployment.yaml to main branch
```

### 2. Check GitHub

1. Go to: https://github.com/tarek-code/IVOLVE-TAKS
2. Navigate to: `04-GitOps/task-25/deployment.yaml`
3. Click **"History"** or check latest commit
4. Verify image tag changed

### 3. Check ArgoCD UI

1. Open ArgoCD UI
2. Click on `jenkins-app-gitops` application
3. **Status** should change:
   - ⚠️ **OutOfSync** (after Git push, before sync)
   - ✅ **Synced** (after ArgoCD syncs)

4. **Last Sync** timestamp should update

### 4. Check Kubernetes

```bash
# Check deployment image
kubectl get deployment jenkins-app -n gitops -o jsonpath='{.spec.template.spec.containers[0].image}'

# Should show: your-username/jenkins-app:1 (or latest build number)

# Check pods
kubectl get pods -n gitops -l app=jenkins-app

# New pods should be created with new image
```

---

## 🔧 How the sed Command Works

The Jenkinsfile uses this command to update the image:

```bash
sed -i 's|image: .*/jenkins-app:.*|image: your-username/jenkins-app:1|g' deployment.yaml
```

**Breaking it down:**
- `sed -i` = Edit file in-place
- `s|...|...|g` = Substitute pattern
- `image: .*/jenkins-app:.*` = Find pattern:
  - `image: ` = Literal text
  - `.*` = Any characters (username)
  - `/jenkins-app:` = Literal text
  - `.*` = Any characters (tag)
- `image: your-username/jenkins-app:1` = Replace with new image
- `g` = Global (replace all occurrences)

**This will match:**
- `image: your-username/jenkins-app:latest`
- `image: your-username/jenkins-app:5`
- `image: test/jenkins-app:v1.0`

**And replace with:**
- `image: your-username/jenkins-app:1` (or current BUILD_NUMBER)

---

## ⚙️ Configuration

### Image Tag Format

In Jenkinsfile:
```groovy
IMAGE_TAG = "${env.BUILD_NUMBER}"  // Uses build number: 1, 2, 3, etc.
```

**You can change this to:**
```groovy
IMAGE_TAG = "v${env.BUILD_NUMBER}"  // v1, v2, v3
IMAGE_TAG = "${env.BUILD_NUMBER}-${env.BRANCH_NAME}"  // 1-main, 2-main
IMAGE_TAG = "${new Date().format('yyyyMMdd-HHmmss')}"  // 20260122-143025
```

### Deployment File Path

In Jenkinsfile:
```groovy
DEPLOYMENT_FILE = "04-GitOps/task-25/deployment.yaml"
```

**Make sure this matches:**
- The actual path in your repository
- The path configured in ArgoCD Application

---

## 🐛 Troubleshooting

### Jenkins Doesn't Update deployment.yaml

**Problem:** File not updated

**Check:**
1. Verify `DEPLOYMENT_FILE` path is correct
2. Check file exists in `gitops-repo` directory
3. Check sed command works: `sed --version`
4. Check Jenkins console output for errors

### Changes Not Pushed to GitHub

**Problem:** UpdateDeploymentYaml works but PushToGitHub fails

**Check:**
1. Verify GitHub credentials (`github-credentials`)
2. Check repository URL is correct
3. Verify branch name (`main`)
4. Check Git is installed on Jenkins agent
5. Check Jenkins console for Git errors

### ArgoCD Doesn't Detect Changes

**Problem:** Changes pushed but ArgoCD doesn't sync

**Solutions:**
1. **Wait 3 minutes** (if using polling)
2. **Click "Refresh"** in ArgoCD UI
3. **Click "Hard Refresh"** to force check
4. **Check repository connection** in ArgoCD Settings
5. **Enable webhook** for faster detection

### ArgoCD Syncs But Pods Don't Update

**Problem:** ArgoCD shows Synced but pods use old image

**Solutions:**
1. Check if deployment strategy is correct
2. Verify image exists in Docker Hub
3. Check pod events: `kubectl describe pod <pod-name> -n gitops`
4. Force rollout: `kubectl rollout restart deployment jenkins-app -n gitops`

---

## ✅ Summary

**Yes, Jenkins automatically:**
1. ✅ Updates `deployment.yaml` with new image tag
2. ✅ Commits the change to Git
3. ✅ Pushes to GitHub
4. ✅ ArgoCD detects the change (within 3 minutes or via webhook)
5. ✅ ArgoCD automatically syncs and deploys new version

**You don't need to:**
- ❌ Manually edit deployment.yaml
- ❌ Manually commit/push to Git
- ❌ Manually run kubectl apply
- ❌ Manually trigger ArgoCD sync (if auto-sync enabled)

**Everything is automated!** 🎉
