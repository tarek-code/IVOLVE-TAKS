# IVOLVE Task 24 - Multi Branch CI/CD Workflow

This lab demonstrates how to create a **Multi Branch Pipeline** in Jenkins that automatically deploys to different Kubernetes namespaces based on the Git branch.

---

## 🎯 Lab Objectives

By the end of this lab, you will:

1. ✅ Understand Multi Branch Pipelines in Jenkins
2. ✅ Set up branch-based deployments to different Kubernetes namespaces
3. ✅ Configure automatic branch detection and namespace mapping
4. ✅ Use shared libraries in a multi-branch context
5. ✅ Deploy applications to prod/stag/dev environments automatically

---

## 📋 Requirements

- ✅ Jenkins Master running (from Lab 22)
- ✅ Jenkins Agent/Slave configured (from Lab 23)
- ✅ Shared Library configured (from Lab 23)
- ✅ Kubernetes cluster access
- ✅ Docker Hub account
- ✅ Git repository with access

---

## 🚀 Step-by-Step Guide

### Step 1: Prepare Git Repository with Multiple Branches

**Where:** Your Git repository

**What:** Clone the repository, add Dockerfile, and create 3 branches

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Ibrahim-Adel15/Jenkins_App.git
   cd Jenkins_App
   ```
   
   **Important:** This repository should contain **only the application code** (Dockerfile, pom.xml, src/, Jenkinsfile), NOT the entire IVOLVE-TAKS lab repository.

2. **Verify required files exist:**
   ```bash
   ls -la
   # Should see: Dockerfile, pom.xml, src/, Jenkinsfile
   
   # If Dockerfile doesn't exist, copy from task-24/Jenkins_App/Dockerfile
   # If Jenkinsfile doesn't exist, copy from task-24/Jenkinsfile
   ```
   
   **Each branch should contain:**
   - ✅ Dockerfile
   - ✅ Jenkinsfile
   - ✅ pom.xml (or package.json)
   - ✅ src/ (application source code)
   - ❌ NOT the entire IVOLVE-TAKS repository
   - ❌ NOT task-22/, task-23/, task-24/ folders

3. **Create and push branches:**
   ```bash
   # Ensure you're on main/master branch
   git checkout main  # or master
   
   # Create and checkout dev branch
   git checkout -b dev
   git push -u origin dev
   
   # Create and checkout stag branch
   git checkout main
   git checkout -b stag
   git push -u origin stag
   
   # Create and checkout prod branch
   git checkout main
   git checkout -b prod
   git push -u origin prod
   
   # Verify all branches
   git branch -a
   ```

4. **Verify branches on GitHub:**
   - Go to your repository on GitHub
   - Click on the branch dropdown
   - You should see: `main`, `dev`, `stag`, `prod`

---

### Step 2: Create Kubernetes Namespaces

**Where:** Kubernetes cluster

**What:** Create 3 namespaces for different environments

1. **Apply namespace YAML:**
   ```bash
   kubectl apply -f namespaces.yaml
   ```

2. **Verify namespaces are created:**
   ```bash
   kubectl get namespaces | grep -E "prod|stag|dev"
   ```

   You should see:
   ```
   NAME   STATUS   AGE
   dev    Active   1m
   prod   Active   1m
   stag   Active   1m
   ```

3. **Verify namespace labels:**
   ```bash
   kubectl get namespace prod stag dev --show-labels
   ```

---

### Step 3: Configure Multi Branch Pipeline in Jenkins

**Where:** Jenkins Master (Web UI)

**What:** Create a Multi Branch Pipeline job

1. **Go to Jenkins Dashboard:**
   - Click **New Item**

2. **Create Multi Branch Pipeline:**
   - **Name**: `jenkins-app-multibranch`
   - **Type**: Select **Multibranch Pipeline**
   - Click **OK**

3. **Configure Branch Sources:**
   - **Branch Sources**: Click **Add source** → **Git**
   - **Project Repository**: `https://github.com/Ibrahim-Adel15/Jenkins_App.git`
   - **Credentials**: Add if repository is private
   - **Behaviors**: 
     - Click **Add** → **Discover branches**
     - **Strategy**: **All branches**
     - Click **Add** → **Filter by name (with wildcards)**
       - **Include**: `prod`, `stag`, `dev`, `main` (or `master`)
       - **Exclude**: Leave empty
   - **Build Configuration**:
     - **Mode**: **by Jenkinsfile**
     - **Script Path**: `Jenkinsfile` (or `03-Continues-Integration/task-24/Jenkinsfile` if in subdirectory)

