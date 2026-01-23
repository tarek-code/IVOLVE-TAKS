# IVOLVE Task 25 - GitOps Workflow with ArgoCD

This lab demonstrates how to implement a **GitOps workflow** using **ArgoCD** for continuous deployment. Jenkins builds and pushes Docker images, updates Git repositories, and ArgoCD automatically deploys changes to Kubernetes.

---

## 🎯 Lab Objectives

By the end of this lab, you will:

1. ✅ Understand GitOps principles and workflow
2. ✅ Install and configure ArgoCD in Kubernetes
3. ✅ Create a Jenkins pipeline that updates Git repositories
4. ✅ Configure ArgoCD to watch Git and auto-deploy
5. ✅ Validate the complete GitOps workflow

---

## 📋 Requirements

- ✅ Jenkins Master running (from Lab 22)
- ✅ Jenkins Agent/Slave configured (from Lab 23)
- ✅ Shared Library configured (from Lab 23)
- ✅ Kubernetes cluster access
- ✅ Docker Hub account
- ✅ GitHub account with repository access
- ✅ Git installed on Jenkins agent

---

## 🔍 What is GitOps?

**GitOps** is a methodology where:

- **Git is the single source of truth** for infrastructure and application configurations
- **Automated tools** (like ArgoCD) watch Git repositories
- **Changes in Git trigger automatic deployments** to Kubernetes
- **No manual kubectl commands** needed for deployments

### GitOps Workflow

```
┌─────────────────────────────────────────────────────────┐
│  1. Developer pushes code to Git                         │
│     ↓                                                     │
│  2. Jenkins Pipeline:                                    │
│     ├─ Builds application                                │
│     ├─ Builds Docker image                               │
│     ├─ Pushes image to Docker Hub                        │
│     ├─ Updates deployment.yaml in Git                    │
│     └─ Pushes updated deployment.yaml to Git            │
│     ↓                                                     │
│  3. ArgoCD detects Git change                             │
│     ↓                                                     │
│  4. ArgoCD automatically deploys to Kubernetes           │
│                                                           │
└─────────────────────────────────────────────────────────┘
```

---

## 📖 Quick Setup Guide

**For detailed step-by-step instructions, see [SETUP-GUIDE.md](SETUP-GUIDE.md)**

The setup guide includes:

- ✅ **Part 1**: Configure Jenkins GitHub Access (Personal Access Token)
- ✅ **Part 2**: Install ArgoCD Manually (with commands)
- ✅ **Part 3**: Configure ArgoCD via GUI (screenshots and steps)
- ✅ **Part 4**: Configure Jenkins Pipeline
- ✅ **Part 5**: Test the Complete Workflow

---

## 🚀 Step-by-Step Guide

### Step 1: Install ArgoCD in Kubernetes

**Where:** Kubernetes cluster

**What:** Install ArgoCD using the installation script

1. **Run the installation script:**

   ```bash
   cd 03-Continues-Integration/task-25
   chmod +x argocd-install.sh
   ./argocd-install.sh
   ```

   Or manually:

   ```bash
   # Create argocd namespace
   kubectl create namespace argocd

   # Install ArgoCD
   kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

   # Wait for pods to be ready
   kubectl wait --for=condition=ready pod --all -n argocd --timeout=300s
   ```
2. **Verify ArgoCD installation:**

   ```bash
   kubectl get pods -n argocd
   ```

   You should see:

   ```
   NAME                                  READY   STATUS    RESTARTS   AGE
   argocd-application-controller-xxx    1/1     Running   0          2m
   argocd-dex-server-xxx                1/1     Running   0          2m
   argocd-redis-xxx                      1/1     Running   0          2m
   argocd-repo-server-xxx               1/1     Running   0          2m
   argocd-server-xxx                     1/1     Running   0          2m
   ```
3. **Access ArgoCD UI:**

   **Option A: Port Forward (Recommended for testing)**

   ```bash
   kubectl port-forward svc/argocd-server -n argocd 8080:443
   ```

   - Access: `https://localhost:8080`
   - Username: `admin`
   - Password: Get with:
     ```bash
     kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
     echo
     ```

   **Option B: Expose via NodePort**

   ```bash
   kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort"}}'
   kubectl get svc argocd-server -n argocd
   # Access via NodePort (e.g., https://<node-ip>:<nodeport>)
   ```

