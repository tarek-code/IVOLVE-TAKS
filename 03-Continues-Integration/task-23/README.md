# IVOLVE Task 23 - CI/CD Pipeline Implementation with Jenkins Agents and Shared Libraries

This lab demonstrates how to create a **Jenkins CI/CD pipeline** using **shared libraries** and **Jenkins agents/slaves** for distributed builds.

## 📚 Learning Path (Start Here If You're New!)

**If you don't know about Jenkins agents and shared libraries, follow this order:**

### Step 1: Read the Tutorial
👉 **[TUTORIAL.md](TUTORIAL.md)** - Complete explanation of concepts

**What you'll learn:**
- What Jenkins agents/slaves are and why we use them
- What shared libraries are and how they work
- Where to put shared libraries and how Jenkins finds them
- How pipelines run on agents vs master
- Step-by-step setup with detailed explanations

### Step 2: Try the Simple Example
👉 **[SIMPLE-EXAMPLE.md](SIMPLE-EXAMPLE.md)** - Hands-on practice

**What you'll do:**
- Create a simple shared library function
- Configure it in Jenkins
- Test it in a pipeline
- Understand the complete flow

### Step 3: Do the Lab
👉 **This README.md** - Full Lab 23 implementation

**What you'll build:**
- Complete shared library with 7 functions
- Configure Jenkins agent
- Create full pipeline using shared library
- Deploy application to Kubernetes

---

**Quick Reference:**
- **Don't understand agents?** → Read [TUTORIAL.md](TUTORIAL.md) Part 1
- **Don't understand shared libraries?** → Read [TUTORIAL.md](TUTORIAL.md) Part 2
- **Want to practice?** → Try [SIMPLE-EXAMPLE.md](SIMPLE-EXAMPLE.md)
- **Ready to build?** → Follow this README

## Lab Overview

In this lab you:

- **Clone** Dockerfile from GitHub
- **Create a shared library** with reusable Groovy functions
- **Configure Jenkins agents/slaves** to run pipelines
- **Create a pipeline** with the following stages:
  1. RunUnitTest
  2. BuildApp
  3. BuildImage
  4. ScanImage
  5. PushImage
  6. RemoveImageLocally
  7. DeployOnK8s
- **Use shared library** functions in the pipeline

## Prerequisites

- **Kubernetes cluster** (from previous tasks)
- **Jenkins** installed and running (from Lab 22)
- **Docker** installed and running
- **Docker Hub account** (for pushing images)
- **kubectl** configured to access your cluster
- **Namespace `ivolve`** exists (from Task 11)
- **Trivy** (for image scanning) - will be installed automatically

## Project Structure

```
task-23/
├── Jenkinsfile                    # Main pipeline using shared library
├── shared-library/                # Shared library repository
│   ├── vars/                      # Global pipeline functions
│   │   ├── runUnitTest.groovy
│   │   ├── buildApp.groovy
│   │   ├── buildImage.groovy
│   │   ├── scanImage.groovy
│   │   ├── pushImage.groovy
│   │   ├── removeImageLocally.groovy
│   │   └── deployOnK8s.groovy
│   └── src/                       # Source classes
│       └── org/ivolve/
│           └── PipelineUtils.groovy
├── jenkins-agent-config.yaml      # Kubernetes agent configuration
└── README.md
```

## Quick Start (After Reading Tutorial)

If you've read the tutorial and understand the concepts, here's the quick setup:

1. **Copy shared library to Jenkins:**
   ```bash
   kubectl cp shared-library jenkins/<pod-name>:/var/jenkins_home/shared-library -n jenkins
   ```

2. **Configure in Jenkins UI:**
   - Manage Jenkins → Configure System → Global Pipeline Libraries
   - Add: Name=`ivolve-shared-library`, Path=`/var/jenkins_home/shared-library`

3. **Install Kubernetes Plugin:**
   - Manage Plugins → Install "Kubernetes" plugin

4. **Configure Kubernetes Cloud:**
   - Manage Jenkins → Configure Clouds → Add Kubernetes
   - Add Pod Template with label `jenkins-agent`

5. **Create pipeline job** using the Jenkinsfile

For detailed explanations, see [TUTORIAL.md](TUTORIAL.md).

---

## Step-by-Step Instructions

