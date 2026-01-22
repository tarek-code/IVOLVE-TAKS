# IVOLVE Task 22 - Jenkins Pipeline for Application Deployment

This lab is part of the IVOLVE training program. It demonstrates how to create a **Jenkins CI/CD pipeline** that automates the complete application deployment workflow: from unit testing to building Docker images, pushing to Docker Hub, and deploying to Kubernetes.

## Lab Overview

In this lab you:

- **Clone** source code and Dockerfile from GitHub
- **Set up Jenkins** (in a container or on a VM)
- **Create a Jenkins Pipeline** that automates:
  1. Run Unit Tests
  2. Build Application
  3. Build Docker Image
  4. Push Image to Docker Hub
  5. Delete Image Locally
  6. Update `deployment.yaml` with New Image
  7. Deploy to Kubernetes Cluster
- **Configure Pipeline Post Actions** (always, success, failure)

## Prerequisites

- **Kubernetes cluster** (from previous tasks)
- **Docker** installed and running
- **Docker Hub account** (for pushing images)
- **kubectl** configured to access your cluster
- **Namespace `ivolve`** exists (from Task 11)
- **Pod limit/quota** set appropriately (at least 5 pods to allow deployment of 2 replicas)

## Project Structure

```
task-22/
├── Jenkinsfile                    # Jenkins Pipeline definition
├── deployment.yaml                # Kubernetes deployment template
├── jenkins-deployment.yaml        # (Optional) Run Jenkins in K8s
├── docker-compose-jenkins.yml     # (Optional) Run Jenkins with Docker Compose
├── README.md
└── screenshots/
    ├── dockerhub-image-tags.png
    └── pipline-success.png
```

## Why Run Jenkins in a Container?

**Yes, running Jenkins in a container is highly recommended for this lab!** Benefits:

- **Isolated environment**: Easy to set up and tear down
- **Consistent setup**: Same Jenkins version across different machines
- **Docker-in-Docker**: Can build Docker images from within Jenkins
- **Portability**: Move Jenkins between environments easily
- **Resource management**: Better control over CPU/memory usage

## Setup Options

You have **three options** to run Jenkins:

### Option 1: Jenkins in Kubernetes (Recommended for K8s Lab)

Deploy Jenkins as a pod in your Kubernetes cluster:

```bash
kubectl apply -f jenkins-deployment.yaml
```

**Access Jenkins:**
- Get NodePort: `kubectl get svc -n jenkins`
- Access via: `http://<node-ip>:30080`

**Get initial admin password:**
```bash
kubectl exec -it -n jenkins deployment/jenkins -- cat /var/jenkins_home/secrets/initialAdminPassword
```

### Option 2: Jenkins with Docker Compose (Easiest)

Run Jenkins using Docker Compose:

```bash
docker-compose -f docker-compose-jenkins.yml up -d
```

**Access Jenkins:**
- URL: `http://localhost:8080`

**Get initial admin password:**
```bash
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

### Option 3: Jenkins on VM/Host

Install Jenkins directly on your VM:

```bash
# On CentOS/RHEL
sudo yum install -y java-11-openjdk
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
sudo yum install -y jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins
```

**Access Jenkins:**
- URL: `http://<vm-ip>:8080`

## Step-by-Step Instructions

### Step 1: Set Up Jenkins

Choose one of the setup options above and start Jenkins.

**Initial Setup (First Time):**

1. Access Jenkins UI (based on your setup option)
2. Enter the initial admin password (from the commands above)
3. Install suggested plugins
4. Create admin user (or skip to use admin/admin)
5. Configure Jenkins URL

### Step 2: Install Required Jenkins Plugins

Go to **Manage Jenkins** → **Manage Plugins** → **Available** and install:

- **Pipeline** (usually pre-installed)
- **Pipeline: Declarative** (for declarative pipeline syntax)
- **Docker Pipeline** (for Docker commands)
- **Kubernetes CLI** (for kubectl)
- **Git** (for SCM)
- **Credentials** (for storing secrets)