---

### Step 2: Create GitOps Namespace

**Where:** Kubernetes cluster

**What:** Create namespace where ArgoCD will deploy applications

```bash
cd 03-Continues-Integration/task-25
chmod +x create-gitops-namespace.sh
./create-gitops-namespace.sh
```

Or manually:

```bash
kubectl create namespace gitops
kubectl get namespace gitops
```

---

### Step 3: Prepare Git Repository

**Where:** Your GitHub repository

**What:** Ensure your repository has the deployment.yaml file

1. **Clone your repository** (or use existing IVOLVE-TAKS):

   ```bash
   git clone https://github.com/YOUR_USERNAME/YOUR_REPO.git
   cd YOUR_REPO
   ```
2. **Ensure deployment.yaml exists:**

   - Copy `03-Continues-Integration/task-25/deployment.yaml` to your repository
   - Or ensure it's already in the repository at: `03-Continues-Integration/task-25/deployment.yaml`
3. **Commit and push:**

   ```bash
   git add 03-Continues-Integration/task-25/deployment.yaml
   git commit -m "Add deployment.yaml for GitOps"
   git push origin main
   ```

---

### Step 4: Configure Jenkins Pipeline

**Where:** Jenkins Master (Web UI)

**What:** Create a pipeline job for GitOps workflow

#### 4.1 Create Pipeline Job

1. **Go to Jenkins Dashboard:**

   - Click **New Item**
2. **Create Pipeline:**

   - **Name**: `gitops-pipeline`
   - **Type**: Select **Pipeline**
   - Click **OK**

#### 4.2 Configure Pipeline

1. **Pipeline Definition:**

   - **Definition**: **Pipeline script from SCM**
   - **SCM**: **Git**
   - **Repository URL**: Your GitOps repository URL (e.g., `https://github.com/YOUR_USERNAME/YOUR_REPO.git`)
   - **Credentials**: Add GitHub credentials if repository is private
   - **Branch**: `*/main` (or your branch name)
   - **Script Path**: `03-Continues-Integration/task-25/Jenkinsfile`
2. **Environment Variables (Optional):**

   - Go to **Pipeline** → **Environment Variables**
   - Add if needed:
     - `GIT_REPO_URL`: Your GitOps repository URL
     - `GIT_BRANCH`: Branch name (default: `main`)
     - `APP_REPO_URL`: Application repository URL (if different from GitOps repo)
3. **Configure Credentials:**

   **Docker Hub Credentials:**

   - Go to **Manage Jenkins** → **Credentials** → **System** → **Global credentials**
   - Add **Username with password**
   - **ID**: `dockerhub-credentials`
   - **Username**: Your Docker Hub username
   - **Password**: Your Docker Hub password

   **GitHub Credentials:**

   - Add **Username with password**
   - **ID**: `github-credentials`
   - **Username**: Your GitHub username
   - **Password**: Your GitHub personal access token (not password!)
4. **Click Save**

#### 4.3 Update Jenkinsfile (if needed)

If your repository structure is different, update the `Jenkinsfile`:

```groovy
environment {
    DOCKERHUB_USER = "${env.DOCKERHUB_USERNAME ?: 'your-username'}"
    DOCKERHUB_REPO = "${DOCKERHUB_USER}/jenkins-app"
    IMAGE_TAG = "${env.BUILD_NUMBER}"
    GIT_REPO_URL = "https://github.com/YOUR_USERNAME/YOUR_REPO.git"  // Update this!
    GIT_BRANCH = "main"
    DEPLOYMENT_FILE = "03-Continues-Integration/task-25/deployment.yaml"
}
```

---

### Step 5: Configure ArgoCD Application

**Where:** Kubernetes cluster (using kubectl or ArgoCD UI)

**What:** Create ArgoCD Application to watch your Git repository

#### Option A: Using kubectl (Recommended)