### Step 1: Set Up Shared Library Repository

The shared library can be stored in:
1. **Git repository** (recommended for production)
2. **Local filesystem** (for testing)

**Option A: Create Git Repository for Shared Library (Recommended)**

1. Create a new Git repository (e.g., `ivolve-jenkins-shared-library`)
2. Copy the `shared-library` folder contents to the repository:
   ```bash
   cd shared-library
   git init
   git add .
   git commit -m "Initial shared library"
   git remote add origin https://github.com/YOUR_USERNAME/ivolve-jenkins-shared-library.git
   git push -u origin main
   ```

3. Note the repository URL for Step 2

**Option B: Use Local Filesystem (For Testing)**

1. Copy `shared-library` folder to Jenkins home:
   ```bash
   # If Jenkins is in Kubernetes
   kubectl cp shared-library jenkins/<pod-name>:/var/jenkins_home/shared-library -n jenkins
   
   # If Jenkins is in Docker
   docker cp shared-library jenkins:/var/jenkins_home/shared-library
   ```

2. Configure Jenkins to use local path (see Step 2)

### Step 2: Configure Shared Library in Jenkins

1. Go to **Manage Jenkins** → **Configure System**
2. Scroll down to **Global Pipeline Libraries**
3. Click **Add**
4. Configure the library:
   - **Name**: `ivolve-shared-library` (must match `@Library` name in Jenkinsfile)
   - **Default version**: `main` (or your branch name)
   - **Retrieval method**: 
     - **Modern SCM** (recommended for Git)
     - **Legacy SCM** (for filesystem or older setups)
   
   **If using Git (Option A):**
   - **Source Code Management**: Select **Git**
   - **Project Repository**: Enter your Git repository URL
     - Example: `https://github.com/YOUR_USERNAME/ivolve-jenkins-shared-library.git`
   - **Credentials**: Add if repository is private
   - **Default version**: `main` or `master`
   
   **If using Local Filesystem (Option B):**
   - **Source Code Management**: Select **None**
   - **Library Path**: `/var/jenkins_home/shared-library` (or your path)
   - Note: This method is less flexible and not recommended for production

