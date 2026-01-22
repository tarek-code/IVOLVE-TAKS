# Lab 25 Setup Guide - Step by Step

This guide provides detailed steps for:
1. **Setting up Jenkins GitHub Access** (to push changes)
2. **Installing ArgoCD** (manual installation)
3. **Configuring ArgoCD via GUI**

---

## Part 1: Configure Jenkins GitHub Access

Jenkins needs to push changes to `https://github.com/tarek-code/IVOLVE-TAKS.git`. We'll use a **Personal Access Token (PAT)** method.

### Step 1.1: Create GitHub Personal Access Token

1. **Go to GitHub:**
   - Visit: https://github.com/settings/tokens
   - Or: GitHub → Your Profile → Settings → Developer settings → Personal access tokens → Tokens (classic)

2. **Generate New Token:**
   - Click **"Generate new token"** → **"Generate new token (classic)"**
   - **Note**: `Jenkins-GitOps-Push-Token`
   - **Expiration**: Choose duration (90 days recommended)
   - **Scopes**: Check these permissions:
     - ✅ **repo** (Full control of private repositories)
       - ✅ repo:status
       - ✅ repo_deployment
       - ✅ public_repo
       - ✅ repo:invite
       - ✅ security_events

3. **Generate and Copy Token:**
   - Click **"Generate token"**
   - **⚠️ IMPORTANT**: Copy the token immediately (you won't see it again!)
   - Example: `ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`

### Step 1.2: Add GitHub Credentials in Jenkins

1. **Open Jenkins:**
   - Go to Jenkins Dashboard
   - Click **"Manage Jenkins"** → **"Credentials"** → **"System"** → **"Global credentials (unrestricted)"**

2. **Add New Credentials:**
   - Click **"Add Credentials"** (or **"+"** button)

3. **Configure Credentials:**
   - **Kind**: `Username with password`
   - **Scope**: `Global`
   - **Username**: Your GitHub username (e.g., `tarek-code`)
   - **Password**: Paste your **Personal Access Token** (not your GitHub password!)
   - **ID**: `github-credentials` (must match Jenkinsfile)
   - **Description**: `GitHub credentials for GitOps repository push`

4. **Click "Create"**

### Step 1.3: Verify Credentials

1. **Test the credentials:**
   - In Jenkins, go to **"Manage Jenkins"** → **"Credentials"**
   - Find `github-credentials`
   - You should see it listed

### Step 1.4: Update Jenkinsfile (if needed)

The Jenkinsfile already uses `github-credentials`. Verify it's correct:

```groovy
withCredentials([usernamePassword(credentialsId: 'github-credentials', 
                                 usernameVariable: 'GIT_USER', 
                                 passwordVariable: 'GIT_PASSWORD')]) {
```

---

## Part 2: Install ArgoCD Manually

### Step 2.1: Create ArgoCD Namespace

```bash
kubectl create namespace argocd
```

**Verify:**
```bash
kubectl get namespace argocd
```

### Step 2.2: Install ArgoCD

```bash
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

**Wait for installation:**
```bash
# Watch pods being created
kubectl get pods -n argocd -w
```

**Wait until all pods are Running:**
```bash
kubectl wait --for=condition=ready pod --all -n argocd --timeout=300s
```

### Step 2.3: Verify ArgoCD Installation

```bash
# Check all pods are running
kubectl get pods -n argocd

# Expected output:
# NAME                                  READY   STATUS    RESTARTS   AGE
# argocd-application-controller-xxx     1/1     Running   0          2m
# argocd-dex-server-xxx                1/1     Running   0          2m
# argocd-redis-xxx                      1/1     Running   0          2m
# argocd-repo-server-xxx               1/1     Running   0          2m
# argocd-server-xxx                    1/1     Running   0          2m
```

### Step 2.4: Get ArgoCD Admin Password

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
echo
```

**Save this password!** You'll need it to login to ArgoCD UI.

**Username:** `admin`

### Step 2.5: Access ArgoCD UI

**Option A: Port Forward (Recommended for testing)**

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

- Open browser: `https://localhost:8080`
- Accept the SSL certificate warning (click "Advanced" → "Proceed to localhost")
- **Username:** `admin`
- **Password:** (from Step 2.4)

**Option B: Expose via NodePort**

```bash
# Change service type to NodePort
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort"}}'

# Get the NodePort
kubectl get svc argocd-server -n argocd

# Access via: https://<node-ip>:<nodeport>
```

### Step 2.6: Create GitOps Namespace

```bash
kubectl create namespace gitops
kubectl get namespace gitops
```

---

## Part 3: Configure ArgoCD via GUI

### Step 3.1: Login to ArgoCD UI

1. **Access ArgoCD UI** (from Step 2.5)
2. **Login:**
   - Username: `admin`
   - Password: (from Step 2.4)

### Step 3.2: Connect GitHub Repository

1. **Go to Settings:**
   - Click **"Settings"** (gear icon) in left sidebar
   - Click **"Repositories"**

2. **Connect Repository:**
   - Click **"Connect Repo"** button (top right)

3. **Configure Repository:**
   - **Type**: `git`
   - **Project**: `default`
   - **Repository URL**: `https://github.com/tarek-code/IVOLVE-TAKS.git`
   - **Username**: Your GitHub username (e.g., `tarek-code`)
   - **Password**: Your GitHub **Personal Access Token** (same one from Part 1)
   - **Skip Server Verification**: Check this (for HTTPS)
   - **Enable LFS**: Leave unchecked

4. **Click "Connect"**

5. **Verify Connection:**
   - You should see a green checkmark ✅
   - Status should be "Successful"

### Step 3.3: Create ArgoCD Application

1. **Go to Applications:**
   - Click **"Applications"** in left sidebar
   - Click **"+ New App"** button

2. **General Settings:**
   - **Application Name**: `jenkins-app-gitops`
   - **Project Name**: `default`
   - **Sync Policy**: 
     - ✅ Check **"Auto-Create Namespace"**
     - ✅ Check **"Auto-Sync"**
     - ✅ Check **"Self-Heal"**
     - ✅ Check **"Prune Resources"**

3. **Source Configuration:**
   - **Repository URL**: `https://github.com/tarek-code/IVOLVE-TAKS.git`
   - **Revision**: `main` (or your branch name)
   - **Path**: `04-GitOps/task-25`

4. **Destination Configuration:**
   - **Cluster URL**: `https://kubernetes.default.svc` (or select from dropdown)
   - **Namespace**: `gitops`

5. **Click "Create"**

### Step 3.4: Verify Application Created

1. **View Application:**
   - You should see `jenkins-app-gitops` in the Applications list
   - Click on it to view details

2. **Check Sync Status:**
   - **Status**: Should show `Synced` (green) or `OutOfSync` (yellow)
   - If `OutOfSync`, click **"Sync"** button

3. **View Resources:**
   - Click on the application
   - You should see the deployment tree
   - Verify `jenkins-app` deployment is present

### Step 3.5: Configure Auto-Sync (if not already enabled)

1. **Go to Application:**
   - Click on `jenkins-app-gitops`

2. **Click "App Details"** (or settings icon)

3. **Sync Policy:**
   - Click **"Enable Auto-Sync"**
   - Check:
     - ✅ **"Auto-Create Namespace"**
     - ✅ **"Self-Heal"**
     - ✅ **"Prune Resources"**

4. **Click "Save"**

---

## Part 4: Configure Jenkins Pipeline

### Step 4.1: Create Pipeline Job

1. **Jenkins Dashboard:**
   - Click **"New Item"**

2. **Create Pipeline:**
   - **Name**: `gitops-pipeline`
   - **Type**: **Pipeline**
   - Click **"OK"**

### Step 4.2: Configure Pipeline

1. **Pipeline Definition:**
   - **Definition**: **Pipeline script from SCM**
   - **SCM**: **Git**
   - **Repository URL**: `https://github.com/tarek-code/IVOLVE-TAKS.git`
   - **Credentials**: Select `github-credentials` (or leave empty if public)
   - **Branch**: `*/main`
   - **Script Path**: `04-GitOps/task-25/Jenkinsfile`

2. **Click "Save"**

### Step 4.3: Configure Environment Variables (Optional)

1. **Go to Pipeline Configuration:**
   - Click on `gitops-pipeline`
   - Click **"Configure"**

2. **Add Environment Variables:**
   - Scroll to **"Pipeline"** section
   - You can add:
     - `DOCKERHUB_USERNAME`: Your Docker Hub username
     - `GIT_REPO_URL`: `https://github.com/tarek-code/IVOLVE-TAKS.git` (already in Jenkinsfile)
     - `GIT_BRANCH`: `main` (already in Jenkinsfile)

3. **Click "Save"**

---

## Part 5: Test the Complete Workflow

### Step 5.1: Run Jenkins Pipeline

1. **Trigger Build:**
   - Go to `gitops-pipeline` job
   - Click **"Build Now"**

2. **Monitor Pipeline:**
   - Watch console output
   - Verify all stages complete:
     - ✅ BuildApp
     - ✅ BuildImage
     - ✅ PushImage
     - ✅ RemoveImageLocally
     - ✅ UpdateDeploymentYaml
     - ✅ PushToGitHub

### Step 5.2: Verify Git Update

1. **Check GitHub:**
   - Go to: https://github.com/tarek-code/IVOLVE-TAKS
   - Navigate to: `04-GitOps/task-25/deployment.yaml`
   - Verify image tag was updated (e.g., `your-username/jenkins-app:1`)

### Step 5.3: Verify ArgoCD Auto-Sync

1. **Check ArgoCD UI:**
   - Go to ArgoCD UI
   - Click on `jenkins-app-gitops` application
   - **Status** should show `Synced` (green)
   - **Last Sync** should show recent timestamp

2. **Check Kubernetes:**
   ```bash
   # Check deployment
   kubectl get deployment jenkins-app -n gitops
   
   # Check pods
   kubectl get pods -n gitops -l app=jenkins-app
   
   # Verify image tag
   kubectl get deployment jenkins-app -n gitops -o jsonpath='{.spec.template.spec.containers[0].image}'
   ```

---

## Troubleshooting

### Jenkins Cannot Push to GitHub

**Problem:** Pipeline fails at "PushToGitHub" stage

**Solutions:**
1. Verify GitHub credentials ID is `github-credentials`
2. Check Personal Access Token has `repo` scope
3. Verify token hasn't expired
4. Check repository URL is correct in Jenkinsfile

### ArgoCD Cannot Access Repository

**Problem:** Repository shows "Connection failed" in ArgoCD

**Solutions:**
1. Verify Personal Access Token is correct
2. Check repository URL is correct
3. Ensure "Skip Server Verification" is checked (for HTTPS)
4. Test connection manually: `git clone https://github.com/tarek-code/IVOLVE-TAKS.git`

### ArgoCD Application Not Syncing

**Problem:** Application shows "OutOfSync"

**Solutions:**
1. Click **"Sync"** button manually
2. Check path is correct: `04-GitOps/task-25`
3. Verify `deployment.yaml` exists in repository
4. Check ArgoCD logs: `kubectl logs -n argocd deployment/argocd-application-controller`

---

## Summary Checklist

- [ ] GitHub Personal Access Token created
- [ ] GitHub credentials added to Jenkins (`github-credentials`)
- [ ] ArgoCD installed in `argocd` namespace
- [ ] ArgoCD admin password retrieved
- [ ] ArgoCD UI accessible (port-forward or NodePort)
- [ ] GitHub repository connected in ArgoCD
- [ ] ArgoCD Application created (`jenkins-app-gitops`)
- [ ] Auto-sync enabled in ArgoCD
- [ ] `gitops` namespace created
- [ ] Jenkins pipeline job created (`gitops-pipeline`)
- [ ] Pipeline runs successfully
- [ ] ArgoCD auto-syncs and deploys

---

**You're all set!** The GitOps workflow is now configured and ready to use.