1. **Update argocd-application.yaml:**

   ```bash
   cd 03-Continues-Integration/task-25
   # Edit argocd-application.yaml and update:
   # - repoURL: Your GitOps repository URL
   # - targetRevision: Your branch name (e.g., main)
   # - path: Path to deployment.yaml in repository
   ```
2. **Apply ArgoCD Application:**

   ```bash
   kubectl apply -f argocd-application.yaml
   ```
3. **Verify application created:**

   ```bash
   kubectl get application -n argocd
   ```

#### Option B: Using ArgoCD UI

1. **Access ArgoCD UI** (from Step 1)
2. **Create New Application:**

   - Click **+ New App**
   - **Application Name**: `jenkins-app-gitops`
   - **Project Name**: `default`
   - **Sync Policy**: **Automatic** (check boxes for auto-sync and self-heal)
3. **Source Configuration:**

   - **Repository URL**: Your GitOps repository URL
   - **Revision**: `main` (or your branch)
   - **Path**: `04-GitOps/task-25`
4. **Destination Configuration:**

   - **Cluster URL**: `https://kubernetes.default.svc`
   - **Namespace**: `gitops`
5. **Click Create**

---

### Step 6: Run the Pipeline

**Where:** Jenkins Master (Web UI)

**What:** Trigger the pipeline and observe GitOps workflow

1. **Run the pipeline:**

   - Go to `gitops-pipeline` job
   - Click **Build Now**
2. **Monitor pipeline execution:**

   - Watch console output
   - Verify each stage completes:
     - ✅ BuildApp
     - ✅ BuildImage
     - ✅ PushImage
     - ✅ RemoveImageLocally
     - ✅ UpdateDeploymentYaml
     - ✅ PushToGitHub

   ![Jenkins Pipeline Complete](screenshots/kenkins-is-done.png)
3. **Verify Git update:**

   ```bash
   # Check your repository on GitHub
   # deployment.yaml should have new image tag
   git pull origin main
   cat 03-Continues-Integration/task-25/deployment.yaml | grep image:
   ```

---

### Step 7: Validate ArgoCD Deployment

**Where:** ArgoCD UI and Kubernetes cluster

**What:** Verify ArgoCD detected the change and deployed automatically

#### 7.1 Check ArgoCD UI

1. **Access ArgoCD UI** (from Step 1)
2. **View Application:**

   - Click on `jenkins-app-gitops` application
   - You should see:
     - **Sync Status**: `Synced` (green)
     - **Health Status**: `Healthy` (green)
     - **Last Sync**: Recent timestamp

   ![ArgoCD Application Synced](screenshots/argocd-is-synced.png)
3. **View Application Details:**

   - Click on the application
   - See the deployment tree
   - Verify `jenkins-app` deployment is present

#### 7.2 Check Kubernetes Cluster

```bash
# Check deployment in gitops namespace
kubectl get deployment jenkins-app -n gitops

# Check pods
kubectl get pods -n gitops -l app=jenkins-app

# Check service
kubectl get svc jenkins-app -n gitops

# Describe deployment to see image
kubectl describe deployment jenkins-app -n gitops | grep Image
```

**Expected output:**

```
NAME          READY   UP-TO-DATE   AVAILABLE   AGE
jenkins-app   2/2     2            2           5m

NAME                           READY   STATUS    RESTARTS   AGE
jenkins-app-xxx-xxx            1/1     Running   0          5m
jenkins-app-xxx-xxx            1/1     Running   0          5m
```

![Deployment in GitOps Namespace](screenshots/deployment-is-in-gitops-namespace.png)

#### 7.3 Verify Image Tag

```bash
# Check the image tag matches the build number
kubectl get deployment jenkins-app -n gitops -o jsonpath='{.spec.template.spec.containers[0].image}'
# Should show: your-username/jenkins-app:BUILD_NUMBER
```

---

## 🔍 How It Works

### Complete GitOps Flow