4. **Configure Build Triggers:**
   - **Build periodically**: Check if you want scheduled builds
   - **Poll SCM**: Check and set interval (e.g., `H/5 * * * *` for every 5 minutes)
   - Or use **GitHub webhooks** (recommended for automatic builds)

5. **Configure Orphaned Item Strategy:**
   - **Orphaned Item Strategy**: Check **Discard old items**
   - **Days to keep old items**: `7`
   - **Max # of old items to keep**: `10`

6. **Click Save**

---

### Step 4: Verify Jenkins Agent is Configured

**Where:** Jenkins Master (Web UI)

**What:** Ensure Jenkins agent is available for the pipeline

1. **Check agent status:**
   - Go to **Manage Jenkins** → **System Configuration** → **Nodes**
   - Verify `jenkins-agent` is **Connected** (green icon)

2. **If agent is not configured:**
   - Follow instructions from **Lab 23** to set up the Jenkins agent
   - Use the same `jenkins-agent-config.yaml` from task-23

---

### Step 5: Verify Shared Library is Configured

**Where:** Jenkins Master (Web UI)

**What:** Ensure shared library is configured (from Lab 23)

1. **Check shared library configuration:**
   - Go to **Manage Jenkins** → **Configure System**
   - Scroll to **Global Trusted Pipeline Libraries**
   - Verify `ivolve-shared-library` is configured
   - **Library Path**: `03-Continues-Integration/task-23/shared-library` (if using Git)
   - **Default version**: `main`

2. **If not configured:**
   - Follow instructions from **Lab 23** Step 2

---

### Step 6: Run the Multi Branch Pipeline

**Where:** Jenkins Master (Web UI)

**What:** Trigger the pipeline and verify branch-based deployments

1. **Scan repository:**
   - Go to your Multi Branch Pipeline job: `jenkins-app-multibranch`
   - Click **Scan Multibranch Pipeline Now** (or wait for automatic scan)
   - Wait for scan to complete

2. **Verify branches are detected:**
   - After scan, you should see branches listed:
     - `prod`
     - `stag`
     - `dev`
     - `main` (or `master`)

3. **Run pipeline for each branch:**
   - Click on a branch (e.g., `dev`)
   - Click **Build Now**
   - Watch the pipeline execute
   - Check console output to verify:
     - Branch name is detected
     - Correct namespace is selected
     - Deployment happens to the right namespace

4. **Verify deployments:**
   ```bash
   # Check dev namespace
   kubectl get deployment jenkins-app -n dev
   kubectl get pods -n dev -l app=jenkins-app
   
   # Check stag namespace
   kubectl get deployment jenkins-app -n stag
   kubectl get pods -n stag -l app=jenkins-app
   
   # Check prod namespace
   kubectl get deployment jenkins-app -n prod
   kubectl get pods -n prod -l app=jenkins-app
   ```

---

## 🔍 How It Works

### Branch to Namespace Mapping

The `Jenkinsfile` automatically maps branches to namespaces:

```groovy
K8S_NAMESPACE = "${env.BRANCH_NAME == 'prod' ? 'prod' : 
                 (env.BRANCH_NAME == 'stag' ? 'stag' : 
                 (env.BRANCH_NAME == 'dev' ? 'dev' : 'default'))}"
```

- **`prod` branch** → deploys to **`prod` namespace**
- **`stag` branch** → deploys to **`stag` namespace**
- **`dev` branch** → deploys to **`dev` namespace**
- **Other branches** → deploys to **`default` namespace**

### Image Tagging

Images are tagged with branch name and build number:
- **`prod-1`**, **`prod-2`**, etc. for prod branch
- **`stag-1`**, **`stag-2`**, etc. for stag branch
- **`dev-1`**, **`dev-2`**, etc. for dev branch

This makes it easy to track which branch and build number each image came from.

---

## 📊 Pipeline Flow

