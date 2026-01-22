# Jenkins Agent Tools Installation Guide

This guide shows you how to install required tools on your Jenkins agent, depending on your setup.

## When Do You Need the Dockerfile?

**You need the Dockerfile ONLY if:**
- ✅ Running agent as a **Kubernetes pod** (static pod or Kubernetes Plugin)
- ✅ Want tools to **persist** across pod restarts
- ✅ Using **containerized agent**

**You DON'T need the Dockerfile if:**
- ❌ Running agent on a **VM/host machine** (not in Kubernetes)
- ❌ Installing tools directly on the VM/host
- ❌ Using a **physical machine** as agent

## Required Tools

The Jenkins agent needs these tools to run the pipeline:

- **Docker CLI** - For building Docker images
- **kubectl** - For deploying to Kubernetes
- **Maven** - For building Java applications
- **Trivy** - For scanning Docker images for vulnerabilities
- **curl, wget, gnupg, lsb-release** - Supporting tools

## Solution: Custom Docker Image (Recommended)

The best way to make tools persistent is to build a custom Docker image with all tools pre-installed. This way, tools are part of the image and persist across pod restarts.

### Step 1: Build Custom Agent Image

1. **Navigate to the task-23 directory:**
   ```bash
   cd 03-Continues-Integration/task-23
   ```

2. **Build the custom image using the provided Dockerfile:**
   ```bash
   docker build -f Dockerfile.agent -t your-dockerhub-username/jenkins-agent:latest .
   ```
   
   Replace `your-dockerhub-username` with your actual Docker Hub username.

3. **Verify the image was built:**
   ```bash
   docker images | grep jenkins-agent
   ```

4. **Test the image locally (optional):**
   ```bash
   docker run --rm your-dockerhub-username/jenkins-agent:latest mvn -version
   docker run --rm your-dockerhub-username/jenkins-agent:latest kubectl version --client
   docker run --rm your-dockerhub-username/jenkins-agent:latest trivy --version
   ```

### Step 2: Push Image to Docker Hub

1. **Login to Docker Hub:**
   ```bash
   docker login
   ```

2. **Push the image:**
   ```bash
   docker push your-dockerhub-username/jenkins-agent:latest
   ```

### Step 3: Update Agent Configuration

1. **Edit `jenkins-agent-config.yaml`:**
   ```bash
   # Change line 13 from:
   image: jenkins/inbound-agent:latest
   
   # To:
   image: your-dockerhub-username/jenkins-agent:latest
   ```

2. **Apply the updated configuration:**
   ```bash
   kubectl apply -f jenkins-agent-config.yaml
   ```

3. **Delete the old pod to recreate it with the new image:**
   ```bash
   kubectl delete pod jenkins-agent -n jenkins
   ```

4. **Wait for the pod to be ready:**
   ```bash
   kubectl get pods -n jenkins -w
   ```

### Step 4: Verify Tools Are Installed

1. **Exec into the agent pod:**
   ```bash
   kubectl exec -it -n jenkins jenkins-agent -- bash
   ```

2. **Check all tools:**
   ```bash
   # Check Maven
   mvn -version
   
   # Check kubectl
   kubectl version --client
   
   # Check Trivy
   trivy --version
   
   # Check Docker (should be available via volume mount)
   docker --version
   docker ps
   ```

3. **Exit the pod:**
   ```bash
   exit
   ```

## Alternative 1: Manual Installation in Kubernetes Pod (Temporary)

If you're running the agent in Kubernetes and need to install tools manually in the pod (they will be lost when pod restarts):

### Step 1: Exec into the Agent Pod

```bash
kubectl exec -it -n jenkins jenkins-agent -- bash
```

### Step 2: Install Required Packages

```bash
# Update package list
apt-get update

# Install base packages
apt-get install -y \
    curl \
    ca-certificates \
    maven \
    wget \
    gnupg \
    lsb-release
```

### Step 3: Install kubectl

```bash
# Download kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# Make it executable
chmod +x kubectl

# Move to system path
mv kubectl /usr/local/bin/kubectl

# Verify installation
kubectl version --client
```

### Step 4: Install Trivy

**Option A: Using apt-key (if available):**
```bash
# Add Trivy repository key
wget -qO- https://aquasecurity.github.io/trivy-repo/deb/public.key | apt-key add -

# Add Trivy repository
echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | tee -a /etc/apt/sources.list.d/trivy.list

# Update package list
apt-get update

# Install Trivy
apt-get install -y trivy

# Verify installation
trivy --version
```