5. **Allow default version to be overridden**: Check this if you want to use different versions
6. **Implicitly load**: Uncheck (we'll load explicitly with `@Library`)
7. Click **Save**

**Verify Configuration:**
- Go to **Manage Jenkins** → **System Information**
- Look for "Pipeline Libraries" section
- Verify your library is listed

### Step 3: Configure Jenkins Agent/Slave

You have **three options** to set up Jenkins agents:

#### Option 1: Kubernetes Plugin (Recommended for K8s Environment)

This is the **best option** for Kubernetes environments as it dynamically creates agents on demand.

1. **Install Kubernetes Plugin** in Jenkins:
   - Go to **Manage Jenkins** → **Manage Plugins** → **Available**
   - Search for "Kubernetes"
   - Install and restart Jenkins

2. **Configure Kubernetes Cloud:**
   - Go to **Manage Jenkins** → **Manage Nodes and Clouds** → **Configure Clouds**
   - Click **Add a new cloud** → **Kubernetes**
   - Configure basic settings:
     - **Name**: `kubernetes`
     - **Kubernetes URL**: 
       - If Jenkins is in K8s: `https://kubernetes.default.svc.cluster.local`
       - If Jenkins is outside K8s: Your cluster API URL
     - **Kubernetes server certificate key**: Leave empty (uses ServiceAccount if in K8s)
     - **Credentials**: 
       - If Jenkins is in K8s: Leave empty (uses ServiceAccount)
       - If Jenkins is outside: Add kubeconfig credential
     - **Jenkins URL**: 
       - If Jenkins is in K8s: `http://jenkins-service.jenkins.svc.cluster.local:8080`
       - If Jenkins is outside: `http://<jenkins-ip>:8080`
     - **Jenkins tunnel**: Leave empty (for JNLP)
   
   - **Pod Templates Configuration:**
     - Click **Add Pod Template**
     - **Name**: `jenkins-agent`
     - **Labels**: `jenkins-agent` (must match label in Jenkinsfile)
     - **Usage**: **Only build jobs with label expressions matching this node**
     - **Containers**:
       - Click **Add Container**
       - **Name**: `jnlp`
       - **Docker image**: `jenkins/inbound-agent:latest`
       - **Working directory**: `/home/jenkins/agent`
       - **Command**: Leave empty
       - **Arguments**: Leave empty
       - **Allocate pseudo-TTY**: Check if needed
     
     - **Volumes** (for Docker access):
       - Click **Add Volume** → **Host Path Volume**
         - **Host path**: `/var/run/docker.sock`
         - **Mount path**: `/var/run/docker.sock`
         - **Read only**: Uncheck
       - Click **Add Volume** → **Host Path Volume**
         - **Host path**: `/usr/bin/docker`
         - **Mount path**: `/usr/bin/docker`
         - **Read only**: Check
     
     - **Environment Variables** (optional):
       - Add if you need custom environment variables
   
   - Click **Save**

3. **Test Agent Creation:**
   - Run a pipeline with `agent { label 'jenkins-agent' }`
   - Check if pod is created: `kubectl get pods -n jenkins`
   - Pod should be created dynamically and deleted after build

#### Option 2: Static Kubernetes Pod Agent

This creates a permanent agent pod that stays running.

1. **Create agent pod:**
   ```bash
   kubectl apply -f jenkins-agent-config.yaml
   ```

2. **In Jenkins UI:**
   - Go to **Manage Jenkins** → **Manage Nodes and Clouds**
   - Click **New Node**
   - **Node name**: `jenkins-agent`
   - **Type**: **Permanent Agent**
   - Click **OK**
   - Configure:
     - **Remote root directory**: `/home/jenkins/agent`
     - **Launch method**: **Launch agent via Java Web Start**
     - **Labels**: `jenkins-agent` (must match label in Jenkinsfile)
     - **Usage**: **Only build jobs with label expressions matching this node**
     - **Number of executors**: `2` (or as needed)
   - Click **Save**

3. **Connect the agent:**
   - On the node page, you'll see connection instructions
   - Get the secret from Jenkins
   - Update `jenkins-agent-config.yaml` with the secret:
     ```yaml
     env:
     - name: JENKINS_SECRET
       value: "YOUR_SECRET_HERE"
     ```
   - Or exec into the pod and run the connection command manually
   - Agent should appear as "Connected" in Jenkins UI

#### Option 3: VM/Physical Machine Agent

1. Install Java on the agent machine:
   ```bash
   sudo yum install -y java-11-openjdk
   ```

2. In Jenkins UI:
   - Go to **Manage Jenkins** → **Manage Nodes and Clouds**
   - Click **New Node**
   - **Node name**: `jenkins-agent`
   - **Type**: **Permanent Agent**
   - Configure:
     - **Remote root directory**: `/home/jenkins/agent`
     - **Launch method**: **Launch agent via SSH**
     - **Host**: Agent machine IP/hostname
     - **Credentials**: Add SSH credentials
     - **Labels**: `jenkins-agent`
   - Click **Save**

### Step 4: Install Required Tools on Agent

The agent needs:
- **Docker** (for building images)
- **kubectl** (for deploying to K8s)
- **Maven** (for building Java apps)
- **Trivy** (for image scanning - will be installed automatically by shared library)

**If using Kubernetes Plugin (Dynamic Agents):**

Create a custom agent image with all tools:

1. **Create Dockerfile for agent:**
   ```dockerfile
   FROM jenkins/inbound-agent:latest
   
   USER root
   
   # Install Docker CLI
   RUN apt-get update && \
       apt-get install -y \
       curl \
       ca-certificates \
       maven \
       && rm -rf /var/lib/apt/lists/*
   
   # Install kubectl
   RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
       chmod +x kubectl && \
       mv kubectl /usr/local/bin/
   
   # Install Trivy
   RUN wget -qO- https://aquasecurity.github.io/trivy-repo/deb/public.key | apt-key add - && \
       echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | tee -a /etc/apt/sources.list.d/trivy.list && \
       apt-get update && \
       apt-get install -y trivy
   
   USER jenkins
   ```

2. **Build and push image:**
   ```bash
   docker build -t your-username/jenkins-agent:latest .
   docker push your-username/jenkins-agent:latest
   ```

3. **Update Kubernetes Plugin pod template:**
   - Change **Docker image** from `jenkins/inbound-agent:latest` to `your-username/jenkins-agent:latest`

**If using Static Agent:**

```bash
# Exec into the agent pod
kubectl exec -it -n jenkins jenkins-agent -- bash

# Install tools (as root)
apt-get update
apt-get install -y maven curl ca-certificates

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/

# Install Trivy (optional - shared library will install it)
wget -qO- https://aquasecurity.github.io/trivy-repo/deb/public.key | apt-key add -
echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | tee -a /etc/apt/sources.list.d/trivy.list
apt-get update
apt-get install -y trivy
```

**Note:** Trivy will be installed automatically by the `scanImage` function if not present, but pre-installing it is faster.

### Step 5: Create Pipeline Job

1. Go to **New Item**
2. Enter name: `jenkins-app-pipeline-lab23`
3. Select **Pipeline**
4. Click **OK**

### Step 6: Configure Pipeline

In the pipeline configuration:

1. **Pipeline Definition**: Select **Pipeline script from SCM**
2. **SCM**: Select **Git**
3. **Repository URL**: `https://github.com/Ibrahim-Adel15/Jenkins_App.git`
4. **Branches to build**: `*/main` or `*/master`
5. **Script Path**: `Jenkinsfile` (or path to your Jenkinsfile)
6. Click **Save**

**Note:** Make sure your Jenkinsfile is in the repository or use **Pipeline script** to paste it directly.

### Step 7: Configure Credentials

Ensure these credentials are configured in Jenkins (same as Lab 22):

1. **Docker Hub credentials** (ID: `dockerhub-credentials`)
2. **Kubernetes kubeconfig** (ID: `kubeconfig`) - Optional if using ServiceAccount

### Step 8: Run the Pipeline

1. Go to your pipeline job: `jenkins-app-pipeline-lab23`
2. Click **Build Now**
3. Watch the pipeline execution

The pipeline will:
- Run on the Jenkins agent (not master)
- Use shared library functions for each stage
- Execute all 7 stages in sequence

## Shared Library Functions Explained

### 1. runUnitTest(workDir)

**Purpose:** Run unit tests based on project type

**Parameters:**
- `workDir`: Working directory (default: '.')

**Behavior:**
- Detects project type (Maven, npm, Python)
- Runs appropriate test command
- Continues even if tests fail (with warning)

**Usage:**
```groovy
runUnitTest('.')
runUnitTest('Jenkins_App')
```

### 2. buildApp(workDir)

**Purpose:** Build the application

**Parameters:**
- `workDir`: Working directory (default: '.')

**Behavior:**
- Detects project type
- Runs build command (mvn package, npm build, etc.)
- Skips if no build tool detected

**Usage:**
```groovy
buildApp('.')
```

### 3. buildImage(imageName, workDir)

**Purpose:** Build Docker image from Dockerfile

**Parameters:**
- `imageName`: Full image name with tag (e.g., `username/repo:tag`)
- `workDir`: Working directory (default: '.')

**Behavior:**
- Checks for Dockerfile
- Builds image with specified name
- Tags as `latest` as well

**Usage:**
```groovy
buildImage('myuser/jenkins-app:1', '.')
```

### 4. scanImage(imageName)

**Purpose:** Scan Docker image for vulnerabilities

**Parameters:**
- `imageName`: Full image name with tag

**Behavior:**
- Installs Trivy if not present
- Scans image for HIGH and CRITICAL vulnerabilities
- Does not fail pipeline on findings (logs warnings)

**Usage:**
```groovy
scanImage('myuser/jenkins-app:1')
```

### 5. pushImage(imageName, credentialsId)

**Purpose:** Push Docker image to Docker Hub

**Parameters:**
- `imageName`: Full image name with tag
- `credentialsId`: Jenkins credential ID (default: 'dockerhub-credentials')

**Behavior:**
- Logs into Docker Hub using credentials
- Pushes both tagged and latest images
- Falls back to environment variables if credentials not found

**Usage:**
```groovy
pushImage('myuser/jenkins-app:1')
pushImage('myuser/jenkins-app:1', 'my-dockerhub-creds')
```

### 6. removeImageLocally(imageName)

**Purpose:** Remove Docker image from local Docker daemon

**Parameters:**
- `imageName`: Full image name with tag

**Behavior:**
- Removes both tagged and latest images
- Does not fail if image not found

**Usage:**
```groovy
removeImageLocally('myuser/jenkins-app:1')
```

### 7. deployOnK8s(imageName, namespace, deploymentFile, workDir)

**Purpose:** Deploy application to Kubernetes

**Parameters:**
- `imageName`: Full image name with tag
- `namespace`: Kubernetes namespace (default: 'ivolve')
- `deploymentFile`: Path to deployment.yaml (default: 'deployment.yaml')
- `workDir`: Working directory (default: '.')

**Behavior:**
- Creates deployment.yaml if it doesn't exist
- Updates image in deployment.yaml
- Creates namespace if needed
- Applies deployment to cluster
- Waits for rollout

**Usage:**
```groovy
deployOnK8s('myuser/jenkins-app:1', 'ivolve', 'deployment.yaml', '.')
```

## Jenkinsfile Explanation

The `Jenkinsfile` uses the shared library:

```groovy
@Library('ivolve-shared-library') _  // Load shared library

pipeline {
    agent {
        label 'jenkins-agent'  // Run on agent, not master
    }
    
    stages {
        stage('RunUnitTest') {
            steps {
                runUnitTest('.')  // Use shared library function
            }
        }
        // ... other stages use shared library functions
    }
}
```

## Benefits of Shared Libraries

1. **Reusability**: Use same functions across multiple pipelines
2. **Maintainability**: Update logic in one place
3. **Consistency**: Same behavior across all pipelines
4. **Testing**: Test functions independently
5. **Versioning**: Control library versions per pipeline

## Benefits of Jenkins Agents

1. **Distributed Builds**: Offload work from master
2. **Resource Isolation**: Agents have dedicated resources
3. **Scalability**: Add more agents as needed
4. **Specialization**: Configure agents for specific tasks
5. **Performance**: Parallel builds on multiple agents

## Troubleshooting

### Shared Library Not Found

**Error:** `Library 'ivolve-shared-library' not found`

**Solution:**
1. Verify library name in Jenkins configuration
2. Check library repository is accessible
3. Verify default version/branch exists
4. Check Jenkins logs for connection errors

### Agent Not Available

**Error:** `There are no nodes with the label 'jenkins-agent'`

**Solution:**
1. Verify agent is online: **Manage Jenkins** → **Manage Nodes**
2. Check agent has correct label
3. Verify agent can connect to Jenkins master
4. Check agent logs for connection issues

### Trivy Installation Fails

**Error:** Trivy scan fails during installation

**Solution:**
1. Agent needs root/sudo access for apt-get
2. Or pre-install Trivy on agent image
3. Or use Trivy Docker container instead:
   ```groovy
   sh "docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy image ${imageName}"
   ```

### Agent Cannot Access Docker

**Error:** `docker: not found` or permission denied

**Solution:**
1. Ensure Docker socket is mounted (for K8s agents)
2. Agent user has Docker group access
3. Verify Docker binary is in PATH
4. Check volume mounts in agent configuration

## Screenshots

Add screenshots for:
- Shared library configuration in Jenkins
- Agent configuration and status
- Pipeline execution on agent
- Shared library function execution
- Successful deployment

## Summary

| Stage | Shared Library Function | Purpose |
|-------|------------------------|---------|
| 1 | `runUnitTest()` | Run unit tests |
| 2 | `buildApp()` | Build application |
| 3 | `buildImage()` | Build Docker image |
| 4 | `scanImage()` | Scan for vulnerabilities |
| 5 | `pushImage()` | Push to Docker Hub |
| 6 | `removeImageLocally()` | Clean up local images |
| 7 | `deployOnK8s()` | Deploy to Kubernetes |

## Key Takeaways

1. **Shared Libraries**: Reusable pipeline code across projects
2. **Jenkins Agents**: Distribute builds for better performance
3. **Modular Design**: Each stage is a separate function
4. **Version Control**: Shared libraries can be versioned
5. **Scalability**: Add agents as needed for parallel builds

## Next Steps

- Add more shared library functions for common tasks
- Configure multiple agents for different environments
- Implement pipeline templates using shared libraries
- Add unit tests for shared library functions
- Move to Lab 24: Multi branch CI/CD Workflow

## License

See the LICENSE file in the parent directory for license information.