```
┌─────────────────────────────────────────────────────────┐
│  Step 1: Jenkins Pipeline                              │
│  ├─ Checkout application source code                    │
│  ├─ Build application                                   │
│  ├─ Build Docker image (tag: BUILD_NUMBER)             │
│  ├─ Push image to Docker Hub                           │
│  ├─ Remove image locally                               │
│  ├─ Update deployment.yaml with new image tag          │
│  └─ Commit & push to Git                                │
│     ↓                                                    │
│  Step 2: Git Repository Updated                        │
│  └─ deployment.yaml now has:                            │
│     image: your-username/jenkins-app:BUILD_NUMBER      │
│     ↓                                                    │
│  Step 3: ArgoCD Detects Change                         │
│  ├─ ArgoCD polls Git (or uses webhook)                 │
│  ├─ Detects deployment.yaml change                     │
│  └─ Compares Git state with cluster state              │
│     ↓                                                    │
│  Step 4: ArgoCD Syncs (Auto-Deploys)                   │
│  ├─ Applies deployment.yaml to Kubernetes               │
│  ├─ Creates/updates Deployment resource                │
│  ├─ Creates/updates Service resource                   │
│  └─ Pods are created with new image                    │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

### Key Components

1. **Jenkins Pipeline:**

   - Builds and pushes Docker images
   - Updates Git repository (deployment.yaml)
   - **Does NOT deploy directly to Kubernetes**
2. **Git Repository:**

   - Contains deployment.yaml with image tags
   - **Single source of truth** for desired state
3. **ArgoCD:**

   - Watches Git repository
   - Compares Git state with cluster state
   - Automatically syncs when changes detected
   - **Handles all Kubernetes deployments**

---

## 📊 Pipeline Stages

The Jenkinsfile implements these stages:

1. **Checkout** - Clones application source and GitOps repository
2. **BuildApp** - Builds the application (Maven/Node.js/etc.)
3. **BuildImage** - Builds Docker image with build number tag
4. **PushImage** - Pushes image to Docker Hub
5. **RemoveImageLocally** - Cleans up local image
6. **UpdateDeploymentYaml** - Updates image tag in deployment.yaml
7. **PushToGitHub** - Commits and pushes updated deployment.yaml

---

## 🎯 Key Features

1. **Git as Source of Truth:**

   - All deployment configurations in Git
   - Version controlled and auditable
2. **Automatic Deployment:**

   - ArgoCD automatically deploys when Git changes
   - No manual kubectl commands needed
3. **Separation of Concerns:**

   - Jenkins: Build and push images, update Git
   - ArgoCD: Deploy to Kubernetes
4. **Self-Healing:**

   - ArgoCD can detect drift and auto-sync
   - Ensures cluster matches Git state
5. **Rollback Capability:**

   - Revert Git commit to rollback deployment
   - ArgoCD will sync to previous state

---

## ✅ Verification Checklist

Before running the pipeline, verify:

- [ ] ArgoCD installed and running in `argocd` namespace
- [ ] ArgoCD UI accessible (port-forward or NodePort)
- [ ] `gitops` namespace created
- [ ] Git repository has `deployment.yaml` file
- [ ] Jenkins pipeline job created
- [ ] Docker Hub credentials configured in Jenkins
- [ ] GitHub credentials configured in Jenkins
- [ ] ArgoCD Application created and synced
- [ ] Jenkinsfile updated with correct repository URLs

---

## 🐛 Troubleshooting

### ArgoCD Not Installing

**Problem:** ArgoCD pods not starting

**Solution:**

1. Check cluster resources: `kubectl top nodes`
2. Check pod events: `kubectl describe pod <pod-name> -n argocd`
3. Check logs: `kubectl logs <pod-name> -n argocd`
4. Ensure enough resources available

### ArgoCD Application Not Syncing

**Problem:** Application shows "OutOfSync" or "Unknown"

**Solution:**

1. Check repository URL is correct
2. Verify path to deployment.yaml is correct
3. Check ArgoCD can access repository (no authentication issues)
4. View application logs in ArgoCD UI
5. Manually sync: Click **Sync** button in ArgoCD UI

### Jenkins Pipeline Fails on Git Push

**Problem:** "PushToGitHub" stage fails

**Solution:**

1. Verify GitHub credentials are correct
2. Use Personal Access Token (not password) for GitHub
3. Check repository permissions
4. Verify branch name is correct
5. Check Git configuration in pipeline

### Deployment Not Updating

**Problem:** ArgoCD synced but pods still using old image

**Solution:**

1. Check deployment.yaml was actually updated in Git
2. Verify ArgoCD detected the change (check sync status)
3. Check pod image: `kubectl describe pod <pod-name> -n gitops | grep Image`
4. Force sync in ArgoCD UI
5. Check if image pull policy is correct

### Image Pull Errors

**Problem:** Pods fail with "ImagePullBackOff"

**Solution:**

1. Verify image exists in Docker Hub
2. Check image name and tag are correct
3. Verify Docker Hub credentials if using private repo
4. Check network connectivity to Docker Hub

---

## 📝 File Structure

```
task-25/
├── Jenkinsfile                    # GitOps pipeline definition
├── deployment.yaml                 # Kubernetes deployment (updated by pipeline)
├── argocd-application.yaml        # ArgoCD application manifest
├── argocd-install.sh             # ArgoCD installation script
├── create-gitops-namespace.sh     # Namespace creation script
├── README.md                      # This file
└── screenshots/                   # Screenshots directory
    ├── argocd-is-synced.png      # ArgoCD application synced status
    ├── deployment-is-in-gitops-namespace.png  # Deployment in gitops namespace
    └── kenkins-is-done.png        # Jenkins pipeline completed successfully