**Option B: Direct download (if apt-key not available - RECOMMENDED):**
```bash
# Download Trivy binary directly
wget -qO- https://github.com/aquasecurity/trivy/releases/latest/download/trivy_$(curl -s https://api.github.com/repos/aquasecurity/trivy/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')_Linux-64bit.tar.gz | tar -xz

# Or use specific version (replace 0.54.0 with latest version)
# wget https://github.com/aquasecurity/trivy/releases/download/v0.54.0/trivy_0.54.0_Linux-64bit.tar.gz
# tar -xzf trivy_0.54.0_Linux-64bit.tar.gz

# Move to system path
mv trivy /usr/local/bin/trivy
chmod +x /usr/local/bin/trivy

# Verify installation
trivy --version
```

**Option C: Using GPG keyring (modern method):**
```bash
# Download and add GPG key to keyring
wget -qO /usr/share/keyrings/trivy.gpg https://aquasecurity.github.io/trivy-repo/deb/public.key

# Add Trivy repository with signed-by
echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/trivy.list

# Update package list
apt-get update

# Install Trivy
apt-get install -y trivy

# Verify installation
trivy --version
```

### Step 5: Verify Docker Access

```bash
# Check Docker version (Docker is mounted from host)
docker --version

# Test Docker
docker ps
```

### Step 6: Verify All Tools

```bash
# Check Maven
mvn -version

# Check kubectl
kubectl version --client

# Check Trivy
trivy --version

# Check Docker
docker --version
```

## Alternative 2: Install Tools on VM/Host Machine (Permanent)

If you're running the Jenkins agent on a VM or host machine (NOT in Kubernetes), install tools directly on the machine:

### For CentOS/RHEL:

```bash
# Install Maven
sudo yum install -y maven

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/kubectl

# Install Trivy
sudo yum install -y wget
wget -qO- https://aquasecurity.github.io/trivy-repo/rpm/public.key | sudo rpm --import -
echo "deb https://aquasecurity.github.io/trivy-repo/rpm $(rpm -E %{rhel}) main" | sudo tee /etc/yum.repos.d/trivy.repo
sudo yum install -y trivy

# Install Docker (if not already installed)
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER  # Add your user to docker group
```

### For Ubuntu/Debian:

```bash
# Install Maven
sudo apt-get update
sudo apt-get install -y maven

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/kubectl

# Install Trivy
sudo apt-get install -y wget gnupg lsb-release
wget -qO- https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt-get update
sudo apt-get install -y trivy

# Install Docker (if not already installed)
sudo apt-get install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER  # Add your user to docker group
```

### Verify Installation:

```bash
mvn -version
kubectl version --client
trivy --version
docker --version
```

**Note:** When running on VM/host, tools persist permanently because they're installed on the actual machine, not in a container.

## Quick Installation Script (For Kubernetes Pod)

If you prefer a single command to install everything manually in a Kubernetes pod:

```bash
# Quick install script (using direct download for Trivy)
kubectl exec -it -n jenkins jenkins-agent -- bash -c "
apt-get update && \
apt-get install -y curl ca-certificates maven wget gnupg lsb-release && \
curl -LO \"https://dl.k8s.io/release/\$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl\" && \
chmod +x kubectl && \
mv kubectl /usr/local/bin/kubectl && \
wget -qO- https://github.com/aquasecurity/trivy/releases/latest/download/trivy_\$(curl -s https://api.github.com/repos/aquasecurity/trivy/releases/latest | grep tag_name | cut -d '\"' -f 4 | sed 's/v//')_Linux-64bit.tar.gz | tar -xz && \
mv trivy /usr/local/bin/trivy && \
chmod +x /usr/local/bin/trivy && \
echo '=== Installation Complete ===' && \
mvn -version && \
kubectl version --client && \
trivy --version && \
docker --version
"
```

## Summary

### If Running Agent in Kubernetes (Pod):
- **Recommended:** Use custom Docker image (`Dockerfile.agent`) - tools persist permanently ✅
- **Temporary:** Install manually in pod - tools lost when pod restarts ❌

### If Running Agent on VM/Host Machine:
- **Install directly on VM/host** - tools persist permanently ✅
- **Dockerfile NOT needed** - just install tools using package manager

**Tools Included in Custom Image:**
- ✅ Maven
- ✅ kubectl
- ✅ Trivy
- ✅ curl, wget, gnupg, lsb-release
- ✅ Docker CLI (available via volume mount from host)

**Note:** Docker is mounted from the host node, so you don't need to install it in the image. The volume mounts in `jenkins-agent-config.yaml` handle Docker access.