```
┌─────────────────────────────────────────────────────────┐
│  Multi Branch Pipeline                                  │
│                                                          │
│  1. Scan Repository                                     │
│     ↓                                                    │
│  2. Detect Branches (prod/stag/dev)                     │
│     ↓                                                    │
│  3. For Each Branch:                                     │
│     ├─ Checkout Branch                                  │
│     ├─ RunUnitTest                                      │
│     ├─ BuildApp                                         │
│     ├─ BuildImage (tag: branch-buildNumber)             │
│     ├─ ScanImage                                        │
│     ├─ PushImage                                        │
│     ├─ RemoveImageLocally                               │
│     └─ DeployOnK8s (to branch-specific namespace)       │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

---

## 🎯 Key Features

1. **Automatic Branch Detection:**
   - Jenkins automatically detects all branches
   - Creates separate pipeline jobs for each branch

2. **Environment-Specific Deployments:**
   - Each branch deploys to its corresponding namespace
   - Isolated environments (prod/stag/dev)

3. **Shared Library Reuse:**
   - Uses the same shared library from Lab 23
   - All 7 functions work across all branches

4. **Agent-Based Execution:**
   - All pipelines run on Jenkins agent
   - Parallel execution possible for different branches

5. **Image Traceability:**
   - Images tagged with branch name and build number
   - Easy to identify which branch/deployment

---

## 🔧 Configuration Details

### Jenkinsfile Environment Variables

```groovy
BRANCH_NAME        // Automatically set by Jenkins (e.g., 'prod', 'stag', 'dev')
K8S_NAMESPACE     // Mapped from BRANCH_NAME
IMAGE_TAG         // Format: branch-buildNumber (e.g., 'prod-1', 'dev-5')
DOCKERHUB_REPO    // Docker Hub repository path
```

### Namespace Mapping Logic

```groovy
K8S_NAMESPACE = "${env.BRANCH_NAME == 'prod' ? 'prod' : 
                 (env.BRANCH_NAME == 'stag' ? 'stag' : 
                 (env.BRANCH_NAME == 'dev' ? 'dev' : 'default'))}"
```

---

## ✅ Verification Checklist

Before running the pipeline, verify:

- [ ] Git repository has 3 branches: `prod`, `stag`, `dev`
- [ ] Dockerfile exists in the repository
- [ ] Kubernetes namespaces created: `prod`, `stag`, `dev`
- [ ] Multi Branch Pipeline job created in Jenkins
- [ ] Branch sources configured correctly
- [ ] Jenkins agent is connected
- [ ] Shared library is configured
- [ ] Docker Hub credentials configured
- [ ] Jenkinsfile is in the repository root (or correct path specified)

---

## 🐛 Troubleshooting

### Branches Not Detected

**Problem:** Multi Branch Pipeline doesn't show branches

**Solution:**
1. Check repository URL is correct
2. Verify credentials if repository is private
3. Check branch filter settings
4. Click **Scan Multibranch Pipeline Now** manually
5. Check Jenkins logs: **Manage Jenkins** → **System Log**

### Wrong Namespace Selected

**Problem:** Deployment goes to wrong namespace

**Solution:**
1. Check `BRANCH_NAME` environment variable in console output
2. Verify namespace mapping logic in Jenkinsfile
3. Ensure branch names match exactly: `prod`, `stag`, `dev` (case-sensitive)

### Deployment Fails

**Problem:** Deployment stage fails

**Solution:**
1. Check if namespace exists: `kubectl get namespace prod stag dev`
2. Verify RBAC permissions for Jenkins service account
3. Check agent pod has kubectl access
4. Review deployment logs in console output

### Shared Library Not Found

**Problem:** `@Library('ivolve-shared-library@main') _` fails

**Solution:**
1. Verify shared library is configured in Jenkins UI
2. Check Library Path is correct if using Git
3. Ensure branch `main` exists in shared library repository
4. Check Jenkins logs for library loading errors

---

## 📝 Summary

This lab demonstrates:

1. ✅ **Multi Branch Pipelines** - Automatic branch detection and pipeline creation
2. ✅ **Environment Isolation** - Separate namespaces for prod/stag/dev
3. ✅ **Branch-Based Deployment** - Automatic namespace selection based on branch
4. ✅ **Shared Library Usage** - Reusing functions from Lab 23
5. ✅ **Agent-Based Execution** - All pipelines run on Jenkins agent
6. ✅ **Image Traceability** - Branch name in image tags

---

## 🎓 Next Steps

- Add environment-specific configuration (config maps, secrets)
- Implement branch protection rules
- Add approval gates for production deployments
- Set up monitoring and alerting per environment
- Implement blue-green or canary deployments

---

## 📚 Related Labs

- **Lab 22**: Jenkins Setup and Basic Pipeline
- **Lab 23**: Jenkins Agents and Shared Libraries
- **Lab 24**: Multi Branch CI/CD Workflow (this lab)

---

## License

See the LICENSE file in the parent directory for license information.