**Note:** If plugins fail to install due to network issues, see the [Plugin Installation Troubleshooting](#plugin-installation-troubleshooting) section below.

### Step 3: Configure Jenkins Credentials

Go to **Manage Jenkins** → **Manage Credentials** → **Global** → **Add Credentials**

#### 3.1 Docker Hub Credentials

1. **Kind**: Username with password
2. **ID**: `dockerhub-credentials`
3. **Username**: Your Docker Hub username
4. **Password**: Your Docker Hub password/token
5. **Description**: Docker Hub credentials

#### 3.2 Docker Hub Username (Separate)

1. **Kind**: Secret text
2. **ID**: `dockerhub-username`
3. **Secret**: Your Docker Hub username (e.g., `yourusername`)
4. **Description**: Docker Hub username

#### 3.3 Kubernetes kubeconfig

1. **Kind**: Secret file
2. **ID**: `kubeconfig`
3. **File**: Upload your `~/.kube/config` file
4. **Description**: Kubernetes kubeconfig

**Alternative:** If running Jenkins in K8s, you can use the ServiceAccount instead (see `jenkins-deployment.yaml`).

### Step 4: Configure Docker Access in Jenkins

If Jenkins is running in a container, ensure it can access Docker:

**For Docker Compose:**
- Already configured via volume mount: `/var/run/docker.sock:/var/run/docker.sock`

**For Kubernetes:**
- Already configured via `hostPath` volume in `jenkins-deployment.yaml`

**For VM/Host:**
- Add Jenkins user to docker group:
  ```bash
  sudo usermod -aG docker jenkins
  sudo systemctl restart jenkins
  ```

### Step 5: Create Jenkins Pipeline Job

1. Go to **New Item**
2. Enter name: `jenkins-app-pipeline`
3. Select **Pipeline**
4. Click **OK**

### Step 6: Configure Pipeline

In the pipeline configuration:

1. **Pipeline Definition**: Select **Pipeline script from SCM**
2. **SCM**: Select **Git**
3. **Repository URL**: `https://github.com/Ibrahim-Adel15/Jenkins_App.git`
4. **Branches to build**: `*/main` or `*/master`
5. **Script Path**: `Jenkinsfile` (or the path where your Jenkinsfile is in the repo)
6. Click **Save**

**Note:** If your Jenkinsfile is not in the repo, you can:
- Copy the `Jenkinsfile` from this task to the repo, OR
- Use **Pipeline script** and paste the Jenkinsfile content directly (see [Pipeline Configuration Options](#pipeline-configuration-options) below)

### Step 7: Update deployment.yaml

Before running the pipeline, update `deployment.yaml`:

1. Clone the repository locally:
   ```bash
   git clone https://github.com/Ibrahim-Adel15/Jenkins_App.git
   cd Jenkins_App
   ```

2. Copy `deployment.yaml` from this task to the repo:
   ```bash
   cp /path/to/task-22/deployment.yaml .
   ```

3. Edit `deployment.yaml` and replace `YOUR_DOCKERHUB_USERNAME` with your actual Docker Hub username:
   ```yaml
   image: yourusername/jenkins-app:latest
   ```

4. Commit and push:
   ```bash
   git add deployment.yaml
   git commit -m "Add deployment.yaml"
   git push
   ```

**Note:** The pipeline will automatically create `deployment.yaml` if it doesn't exist in the repository.

### Step 8: Run the Pipeline

1. Go to your pipeline job: `jenkins-app-pipeline`
2. Click **Build Now**
3. Watch the pipeline execution in **Build History**

### Step 9: Verify Deployment

After the pipeline completes successfully:

```bash
# Check deployment
kubectl get deployment jenkins-app -n ivolve

# Check pods
kubectl get pods -n ivolve -l app=jenkins-app

# Check service
kubectl get svc jenkins-app-service -n ivolve

# View logs
kubectl logs -n ivolve -l app=jenkins-app --tail=50
```

## Jenkinsfile Explanation

The `Jenkinsfile` defines a declarative pipeline with the following stages:

### Stage 1: Checkout
- Clones the source code from GitHub
- Handles both "Pipeline script from SCM" and "Pipeline script" modes

### Stage 2: Unit Tests
- Detects the application type (Node.js, Java/Maven, Python)
- Runs appropriate test command (`mvn test`, `npm test`, `pytest`)
- Uses Maven installed in Jenkins container or Maven Docker container

### Stage 3: Build App
- Builds the application (npm install, mvn package, etc.)
- Uses Maven installed in Jenkins container or Maven Docker container

### Stage 4: Build Docker Image
- Builds Docker image using Dockerfile from repo
- Tags with build number and `latest`

### Stage 5: Push to Docker Hub
- Logs into Docker Hub using credentials
- Pushes both tagged images

### Stage 6: Delete Local Image
- Removes local Docker images to save space

### Stage 7: Update Deployment YAML
- Creates `deployment.yaml` if it doesn't exist
- Uses `sed` to replace image tag in existing `deployment.yaml`
- Updates with new build number

### Stage 8: Deploy to Kubernetes
- Creates namespace if it doesn't exist
- Applies `deployment.yaml` to the cluster
- Waits for rollout to complete (with timeout)
- Shows deployment and pod status

### Post Actions
- **always**: Runs cleanup (`deleteDir()`) and logs completion message
- **success**: Logs success message when pipeline succeeds
- **failure**: Logs failure message when pipeline fails

## Deployment Files Explanation

### Two Different Deployments for Two Different Purposes

#### 1. `jenkins-deployment.yaml` - Deploys Jenkins (The CI/CD Tool)

**Purpose:** Run Jenkins itself in Kubernetes

**What it deploys:**
- Jenkins CI/CD server (the tool that runs pipelines)
- Image: `jenkins/jenkins:lts`
- Namespace: `jenkins`
- Includes:
  - Jenkins pod
  - ServiceAccount with RBAC permissions
  - PersistentVolumeClaim (for Jenkins data)
  - Service (NodePort on 30080)
  - Maven and kubectl installation in startup script

**When to use:**
- If you want to run Jenkins in Kubernetes (Option 1 from README)
- One-time setup to get Jenkins running

**Command:**
```bash
kubectl apply -f jenkins-deployment.yaml
```

**Result:** Jenkins UI accessible at `http://<node-ip>:30080`

#### 2. `deployment.yaml` - Deploys Your Application

**Purpose:** Deploy the application that Jenkins builds

**What it deploys:**
- Your application from `https://github.com/Ibrahim-Adel15/Jenkins_App.git`
- Image: `YOUR_DOCKERHUB_USERNAME/jenkins-app:BUILD_NUMBER` (updated by pipeline)
- Namespace: `ivolve`
- Includes:
  - Application deployment (2 replicas)
  - Service (ClusterIP)

**When to use:**
- This file is used BY Jenkins pipeline
- Jenkins updates the image tag in this file
- Jenkins applies this file to deploy your app

**Command:** (Usually done by Jenkins pipeline)
```bash
kubectl apply -f deployment.yaml -n ivolve
```

**Result:** Your application running in Kubernetes

### Workflow

```
1. Deploy Jenkins (one-time setup)
   kubectl apply -f jenkins-deployment.yaml
   ↓
   Jenkins is now running

2. Jenkins Pipeline runs:
   - Builds your app
   - Creates Docker image
   - Pushes to Docker Hub
   - Updates deployment.yaml with new image tag
   - Applies deployment.yaml to deploy your app
   ↓
   Your application is now running

3. Result:
   - Jenkins pod running in "jenkins" namespace
   - Your app pods running in "ivolve" namespace
```

### Why Both Are Needed?

| File | Deploys | Namespace | Purpose | Who Uses It |
|------|---------|-----------|---------|-------------|
| `jenkins-deployment.yaml` | Jenkins CI/CD tool | `jenkins` | Run Jenkins | You (one-time) |
| `deployment.yaml` | Your application | `ivolve` | Deploy your app | Jenkins pipeline (every build) |

**Summary:**
- **`jenkins-deployment.yaml`** = Deploy the CI/CD tool (Jenkins)
- **`deployment.yaml`** = Deploy your application (what Jenkins builds)

Both are needed because:
1. You need Jenkins to run pipelines → `jenkins-deployment.yaml`
2. Jenkins needs to deploy your app → `deployment.yaml`

## Ports Explanation

This section explains all ports used in the Jenkins CI/CD lab.

### Port Summary Table

| Port            | Service               | Type         | Access                                               | Purpose                                          |
| --------------- | --------------------- | ------------ | ---------------------------------------------------- | ------------------------------------------------ |
| **8080**  | Jenkins UI            | Container/VM | `http://localhost:8080` or `http://<vm-ip>:8080` | Jenkins web interface                            |
| **30080** | Jenkins UI (K8s)      | NodePort     | `http://<node-ip>:30080`                           | Jenkins web interface when running in Kubernetes |
| **50000** | Jenkins Agent (JNLP)  | Container/VM | Internal                                             | Communication between Jenkins master and agents  |
| **3000**  | Application Container | Container    | Internal                                             | Your application runs on this port               |
| **80**    | Application Service   | ClusterIP    | Internal (via Service)                               | Kubernetes service exposes app on port 80        |

### Detailed Port Explanations

#### 1. Jenkins Ports

##### Port 8080 - Jenkins Web UI

**Where used:**
- `docker-compose-jenkins.yml`: `"8080:8080"`
- `jenkins-deployment.yaml`: `containerPort: 8080` (inside container)

**Purpose:**
- Jenkins web interface/UI
- Access Jenkins dashboard, configure jobs, view builds

**Access:**
- **Docker Compose**: `http://localhost:8080`
- **VM/Host**: `http://<vm-ip>:8080`
- **Kubernetes**: Not directly accessible on 8080 (use NodePort 30080 instead)

##### Port 30080 - Jenkins Web UI (NodePort)

**Where used:**
- `jenkins-deployment.yaml`: `nodePort: 30080` in Service

**Purpose:**
- Exposes Jenkins UI when running in Kubernetes
- NodePort service type allows external access

**Access:**
- `http://<any-node-ip>:30080`
- Works from outside the cluster

**Why needed:**
- When Jenkins runs in a pod, port 8080 is only accessible inside the cluster
- NodePort makes it accessible from outside the cluster

##### Port 50000 - Jenkins Agent Communication (JNLP)

**Where used:**
- `docker-compose-jenkins.yml`: `"50000:50000"`
- `jenkins-deployment.yaml`: `containerPort: 50000` (inside container)

**Purpose:**
- **JNLP (Java Web Start Agent Protocol)** communication
- Jenkins master communicates with Jenkins agents/slaves
- Used for distributed builds

**Access:**
- Internal only (between Jenkins master and agents)
- Not meant for direct user access

**When needed:**
- When using Jenkins agents/slaves (Labs 23-24)
- For distributed build execution

#### 2. Application Ports

##### Port 3000 - Application Container Port

**Where used:**
- `deployment.yaml`: `containerPort: 3000`

**Purpose:**
- Your application listens on this port inside the container
- Common for Node.js applications (Express, NestJS, etc.)
- The app from `https://github.com/Ibrahim-Adel15/Jenkins_App.git` runs here

**Access:**
- Internal to the pod only
- Not directly accessible from outside

**Health Checks:**
- Liveness probe: `http://<pod-ip>:3000/`
- Readiness probe: `http://<pod-ip>:3000/`

##### Port 80 - Application Service Port

**Where used:**
- `deployment.yaml`: Service `port: 80`, `targetPort: 3000`

**Purpose:**
- Kubernetes Service exposes your app on port 80
- Maps to container port 3000 (`targetPort: 3000`)
- Standard HTTP port (more user-friendly than 3000)

**Access:**
- Via Service: `http://jenkins-app-service.ivolve.svc.cluster.local`
- Internal cluster access only (ClusterIP)
- Can be accessed from within the cluster

**Port Mapping:**
```
Service Port 80 → Container Port 3000
```

**To access from within cluster:**
```bash
# Port-forward to test locally
kubectl port-forward -n ivolve svc/jenkins-app-service 8081:80
# Access: http://localhost:8081

# Or from another pod in cluster
curl http://jenkins-app-service.ivolve.svc.cluster.local
```

### Port Flow Diagrams

#### Jenkins Access Flow (Kubernetes)

```
External User
    ↓
<node-ip>:30080  (NodePort)
    ↓
Jenkins Service (port 8080)
    ↓
Jenkins Pod (containerPort: 8080)
    ↓
Jenkins Web UI
```

#### Application Access Flow

```
Inside Kubernetes Cluster
    ↓
jenkins-app-service:80  (ClusterIP Service)
    ↓
Port 80 → targetPort 3000
    ↓
Application Pod (containerPort: 3000)
    ↓
Your Application (Node.js/Express/etc.)
```

### Port Conflict Resolution

#### If Port 8080 is Already in Use

**Docker Compose:**
```yaml
ports:
  - "8081:8080"  # Use different host port
```

**VM/Host:**
- Change Jenkins port: Edit `/etc/sysconfig/jenkins` → `JENKINS_PORT=8081`
- Or use a different VM/port

**Kubernetes:**
- Change NodePort: `nodePort: 30081` in Service

#### If Port 3000 is Already in Use

**Application:**
- Change `containerPort: 3001` in `deployment.yaml`
- Update Service `targetPort: 3001`
- Update app code to listen on new port

### Security Considerations

| Port         | Should be Exposed?            | Firewall Rule                  |
| ------------ | ----------------------------- | ------------------------------ |
| 8080         | Yes (Jenkins UI)              | Allow from trusted IPs only    |
| 30080        | Yes (Jenkins UI via NodePort) | Allow from trusted IPs only    |
| 50000        | No (Internal)                 | Block from external access     |
| 3000         | No (Internal)                 | Only accessible via Service    |
| 80 (Service) | No (Internal)                 | Only accessible within cluster |

### Quick Reference

**Jenkins Ports:**
- **8080**: Jenkins web UI (Docker Compose / VM)
- **30080**: Jenkins web UI (Kubernetes NodePort)
- **50000**: Jenkins agent communication (JNLP)

**Application Ports:**
- **3000**: Application container port (your app listens here)
- **80**: Kubernetes Service port (exposes app internally)

## Jenkins RBAC Permissions

This section explains what Kubernetes permissions Jenkins needs for Labs 22, 23, and 24.

### Lab 22: Jenkins Pipeline for Application Deployment

**Required Permissions:**

| Task | K8s Permission Needed | Covered? |
|------|---------------------|----------|
| 1. Clone source code | None (Git) | ✅ |
| 2. Run Unit Test | None (local/test) | ✅ |
| 3. Build App | None (local build) | ✅ |
| 4. Build Docker image | None (Docker) | ✅ |
| 5. Push to Docker Hub | None (Docker Hub) | ✅ |
| 6. Delete image locally | None (local Docker) | ✅ |
| 7. Edit deployment.yaml | None (file edit) | ✅ |
| 8. **Deploy to K8s** | **create/update deployments, services** | ✅ |

**Key Permission:** `deployments` and `services` - **CREATE, UPDATE, PATCH**

### Current Jenkins RBAC Role Breakdown

The `jenkins-deployer` ClusterRole includes:

#### Core Resources (apiGroups: "")
- **pods**: get, list, watch, create, update, patch, delete
- **services**: get, list, watch, create, update, patch, delete
- **configmaps**: get, list, watch, create, update, patch, delete (for app configs)
- **secrets**: get, list, watch, create, update, patch, delete (for image pull secrets)
- **namespaces**: get, list, watch, create, update, patch, delete (for Lab 24)
- **pods/log**: get, list (for viewing logs)
- **events**: get, list, watch (for debugging)

#### Apps Resources (apiGroups: "apps")
- **deployments**: get, list, watch, create, update, patch, delete
- **deployments/scale**: get, update, patch (for scaling)
- **deployments/status**: get, update, patch (for rollout status)
- **statefulsets**: get, list, watch, create, update, patch, delete (if needed)
- **daemonsets**: get, list, watch, create, update, patch, delete (if needed)

### Why ClusterRoleBinding (Not RoleBinding)?

**ClusterRoleBinding** is used because:

1. **Lab 24 requires multi-namespace deployment** (prod/stag/dev)
2. Jenkins needs to deploy to **any namespace** dynamically
3. More flexible for future pipelines

If you want to restrict Jenkins to specific namespaces only, you could:
- Use **RoleBinding** in each namespace (prod, stag, dev, ivolve)
- But this is less flexible for Lab 24

### Verification Commands

Test if Jenkins has the required permissions:

```bash
# As Jenkins ServiceAccount
kubectl auth can-i create deployments --as=system:serviceaccount:jenkins:jenkins --all-namespaces
# Should return: yes

kubectl auth can-i create services --as=system:serviceaccount:jenkins:jenkins --all-namespaces
# Should return: yes

kubectl auth can-i create namespaces --as=system:serviceaccount:jenkins:jenkins
# Should return: yes

# Test in specific namespace
kubectl auth can-i create deployments --as=system:serviceaccount:jenkins:jenkins -n prod
# Should return: yes
```

### Summary

✅ **Lab 22**: Fully covered - can deploy to ivolve namespace  
✅ **Lab 23**: Fully covered - can deploy to any namespace  
✅ **Lab 24**: Fully covered - can create namespaces and deploy to prod/stag/dev

The enhanced `jenkins-deployer` ClusterRole provides all necessary permissions for all three labs!

## Pipeline Configuration Options

### The Error You Might Get

```
ERROR: 'checkout scm' is only available when using "Multibranch Pipeline" or "Pipeline script from SCM"
```

This happens when you use **"Pipeline script"** (pasting Jenkinsfile) instead of **"Pipeline script from SCM"** (pointing to Git).

### Two Ways to Configure Pipeline

#### Option 1: Pipeline script from SCM (Recommended)

**Configuration:**
1. Go to your pipeline job → **Configure**
2. **Pipeline Definition**: Select **"Pipeline script from SCM"**
3. **SCM**: Select **Git**
4. **Repository URL**: `https://github.com/Ibrahim-Adel15/Jenkins_App.git`
5. **Branches to build**: `*/main` or `*/master`
6. **Script Path**: `Jenkinsfile` (or path to your Jenkinsfile in repo)

**How it works:**
- Jenkins clones the repo
- Reads the Jenkinsfile from the repo
- `checkout scm` works automatically

**Pros:**
- ✅ Jenkinsfile is version controlled
- ✅ Changes to Jenkinsfile trigger new builds
- ✅ `checkout scm` works
- ✅ Best practice

**Cons:**
- ❌ Jenkinsfile must be in the repo

#### Option 2: Pipeline script (Pasted)

**Configuration:**
1. Go to your pipeline job → **Configure**
2. **Pipeline Definition**: Select **"Pipeline script"**
3. Paste the Jenkinsfile content directly

**How it works:**
- Jenkinsfile is stored in Jenkins (not in Git)
- No automatic repo cloning
- `checkout scm` **doesn't work** (causes the error you saw)

**Pros:**
- ✅ Quick to test
- ✅ Don't need Jenkinsfile in repo

**Cons:**
- ❌ Jenkinsfile not version controlled
- ❌ `checkout scm` doesn't work (must clone manually)
- ❌ Not best practice

### Fixed Jenkinsfile

The updated Jenkinsfile now handles **both options**:

```groovy
stage('Checkout') {
    steps {
        script {
            try {
                checkout scm  // Works if using "Pipeline script from SCM"
            } catch (Exception e) {
                // Falls back to manual clone if using "Pipeline script"
                sh "git clone https://github.com/Ibrahim-Adel15/Jenkins_App.git"
            }
        }
    }
}
```

All subsequent stages use `dir()` to work in the correct directory.

### Which Should You Use?

**For Lab 22, use Option 1 (Pipeline script from SCM):**

1. **Put Jenkinsfile in your repo:**
   ```bash
   cd Jenkins_App
   # Copy Jenkinsfile to repo
   cp /path/to/task-22/Jenkinsfile .
   git add Jenkinsfile
   git commit -m "Add Jenkinsfile"
   git push
   ```

2. **Configure Jenkins:**
   - Pipeline Definition: **Pipeline script from SCM**
   - Repository URL: `https://github.com/Ibrahim-Adel15/Jenkins_App.git`
   - Script Path: `Jenkinsfile`

3. **Run pipeline** - `checkout scm` will work!

### Summary

| Configuration | `checkout scm` | Jenkinsfile Location | Best Practice? |
|---------------|----------------|---------------------|----------------|
| **Pipeline script from SCM** | ✅ Works | In Git repo | ✅ Yes |
| **Pipeline script** (pasted) | ❌ Doesn't work | In Jenkins | ⚠️ No (but works) |

**Recommendation:** Use **"Pipeline script from SCM"** for Lab 22!

## Customizing the Pipeline

### Adjust for Your Application Type

**For Node.js:**
- Tests: `npm test`
- Build: `npm run build`

**For Java/Maven:**
- Tests: `mvn test`
- Build: `mvn clean package`

**For Python:**
- Tests: `pytest` or `python -m unittest`
- Build: `pip install -r requirements.txt`

### Change Image Name

Edit the `DOCKERHUB_REPO` environment variable in the Jenkinsfile:

```groovy
DOCKERHUB_REPO = "${DOCKERHUB_USER}/your-app-name"
```

### Change Kubernetes Namespace

Edit the `K8S_NAMESPACE` environment variable:

```groovy
K8S_NAMESPACE = 'your-namespace'
```

## Troubleshooting

This section covers all common errors and their solutions encountered during Lab 22.

### Pipeline Fails at "Build Docker Image"

**Problem:** Jenkins cannot access Docker.

**Solution:**
- If Jenkins is in a container, ensure Docker socket is mounted
- If Jenkins is in Kubernetes, verify `hostPath` volumes in `jenkins-deployment.yaml`:
  - `/var/run/docker.sock` (socket)
  - `/usr/bin/docker` (Docker CLI binary)
- If Jenkins is on a VM, add Jenkins user to docker group:
  ```bash
  sudo usermod -aG docker jenkins
  sudo systemctl restart jenkins
  ```

### Pipeline Fails at "Push to Docker Hub"

**Problem:** Authentication failed.

**Solution:**
- Verify Docker Hub credentials in Jenkins
- Check that the credential ID matches: `dockerhub-credentials`
- Test login manually: `docker login`

### Pipeline Fails at "Deploy to Kubernetes"

**Problem:** kubectl not found or kubeconfig incorrect.

**Solution:**
- Verify kubeconfig credential is uploaded correctly
- If Jenkins is in K8s, ensure ServiceAccount has proper RBAC permissions
- Test kubectl access manually from Jenkins pod/container
- Verify `kubectl` is installed in Jenkins container (see `jenkins-deployment.yaml`)

### deployment.yaml Not Updated

**Problem:** `sed` command didn't match the image line.

**Solution:**
- The pipeline automatically creates `deployment.yaml` if it doesn't exist
- If updating existing file, check the exact format of the image line in `deployment.yaml`
- Adjust the `sed` pattern in the Jenkinsfile if needed:
  ```groovy
  sh """
    sed -i 's|image:.*jenkins-app.*|image: ${imageName}|g' deployment.yaml
  """
  ```

### Unit Tests Always Pass

**Problem:** Tests are skipped or not running.

**Solution:**
- The pipeline uses `|| true` to not fail on missing test commands
- Remove `|| true` if you want tests to be mandatory
- Add specific test commands for your app type

### Pipeline Stuck at "kubectl rollout status"

**Problem:** Deployment rollout is taking too long or pods are not becoming ready.

**Solution:**
- Check pod status: `kubectl get pods -n ivolve -l app=jenkins-app`
- Check pod events: `kubectl describe pod <pod-name> -n ivolve`
- Verify pod limit/quota is sufficient (at least 5 pods to allow 2 replicas)
- Check if image is pulling correctly: `kubectl describe pod <pod-name> -n ivolve | grep -i image`
- The pipeline now includes a timeout (300 seconds) and will show status even if rollout times out

### Jenkins Pipeline Errors

#### Error 1: `No such DSL method 'cleanWs' found`

**Problem:** The `cleanWs()` method requires the **Workspace Cleanup** plugin, which is not installed.

**Fix Applied:** Replaced `cleanWs()` with `deleteDir()` which is a built-in Jenkins step.

**Before:**
```groovy
post {
    always {
        cleanWs()  // ❌ Requires plugin
    }
}
```

**After:**
```groovy
post {
    always {
        deleteDir()  // ✅ Built-in step
    }
}
```

#### Error 2: `ERROR: kubeconfig`

**Problem:** The `credentials('kubeconfig')` in the `environment` block fails because:
1. The credential might not exist
2. File credentials can't be used directly in `environment` block like that
3. The credential ID might be wrong

**Fix Applied:** Removed `KUBECONFIG = credentials('kubeconfig')` from environment and used `withCredentials` block instead (which is the correct way).

**Before:**
```groovy
environment {
    KUBECONFIG = credentials('kubeconfig')  // ❌ Doesn't work for file credentials
}
```

**After:**
```groovy
stage('Deploy to Kubernetes') {
    steps {
        script {
            try {
                withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG_FILE')]) {
                    // ✅ Correct way to use file credentials
                }
            } catch (Exception e) {
                // Fallback to ServiceAccount if Jenkins is in K8s
            }
        }
    }
}
```

### Verify Docker CLI in Jenkins Container

**Step 1: Verify Docker CLI Works**

Run this command to check if Docker CLI is accessible in the Jenkins container:
```bash
kubectl exec -it -n jenkins deployment/jenkins -- docker --version
```

**Expected output:**
```
Docker version 24.x.x or similar
```

**Step 2: Test Docker Command**

Test if Docker can communicate with the Docker daemon:
```bash
kubectl exec -it -n jenkins deployment/jenkins -- docker ps
```

**Expected output:**
```
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS   PORTS   NAMES
```
(Shows running containers, or empty if none)

**Step 3: Test Maven Docker Container**

Test if Jenkins can run Maven Docker container:
```bash
kubectl exec -it -n jenkins deployment/jenkins -- docker run --rm maven:3.9-eclipse-temurin-17 mvn --version
```

**Expected output:**
```
Apache Maven 3.9.x
Maven home: /usr/share/maven
Java version: ...
```

**Step 4: Run Jenkins Pipeline**

If all above commands work, your Jenkins pipeline should now work!

1. Go to Jenkins UI: `http://<node-ip>:30080`
2. Open your pipeline: `jenkins-app-pipeline`
3. Click **"Build Now"** or **"Run"**
4. Watch the console output

The pipeline should now:
- ✅ Clone repository
- ✅ Run unit tests (using Maven Docker container)
- ✅ Build app (using Maven Docker container)
- ✅ Build Docker image
- ✅ Push to Docker Hub
- ✅ Deploy to Kubernetes

**Troubleshooting:**
- If `docker --version` fails: Check pod logs: `kubectl logs -n jenkins deployment/jenkins`
- Verify volume mount: `kubectl describe pod -n jenkins -l app=jenkins | grep -A 5 "docker-bin"`
- If pipeline still fails: Check Jenkins console output for specific error

### Plugin Installation Troubleshooting

#### Network Timeout Errors

**What Happened?**
Some plugins failed to download due to **network timeout errors**:
- `java.net.SocketTimeoutException: Connect timed out`
- This means Jenkins couldn't connect to the update center to download plugins

**Status Check:**

**✅ Successfully Installed (Critical for Lab 22):**
- ✅ **Pipeline: Step API** - Core pipeline functionality
- ✅ **Pipeline: API** - Pipeline core APIs
- ✅ **Pipeline: Build Step** - Build steps
- ✅ **Pipeline: SCM Step** - Git/SCM integration
- ✅ **Pipeline: Groovy** - Groovy script support
- ✅ **Pipeline: Model API** - Pipeline models
- ✅ **Pipeline: Stage Step** - Stage steps
- ✅ **Pipeline: Job** - Pipeline jobs

**❌ Failed Plugins (But Not Critical for Basic Lab 22):**
- ❌ **Folders** - Organization (nice to have, not required)
- ❌ **Credentials** - Storing secrets (important but can work around)
- ❌ **Plain Credentials** - Depends on Credentials
- ❌ **SSH Credentials** - Depends on Credentials
- ❌ **Credentials Binding** - Depends on Credentials
- ❌ **Pipeline: Groovy Libraries** - Depends on Folders

**⏳ Pending Plugins:**
- ⏳ **Pipeline: Declarative** - Important! (still pending)
- ⏳ **Pipeline** - Main pipeline plugin (still pending)
- ⏳ **Pipeline: Basic Steps** - Basic pipeline steps (still pending)

**Is This OK for Lab 22?**

**Partially OK, but you should fix it:**

1. **You can proceed** if the pending plugins finish installing
2. **You need to manually install** the failed plugins, especially:
   - **Credentials** (for Docker Hub and kubeconfig)
   - **Pipeline: Declarative** (if it doesn't finish)
   - **Git** plugin (for cloning repos)

**Solutions:**

**Solution 1: Wait and Retry (Easiest)**
1. **Wait for pending plugins** to finish installing
2. **Check if Pipeline and Pipeline: Declarative** install successfully
3. If they fail, proceed to Solution 2

**Solution 2: Manual Plugin Installation**

**Step 1: Install Missing Plugins Manually**
1. Go to **Manage Jenkins** → **Manage Plugins** → **Available**
2. Search for and install:
   - **Git** (for SCM)
   - **Docker Pipeline** (for Docker commands)
   - **Kubernetes CLI** (for kubectl)
   - **Credentials** (for storing secrets)
   - **Pipeline** (if not installed)
   - **Pipeline: Declarative** (if not installed)

**Step 2: If Download Still Fails - Use Manual Download**

**Option A: Download and Upload Manually**
1. Download plugins from: https://updates.jenkins.io/download/plugins/
2. Go to **Manage Jenkins** → **Manage Plugins** → **Advanced**
3. Scroll to **Upload Plugin**
4. Upload the `.hpi` files you downloaded

**Option B: Use Jenkins CLI**
```bash
# If Jenkins is in a container
docker exec jenkins wget https://updates.jenkins.io/download/plugins/git/latest/git.hpi -O /var/jenkins_home/plugins/git.jpi

# If Jenkins is in Kubernetes
kubectl exec -n jenkins deployment/jenkins -- wget https://updates.jenkins.io/download/plugins/git/latest/git.hpi -O /var/jenkins_home/plugins/git.jpi

# Restart Jenkins
```

**Solution 3: Fix Network Issues**

**If you're behind a proxy or firewall:**
1. Go to **Manage Jenkins** → **Manage Plugins** → **Advanced**
2. Set **HTTP Proxy Configuration** if needed
3. Or configure Jenkins to use a different update center

**Change Update Center URL:**
1. Go to **Manage Jenkins** → **Manage Plugins** → **Advanced**
2. Under **Update Site**, you can:
   - Use a mirror: `https://mirrors.jenkins.io/updates/update-center.json`
   - Or use a local update center

**Solution 4: Install Plugins via Jenkinsfile (Alternative)**

You can install plugins programmatically by creating a `plugins.txt`:
```groovy
// plugins.txt
git
docker-workflow
kubernetes-cli
credentials
pipeline-stage-view
```

Then use a Jenkins init script or install them via Jenkins CLI.

**Minimum Required Plugins for Lab 22:**

| Plugin | Status | Critical? |
|--------|--------|------------|
| **Pipeline** | ⏳ Pending | ✅ **YES** |
| **Pipeline: Declarative** | ⏳ Pending | ✅ **YES** |
| **Git** | ❓ Unknown | ✅ **YES** |
| **Docker Pipeline** | ❓ Unknown | ✅ **YES** |
| **Kubernetes CLI** | ❓ Unknown | ✅ **YES** |
| **Credentials** | ❌ Failed | ⚠️ **Recommended** |

**Quick Check: Can You Proceed?**

**Test if Pipeline works:**
1. Go to **New Item**
2. Try to create a **Pipeline** job
3. If you see "Pipeline" option → ✅ You can proceed!
4. If not → ❌ Need to install Pipeline plugin

**Test if Git works:**
1. In pipeline configuration, try to select **Git** as SCM
2. If Git option appears → ✅ Git is installed
3. If not → ❌ Need to install Git plugin

**Recommended Action Plan:**
1. **Wait 5-10 minutes** for pending plugins to finish
2. **Check if Pipeline and Pipeline: Declarative** installed
3. **Manually install** these if missing:
   - Git
   - Docker Pipeline
   - Kubernetes CLI
   - Credentials (for storing Docker Hub password)
4. **Restart Jenkins** after installing plugins
5. **Test** by creating a simple pipeline job

**Restart Jenkins:**

**Docker Compose:**
```bash
docker restart jenkins
```

**Kubernetes:**
```bash
kubectl rollout restart deployment/jenkins -n jenkins
```

**VM/Host:**
```bash
sudo systemctl restart jenkins
```

**Alternative: Skip Plugin Installation for Now**

If you're having persistent network issues, you can:
1. **Use Jenkinsfile directly** (paste content, don't use SCM)
2. **Use kubectl from Jenkins pod** (if Jenkins is in K8s)
3. **Use Docker commands directly** (if Docker socket is mounted)

But this is less ideal - it's better to install the plugins.

#### Critical Plugin Fix

**These plugins are REQUIRED for Lab 22:**

1. ❌ **Pipeline** (workflow-aggregator) - **CRITICAL** - Cannot create pipeline jobs without this
2. ❌ **Pipeline: Declarative** - **CRITICAL** - Your Jenkinsfile uses declarative syntax
3. ❌ **cloudbees-folder** - **BLOCKER** - Blocks Pipeline: Groovy Libraries
4. ❌ **Pipeline: Groovy Libraries** - **BLOCKER** - Blocks Pipeline and Pipeline: Declarative
5. ❌ **Credentials** - **IMPORTANT** - Needed for Docker Hub and kubeconfig

**Solution: Manual Plugin Installation**

**Method A: Download and Upload (Recommended)**

1. Download plugins manually:
```bash
# Create a directory for plugins
mkdir -p ~/jenkins-plugins
cd ~/jenkins-plugins

# Download critical plugins (adjust versions if needed)
wget https://updates.jenkins.io/download/plugins/cloudbees-folder/latest/cloudbees-folder.hpi
wget https://updates.jenkins.io/download/plugins/credentials/latest/credentials.hpi
wget https://updates.jenkins.io/download/plugins/pipeline-groovy-lib/latest/pipeline-groovy-lib.hpi
wget https://updates.jenkins.io/download/plugins/pipeline-model-definition/latest/pipeline-model-definition.hpi
wget https://updates.jenkins.io/download/plugins/workflow-aggregator/latest/workflow-aggregator.hpi
wget https://updates.jenkins.io/download/plugins/git/latest/git.hpi
wget https://updates.jenkins.io/download/plugins/docker-workflow/latest/docker-workflow.hpi
wget https://updates.jenkins.io/download/plugins/kubernetes-cli/latest/kubernetes-cli.hpi
```

2. Upload to Jenkins:
   - Go to **Manage Jenkins** → **Manage Plugins** → **Advanced**
   - Scroll to **Upload Plugin**
   - Upload each `.hpi` file **one at a time** in this order:
     - `cloudbees-folder.hpi` (first!)
     - `credentials.hpi`
     - `pipeline-groovy-lib.hpi`
     - `pipeline-model-definition.hpi`
     - `workflow-aggregator.hpi`
     - `git.hpi`
     - `docker-workflow.hpi`
     - `kubernetes-cli.hpi`

3. Restart Jenkins after each critical plugin

**Method B: Copy to Jenkins Plugin Directory**

**If Jenkins is in Docker:**
```bash
docker cp cloudbees-folder.hpi jenkins:/var/jenkins_home/plugins/cloudbees-folder.jpi
docker cp credentials.hpi jenkins:/var/jenkins_home/plugins/credentials.jpi
# ... repeat for other plugins
docker restart jenkins
```

**If Jenkins is in Kubernetes:**
```bash
kubectl cp cloudbees-folder.hpi jenkins/<pod-name>:/var/jenkins_home/plugins/cloudbees-folder.jpi -n jenkins
kubectl cp credentials.hpi jenkins/<pod-name>:/var/jenkins_home/plugins/credentials.jpi -n jenkins
# ... repeat for other plugins
kubectl rollout restart deployment/jenkins -n jenkins
```

**If Jenkins is on VM/Host:**
```bash
sudo cp cloudbees-folder.hpi /var/lib/jenkins/plugins/cloudbees-folder.jpi
sudo cp credentials.hpi /var/lib/jenkins/plugins/credentials.jpi
# ... repeat for other plugins
sudo chown jenkins:jenkins /var/lib/jenkins/plugins/*.jpi
sudo systemctl restart jenkins
```

### Docker Socket Permission Denied

**Error:**
```
permission denied while trying to connect to the docker API at unix:///var/run/docker.sock
```

**Problem:**
The Jenkins container runs as `jenkins` user (UID 1000), but the Docker socket (`/var/run/docker.sock`) is owned by `root:docker` (GID 999), so the jenkins user can't access it.

**Solution:**
For a **lab environment**, run Jenkins as root to access the Docker socket. This is acceptable for learning/testing.

**Updated `jenkins-deployment.yaml`:**
- Added `securityContext.runAsUser: 0` (root) to the container
- Added `securityContext.fsGroup: 999` (docker group) to the pod

**Apply the Fix:**
```bash
# Apply updated deployment
kubectl apply -f jenkins-deployment.yaml

# Wait for pod to restart
kubectl get pods -n jenkins -w

# Verify Docker access works
kubectl exec -it -n jenkins deployment/jenkins -- docker ps
```

### Docker CLI Not Found

**Error:**
```
docker: not found
ERROR: script returned exit code 127
```

**Problem:**
The Jenkins container has the Docker socket mounted (`/var/run/docker.sock`) but **not the Docker CLI binary** (`docker` command).

**Solution:**
Mount the Docker CLI binary from the host into the Jenkins container.

**Updated jenkins-deployment.yaml:**
Added mount for Docker CLI binary:
```yaml
volumeMounts:
- name: docker-bin
  mountPath: /usr/bin/docker

volumes:
- name: docker-bin
  hostPath:
    path: /usr/bin/docker
    type: File
```

**Apply the Fix:**
```bash
# Apply updated deployment
kubectl apply -f jenkins-deployment.yaml

# Wait for pod to restart
kubectl get pods -n jenkins -w

# Verify Docker CLI is available
kubectl exec -it -n jenkins deployment/jenkins -- docker --version
```

### Maven Not Found in Jenkins

**Error:**
```
mvn: not found
ERROR: script returned exit code 127
```

**Problem:** Maven is not installed in the Jenkins container.

**Solution:**
The `jenkins-deployment.yaml` has been updated to install Maven and kubectl automatically in the Jenkins container startup script. The container runs as root and installs:
- Maven via `apt-get install -y maven`
- kubectl via downloading from Kubernetes release

**Verify:**
```bash
# Check Maven
kubectl exec -it -n jenkins deployment/jenkins -- mvn -version

# Check kubectl
kubectl exec -it -n jenkins deployment/jenkins -- kubectl version --client
```

**Alternative:** If Maven installation fails, you can install manually:
```bash
kubectl exec -it -n jenkins deployment/jenkins -- bash -c "apt-get update && apt-get install -y maven"
```

#### Maven Installation Methods (Detailed)

**Method 1: Install Maven as Root (Quick Fix)**

**For Kubernetes:**
```bash
# Exec as root
kubectl exec -it -n jenkins deployment/jenkins -- bash -c "apt-get update && apt-get install -y maven"

# Or create directory first if permission denied
kubectl exec -it -n jenkins deployment/jenkins -- bash -c "
    mkdir -p /var/lib/apt/lists/partial && \
    apt-get update && \
    apt-get install -y maven
"

# Verify installation
kubectl exec -it -n jenkins deployment/jenkins -- mvn -version
```

**For Docker:**
```bash
# Exec as root
docker exec -u root -it jenkins bash
apt-get update && apt-get install -y maven
```

**Method 2: Install Maven Manually (No Root Needed)**

**Download and install Maven without root:**
```bash
# Exec into Jenkins container
kubectl exec -it -n jenkins deployment/jenkins -- bash

# As jenkins user, download Maven
cd /tmp
wget https://dlcdn.apache.org/maven/maven-3/3.9.6/binaries/apache-maven-3.9.6-bin.tar.gz

# Extract to user's home directory
tar -xzf apache-maven-3.9.6-bin.tar.gz -C /var/jenkins_home

# Add to PATH (temporary for current session)
export PATH=/var/jenkins_home/apache-maven-3.9.6/bin:$PATH

# Make it permanent - add to .bashrc
echo 'export PATH=/var/jenkins_home/apache-maven-3.9.6/bin:$PATH' >> /var/jenkins_home/.bashrc

# Verify
mvn -version
```

**Note:** This only works for the current pod. If Jenkins pod restarts, you'll need to reinstall or use a custom Jenkins image.

**Method 3: Create Custom Jenkins Image with Maven (Best for Production)**

Create a `Dockerfile` for Jenkins with Maven:
```dockerfile
FROM jenkins/jenkins:lts

USER root

# Install Maven
RUN apt-get update && \
    apt-get install -y maven && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

USER jenkins
```

**Build and use:**
```bash
# Build custom image
docker build -t jenkins-with-maven:lts .

# Update jenkins-deployment.yaml to use custom image
# Change: image: jenkins/jenkins:lts
# To: image: jenkins-with-maven:lts
```

**Method 4: Use Maven via Docker Container (Recommended for Lab)**

Instead of installing Maven in Jenkins, use Maven Docker container. The Jenkinsfile already supports this:
- Unit Tests: Runs `mvn test` in Maven Docker container
- Build App: Runs `mvn clean package` in Maven Docker container
- No installation needed
- Works immediately

**Method 5: Skip Build Step (Easiest for Lab 22)**

**Just skip it!** The Dockerfile will build the app during `docker build`. The updated Jenkinsfile already does this - it skips Maven build and lets Dockerfile handle it.

**Recommendation:**
- **For Lab 22:** Use **Method 5** (Skip Build Step) - it's already implemented in the Jenkinsfile
- **If you really need Maven:** Use **Method 1** (run as root) for quick fix, or **Method 4** (Docker Maven) for a cleaner approach
- **For Production:** Use **Method 3** (Custom Jenkins image with Maven)

#### Maven Permission Issues

**Error:**
```
E: List directory /var/lib/apt/lists/partial is missing. - Acquire (13: Permission denied)
```

**Problem:** Even when running as root, the directory doesn't exist and needs to be created first.

**Solution:** Create directory first, then install:
```bash
kubectl exec -it -n jenkins deployment/jenkins -- bash -c "
    mkdir -p /var/lib/apt/lists/partial && \
    apt-get update && \
    apt-get install -y maven
"
```

### Docker Volume Mount Empty Directory

**Problem:**
When mounting Jenkins workspace into Maven Docker container, the directory appears empty.

**Root Cause:**
**SELinux** on CentOS/RHEL blocks Docker volume mounts by default. The `:z` or `:Z` flag is needed to set proper SELinux context.

**Solution:**
Add `:z` flag to the volume mount:
```bash
docker run --rm \
    -v "$WORK_DIR":/app:z \  # :z for SELinux context sharing
    -w /app \
    maven:3.9-eclipse-temurin-17 \
    mvn test
```

**`:z` flag:**
- Sets SELinux context to allow container access
- Shared label - multiple containers can access
- Safe for read-write access

### Jenkins Pod Stuck in Pending

**Problem:**
New Jenkins pod is stuck in `Pending` state after updating deployment.

**Common Causes:**

1. **Docker Binary Path Doesn't Exist**
   - Check: `ls -la /usr/bin/docker` on the node
   - Fix: Find correct Docker path: `which docker` or update YAML

2. **PVC Access Mode Conflict**
   - The PVC has `ReadWriteOnce` mode, which means only one pod can mount it at a time
   - Fix: Delete the old pod manually:
     ```bash
     kubectl delete pod <old-pod-name> -n jenkins
     ```

3. **Insufficient Resources**
   - Check: `kubectl describe pod -n jenkins -l app=jenkins | grep -A 20 "Events:"`
   - Fix: Free up resources or adjust resource requests/limits

**Quick Fix:**
```bash
# Check pod events
kubectl describe pod -n jenkins -l app=jenkins | tail -20

# Delete old pod if needed
kubectl delete pod <old-pod-name> -n jenkins
```

### Jenkins Container Crashing

**Problem:**
Jenkins container is in `BackOff` state - crashing repeatedly.

**Check Jenkins Logs:**
```bash
kubectl logs -n jenkins -l app=jenkins -c jenkins --tail=50
```

**Likely Causes:**
- PATH modification breaking Jenkins startup
- Init container issues
- Volume mount problems

**Solution:**
The current `jenkins-deployment.yaml` installs Maven and kubectl directly in the Jenkins container startup script, avoiding init container issues.

### Pod Limit/Quota Issues

**Problem:**
Pipeline stuck at `kubectl rollout status` because pods cannot be created.

**Error:**
```
0/2 nodes are available: 1 Insufficient pods
```

**Solution:**
Increase the pod limit/quota in your Kubernetes cluster:

```bash
# Check current quota
kubectl get resourcequota -n ivolve

# Update quota (if using ResourceQuota)
kubectl edit resourcequota <quota-name> -n ivolve
# Change pods limit to at least 5

# Or check cluster-wide limits
kubectl describe node | grep -i pod
```

**Note:** The deployment creates 2 replicas, so you need at least 5 pods available (including system pods).

### Complete Maven Installation Guide

#### Current Solution: Maven Installed in Jenkins Startup Script

The `jenkins-deployment.yaml` has been updated to install Maven and kubectl automatically in the Jenkins container startup script. The container runs as root and installs:
- Maven via `apt-get install -y maven`
- kubectl via downloading from Kubernetes release

This happens automatically when the Jenkins pod starts, so no manual installation is needed.

#### Alternative: Persistent Maven Installation Using Init Container

**How It Works:**
1. **Init Container** runs first and installs Maven
2. Maven is copied to a shared volume (`maven-data`)
3. Jenkins container mounts the same volume
4. Maven is available in PATH automatically

**Benefits:**
- ✅ Maven installed automatically on pod startup
- ✅ No manual installation needed
- ✅ Works even after pod restarts (init container runs again)
- ✅ Maven available in PATH

**Note:** The `emptyDir` volume is ephemeral - if the pod is deleted and recreated, Maven will be reinstalled by the init container. This is fine for most use cases.

**Verify After Installation:**
```bash
kubectl exec -it -n jenkins deployment/jenkins -- mvn -version
```

Should show:
```
Apache Maven 3.x.x
Maven home: /usr/share/maven (or /maven-data if using init container)
Java version: ...
```

#### Maven Installation Summary

**Easiest:** Skip Maven build (already done in Jenkinsfile)  
**Quick fix:** Install as root using `apt-get install -y maven`  
**Best practice:** Use Maven Docker container (already supported in Jenkinsfile)  
**Production:** Custom Jenkins image with Maven  
**Current Implementation:** Maven installed automatically in Jenkins startup script

## Screenshots

Screenshots have been added to document the pipeline execution:

- **dockerhub-image-tags.png**: Shows Docker Hub with pushed image tags
- **pipline-success.png**: Shows successful pipeline execution

These screenshots demonstrate:
- Successful Docker image push to Docker Hub
- Complete pipeline execution with all stages passing
- Post actions (always, success) executing correctly

## Summary

| Stage | Action | Tool/Command |
|-------|--------|--------------|
| 1 | Checkout | Git clone |
| 2 | Unit Tests | npm test / mvn test / pytest |
| 3 | Build App | npm build / mvn package |
| 4 | Build Docker Image | `docker build` |
| 5 | Push to Docker Hub | `docker push` |
| 6 | Delete Local Image | `docker rmi` |
| 7 | Update deployment.yaml | `sed` or `writeFile` |
| 8 | Deploy to K8s | `kubectl apply` |

## Key Takeaways

1. **Jenkins Pipeline as Code**: Define CI/CD in `Jenkinsfile`
2. **Containerized Jenkins**: Easy setup and Docker-in-Docker support
3. **Automated Deployment**: From code to production in one pipeline
4. **Post Actions**: Handle cleanup and notifications (always, success, failure)
5. **Credentials Management**: Secure storage of Docker Hub and K8s credentials
6. **RBAC Permissions**: Proper Kubernetes permissions for deployment
7. **Error Handling**: Graceful fallbacks for missing credentials or tools

## Next Steps

- Add Slack/Email notifications on pipeline success/failure
- Implement blue-green deployments
- Add automated rollback on deployment failure
- Set up webhook triggers for automatic builds on git push
- Add integration tests in the pipeline
- Move to Lab 23: CI/CD Pipeline Implementation with Jenkins Agents and Shared Libraries
- Move to Lab 24: Multi branch CI/CD Workflow

## License

See the LICENSE file in the parent directory for license information.