```

---

## 🔧 Configuration Details

### Jenkinsfile Environment Variables

```groovy
DOCKERHUB_USER      // Docker Hub username
DOCKERHUB_REPO      // Docker Hub repository path
IMAGE_TAG           // Image tag (build number)
GIT_REPO_URL        // GitOps repository URL
GIT_BRANCH          // Branch to push updates to
DEPLOYMENT_FILE     // Path to deployment.yaml in repo
```

### ArgoCD Application Configuration

```yaml
source:
  repoURL: https://github.com/YOUR_USERNAME/YOUR_REPO.git
  targetRevision: main
  path: 03-Continues-Integration/task-25

destination:
  server: https://kubernetes.default.svc
  namespace: gitops

syncPolicy:
  automated:
    prune: true
    selfHeal: true
```

---

## 🚀 Quick Start (5 Steps)

### Step 1: Install ArgoCD

```bash
cd 03-Continues-Integration/task-25
chmod +x argocd-install.sh
./argocd-install.sh
```

### Step 2: Create Namespace

```bash
chmod +x create-gitops-namespace.sh
./create-gitops-namespace.sh
```

### Step 3: Configure ArgoCD Application

```bash
# Edit argocd-application.yaml with your repo URL
kubectl apply -f argocd-application.yaml
```

### Step 4: Configure Jenkins Pipeline

1. Create pipeline job: `gitops-pipeline`
2. Configure SCM: Point to your GitOps repository
3. Script Path: `03-Continues-Integration/task-25/Jenkinsfile`
4. Add Docker Hub and GitHub credentials

### Step 5: Run Pipeline

1. Click **Build Now** in Jenkins
2. Wait for pipeline to complete
3. Check ArgoCD UI - application should auto-sync
4. Verify deployment: `kubectl get pods -n gitops`

---

## 📚 Summary

This lab demonstrates:

1. ✅ **GitOps Workflow** - Git as single source of truth
2. ✅ **ArgoCD Installation** - Continuous deployment tool
3. ✅ **Jenkins Integration** - Build, push, update Git
4. ✅ **Automatic Deployment** - ArgoCD syncs from Git
5. ✅ **Separation of Concerns** - CI (Jenkins) vs CD (ArgoCD)

---

## 🎓 Next Steps

- Configure ArgoCD webhooks for faster sync
- Implement multi-environment GitOps (dev/stag/prod)
- Add ArgoCD RBAC for team access control
- Set up ArgoCD notifications (Slack/Email)
- Implement GitOps best practices (branching strategy)
- Add health checks and sync windows

---

## 📚 Related Labs

- **Lab 22**: Jenkins Setup and Basic Pipeline
- **Lab 23**: Jenkins Agents and Shared Libraries
- **Lab 24**: Multi Branch CI/CD Workflow
- **Lab 25**: GitOps Workflow with ArgoCD (this lab)

---

## License

See the LICENSE file in the parent directory for license information.
