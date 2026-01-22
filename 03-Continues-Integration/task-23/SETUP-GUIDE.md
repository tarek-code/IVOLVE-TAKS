# Quick Setup Guide for Lab 23

This is a condensed setup guide. For detailed instructions, see README.md.

## Quick Start

### 1. Set Up Shared Library (5 minutes)

**Option A: Git Repository (Recommended)**
```bash
# Create new repo on GitHub/GitLab
# Copy shared-library folder to repo
cd shared-library
git init
git add .
git commit -m "Initial shared library"
git remote add origin https://github.com/YOUR_USERNAME/ivolve-shared-library.git
git push -u origin main
```

**Option B: Local Filesystem**
```bash
# Copy to Jenkins home
kubectl cp shared-library jenkins/<pod-name>:/var/jenkins_home/shared-library -n jenkins
```

### 2. Configure in Jenkins (2 minutes)

1. **Manage Jenkins** → **Configure System** → **Global Pipeline Libraries**
2. **Add** library:
   - Name: `ivolve-shared-library`
   - Version: `main`
   - SCM: Git (or None for filesystem)
   - Repository: Your Git URL (or leave empty for filesystem)
3. **Save**

### 3. Set Up Agent (10 minutes)

**Option A: Kubernetes Plugin (Easiest)**

1. Install **Kubernetes Plugin**
2. **Manage Jenkins** → **Configure Clouds** → **Add Kubernetes**
3. Configure:
   - Name: `kubernetes`
   - URL: `https://kubernetes.default.svc.cluster.local`
   - Jenkins URL: `http://jenkins-service.jenkins.svc.cluster.local:8080`
4. **Add Pod Template**:
   - Name: `jenkins-agent`
   - Labels: `jenkins-agent`
   - Image: `jenkins/inbound-agent:latest` (or your custom image)
   - Volumes: Mount `/var/run/docker.sock` and `/usr/bin/docker`
5. **Save**

**Option B: Static Pod**

```bash
kubectl apply -f jenkins-agent-config.yaml
# Then configure node in Jenkins UI
```

### 4. Create Pipeline (2 minutes)

1. **New Item** → **Pipeline**
2. Name: `jenkins-app-pipeline-lab23`
3. **Pipeline script from SCM**:
   - Git: `https://github.com/Ibrahim-Adel15/Jenkins_App.git`
   - Script Path: `Jenkinsfile`
4. **Save**

### 5. Run Pipeline

Click **Build Now** and watch it execute on the agent!

## Verification Checklist

- [ ] Shared library configured in Jenkins
- [ ] Agent is online (Manage Nodes)
- [ ] Agent has label `jenkins-agent`
- [ ] Docker accessible on agent
- [ ] kubectl available on agent
- [ ] Pipeline uses `@Library('ivolve-shared-library') _`
- [ ] Pipeline uses `agent { label 'jenkins-agent' }`

## Common Issues

**Library not found:**
- Check library name matches `@Library` directive
- Verify repository is accessible
- Check Jenkins logs

**Agent not found:**
- Verify agent is online
- Check label matches Jenkinsfile
- Verify agent can connect to master

**Docker not found:**
- Check volume mounts in agent config
- Verify Docker socket permissions
- Check agent has Docker CLI
