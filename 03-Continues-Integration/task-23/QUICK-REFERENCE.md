# Quick Reference: Jenkins Agents and Shared Libraries

## What is What?

| Term | What It Is | Where It Lives | Purpose |
|------|------------|----------------|---------|
| **Jenkins Master** | Main Jenkins server | Your Kubernetes cluster or VM | Provides web UI, manages jobs |
| **Jenkins Agent** | Worker machine/container | Separate pod/VM/machine | Executes actual build work |
| **Shared Library** | Reusable Groovy code | Git repo or Jenkins filesystem | Functions you can use in pipelines |
| **Pipeline** | Build definition | Jenkinsfile in Git or Jenkins | Defines what to build and how |

## Where Does Pipeline Run?

```groovy
pipeline {
    agent any  // ← Can run on master OR agent (Jenkins decides)
}

pipeline {
    agent { label 'jenkins-agent' }  // ← MUST run on agent with this label
}
```

**Answer:** 
- `agent any` = Master or any agent
- `agent { label 'name' }` = Specific agent only
- If agent not available → Pipeline waits in queue

## Where Does Shared Library Live?

**Option 1: Git Repository (Recommended)**
```
GitHub/GitLab
└── shared-library/
    ├── vars/
    └── src/
```
- Jenkins downloads it when pipeline runs
- Configure: Manage Jenkins → Configure System → Global Pipeline Libraries

**Option 2: Local Filesystem**
```
/var/jenkins_home/
└── shared-library/
    ├── vars/
    └── src/
```
- Jenkins reads directly from filesystem
- Copy files to this path
- Configure: Same as Git, but use filesystem path

## How to Use Shared Library?

**Step 1: Load library in Jenkinsfile**
```groovy
@Library('ivolve-shared-library') _  // ← Loads the library
```

**Step 2: Use functions**
```groovy
pipeline {
    stages {
        stage('Build') {
            steps {
                buildApp()  // ← Function from shared library
            }
        }
    }
}
```

**The function name = file name in `vars/` folder:**
- `vars/buildApp.groovy` → `buildApp()`
- `vars/deploy.groovy` → `deploy()`

## How to Set Up Agent?

**Option 1: Kubernetes Plugin (Best for K8s)**
1. Install Kubernetes Plugin
2. Configure Cloud → Add Kubernetes
3. Add Pod Template with label `jenkins-agent`
4. Agent pods created automatically when needed

**Option 2: Static Pod**
1. Create pod using YAML
2. Configure node in Jenkins UI
3. Agent stays running

## Complete Setup Checklist

- [ ] Shared library created (7 functions in `vars/`)
- [ ] Shared library copied to Jenkins (`/var/jenkins_home/shared-library`)
- [ ] Shared library configured in Jenkins UI
- [ ] Kubernetes Plugin installed
- [ ] Kubernetes Cloud configured
- [ ] Pod Template created with label `jenkins-agent`
- [ ] Docker volumes mounted in pod template
- [ ] Pipeline created with `@Library('ivolve-shared-library') _`
- [ ] Pipeline uses `agent { label 'jenkins-agent' }`
- [ ] Test pipeline runs successfully on agent

## Common Commands

**Copy shared library to Jenkins:**
```bash
kubectl cp shared-library jenkins/<pod>:/var/jenkins_home/shared-library -n jenkins
```

**Check if library is in Jenkins:**
```bash
kubectl exec -it -n jenkins <pod> -- ls -la /var/jenkins_home/shared-library/vars
```

**Check agent pods:**
```bash
kubectl get pods -n jenkins | grep agent
```

**Check agent status in Jenkins:**
- Manage Jenkins → Manage Nodes
- Should see agent with status "Connected"

## Troubleshooting Quick Fixes

**Library not found:**
- Check name matches: `@Library('name') _` = Configured library name
- Verify path is correct
- Check Jenkins logs

**Agent not found:**
- Check agent is online: Manage Nodes
- Verify label matches: `agent { label 'name' }` = Agent label
- Check agent can connect to master

**Docker not found on agent:**
- Verify volumes are mounted in pod template
- Check Docker socket permissions
- Verify Docker binary is mounted
