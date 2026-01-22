# Complete Tutorial: Jenkins Agents and Shared Libraries

This tutorial explains everything you need to know about Jenkins agents (slaves) and shared libraries from scratch.

## Part 1: Understanding Jenkins Architecture

### What is Jenkins Master?

**Jenkins Master** is the main Jenkins server that:
- Provides the web UI
- Manages jobs and pipelines
- Coordinates builds
- Stores configuration

**Problem:** If all builds run on the master:
- Master gets overloaded
- Can't run multiple builds in parallel easily
- Master resources are limited
- One build can block others

### What are Jenkins Agents/Slaves?

**Jenkins Agents** (also called "slaves" or "nodes") are:
- Separate machines/containers that **execute** the actual build work
- Connected to the Jenkins master
- Can run builds in parallel
- Have their own resources (CPU, memory, disk)

**Benefits:**
- ✅ Master stays free (just coordinates)
- ✅ Multiple builds can run simultaneously
- ✅ Each agent has dedicated resources
- ✅ Can scale by adding more agents
- ✅ Agents can be specialized (e.g., one for Docker, one for Maven)

### How It Works

```
┌─────────────────┐
│  Jenkins Master │  ← You access this via web UI
│  (Coordinates)  │
└────────┬────────┘
         │
         │ Sends build tasks
         │
    ┌────┴────┬──────────┐
    │         │          │
┌───▼───┐ ┌──▼───┐  ┌───▼───┐
│Agent 1│ │Agent 2│  │Agent 3│  ← These do the actual work
│(Build)│ │(Build)│  │(Build)│
└───────┘ └───────┘  └───────┘
```

**Example:**
- Master: "Hey Agent 1, run this pipeline"
- Agent 1: "Okay, I'll run `mvn test`, `docker build`, etc."
- Master: "Show me the results when done"

## Part 2: Understanding Shared Libraries

### What is a Shared Library?

**Shared Library** is a collection of reusable Groovy code that:
- Contains common pipeline functions
- Can be used across multiple Jenkinsfiles
- Stored in a Git repository or filesystem
- Loaded into pipelines with `@Library('name') _`

### Why Use Shared Libraries?

**Without Shared Library:**
```groovy
// Pipeline 1
pipeline {
    stages {
        stage('Build') {
            steps {
                sh 'mvn clean package'  // Same code repeated
            }
        }
    }
}

// Pipeline 2
pipeline {
    stages {
        stage('Build') {
            steps {
                sh 'mvn clean package'  // Same code repeated again!
            }
        }
    }
}
```

**Problem:**
- Code duplication
- If you need to change build logic, update 10+ pipelines
- Inconsistent behavior
- Hard to maintain

**With Shared Library:**
```groovy
// Shared Library: vars/buildApp.groovy
def call() {
    sh 'mvn clean package'
}

// Pipeline 1
@Library('my-library') _
pipeline {
    stages {
        stage('Build') {
            steps {
                buildApp()  // Reusable function!
            }
        }
    }
}

// Pipeline 2
@Library('my-library') _
pipeline {
    stages {
        stage('Build') {
            steps {
                buildApp()  // Same function, no duplication!
            }
        }
    }
}
```

**Benefits:**
- ✅ Write once, use everywhere
- ✅ Update in one place, all pipelines benefit
- ✅ Consistent behavior
- ✅ Easy to test and maintain

### Shared Library Structure

```
shared-library/
├── vars/              # Global variables (pipeline steps)
│   └── buildApp.groovy    ← Functions you call in pipelines
├── src/               # Source classes (optional)
│   └── org/company/
│       └── Utils.groovy   ← Helper classes
└── resources/         # Static files (optional)
    └── scripts/
        └── deploy.sh
```

**Key Points:**
- Files in `vars/` become pipeline steps automatically
- File name = function name (e.g., `buildApp.groovy` → `buildApp()`)
- `src/` contains classes you can import
- `resources/` contains files you can read

## Part 3: Where Does Jenkins Find Shared Libraries?

### Option 1: Git Repository (Recommended)

**How it works:**
1. You store shared library in a Git repository
2. Jenkins downloads it when pipeline runs
3. Jenkins caches it locally

**Configuration:**
- **Manage Jenkins** → **Configure System** → **Global Pipeline Libraries**
- Add library with Git URL
- Jenkins automatically fetches it

**Example:**
```
Repository: https://github.com/your-username/shared-library.git
Branch: main
Jenkins downloads → /var/jenkins_home/.jenkins/cache/...
```

### Option 2: Local Filesystem

**How it works:**
1. You copy shared library to Jenkins home directory
2. Jenkins reads it directly from filesystem
3. No Git needed (but less flexible)

**Configuration:**
- Copy to: `/var/jenkins_home/shared-library/`
- Configure Jenkins to use that path
- Jenkins reads directly from filesystem

**Example:**
```
/var/jenkins_home/
└── shared-library/
    ├── vars/
    └── src/
```

### Why Put It in Jenkins Path?

**Answer:** Jenkins needs to find and load the library when pipeline runs.

**Process:**
1. Pipeline starts: `@Library('my-library') _`
2. Jenkins looks for library:
   - Checks configured libraries (Git or filesystem)
   - Downloads/clones if from Git
   - Loads functions into pipeline
3. Pipeline can now use: `buildApp()`, `deploy()`, etc.

**If library not found:**
- Pipeline fails with: `Library 'my-library' not found`
- You must configure it first in Jenkins

## Part 4: Step-by-Step Guide

### Step 1: Create Shared Library (Local Filesystem Method - Easiest)

**Why start with filesystem?**
- No Git setup needed
- Faster for learning
- Can move to Git later

**Steps:**

1. **Copy shared library to Jenkins:**

   **If Jenkins is in Kubernetes:**
   ```bash
   # Get Jenkins pod name
   kubectl get pods -n jenkins
   
   # Copy shared-library folder to Jenkins
   kubectl cp shared-library jenkins/<pod-name>:/var/jenkins_home/shared-library -n jenkins
   
   # Verify it's there
   kubectl exec -it -n jenkins <pod-name> -- ls -la /var/jenkins_home/shared-library
   ```

   **If Jenkins is in Docker:**
   ```bash
   docker cp shared-library jenkins:/var/jenkins_home/shared-library
   
   # Verify
   docker exec jenkins ls -la /var/jenkins_home/shared-library
   ```

2. **Verify structure in Jenkins:**
   ```bash
   # In Kubernetes
   kubectl exec -it -n jenkins <pod-name> -- tree /var/jenkins_home/shared-library
   
   # Should show:
   # shared-library/
   # ├── vars/
   # │   ├── runUnitTest.groovy
   # │   ├── buildApp.groovy
   # │   └── ...
   # └── src/
   ```

### Step 2: Configure Shared Library in Jenkins UI

1. **Open Jenkins UI:**
   - Go to: `http://<jenkins-url>:8080` (or `:30080` if NodePort)

2. **Navigate to Configuration:**
   - Click **Manage Jenkins** (left sidebar)
   - Click **Configure System** (or **System Configuration**)

3. **Find Global Pipeline Libraries:**
   - Scroll down to find **Global Pipeline Libraries** section
   - It's usually near the bottom

4. **Add New Library:**
   - Click **Add** button
   - Fill in:
     - **Name**: `ivolve-shared-library`
       - ⚠️ This name MUST match what you use in Jenkinsfile: `@Library('ivolve-shared-library') _`
     - **Default version**: `main` (or leave empty for filesystem)
     - **Retrieval method**: 
       - For filesystem: Select **Legacy SCM** or **None**
       - For Git: Select **Modern SCM**
   
   **For Local Filesystem:**
   - **Source Code Management**: Select **None** (or **Legacy SCM** → **File System**)
   - **Library Path**: `/var/jenkins_home/shared-library`
     - This is the path INSIDE Jenkins container/pod
   
   **For Git Repository:**
   - **Source Code Management**: Select **Git**
   - **Project Repository**: `https://github.com/your-username/shared-library.git`
   - **Credentials**: Add if private repo
   - **Default version**: `main`

5. **Advanced Options:**
   - **Allow default version to be overridden**: ✅ Check (allows using different versions)
   - **Implicitly load**: ❌ Uncheck (we load explicitly with `@Library`)

6. **Save:**
   - Click **Save** at the bottom
   - Jenkins will validate the configuration

7. **Verify:**
   - Go to **Manage Jenkins** → **System Information**
   - Look for "Pipeline Libraries" section
   - You should see `ivolve-shared-library` listed

### Step 3: Understanding Pipeline Agent Configuration

**In your Jenkinsfile, you specify WHERE the pipeline runs:**

```groovy
pipeline {
    agent any  // ← This means: "Run on any available agent or master"
}
```

**Options:**

1. **`agent any`**
   - Runs on master OR any available agent
   - Jenkins picks automatically

2. **`agent { label 'jenkins-agent' }`**
   - Runs ONLY on agent with label `jenkins-agent`
   - If no agent with that label → Pipeline waits or fails

3. **`agent none`**
   - No agent assigned
   - You specify agent per stage

**Example:**
```groovy
pipeline {
    agent { label 'jenkins-agent' }  // ← Pipeline runs on agent
    
    stages {
        stage('Build') {
            steps {
                buildApp()  // ← This executes ON THE AGENT
            }
        }
    }
}
```

**What happens:**
1. You click "Build Now" in Jenkins UI (on master)
2. Master looks for agent with label `jenkins-agent`
3. Master sends pipeline code to agent
4. Agent executes all stages
5. Agent sends results back to master
6. You see results in Jenkins UI

### Step 4: Set Up Jenkins Agent (Kubernetes Plugin - Recommended)

**Why Kubernetes Plugin?**
- Automatically creates agents when needed
- Deletes agents when done (saves resources)
- No manual pod management
- Best for Kubernetes environments

#### 4.1 Install Kubernetes Plugin

1. **Go to Jenkins UI:**
   - **Manage Jenkins** → **Manage Plugins**

2. **Install Plugin:**
   - Click **Available** tab
   - Search for: `Kubernetes`
   - Find **Kubernetes** plugin (by Jenkins)
   - ✅ Check the box
   - Click **Install without restart** (or **Download now and install after restart**)

3. **Restart Jenkins:**
   - After installation, restart Jenkins
   - **Manage Jenkins** → **Restart Jenkins**

#### 4.2 Configure Kubernetes Cloud

1. **Navigate to Cloud Configuration:**
   - **Manage Jenkins** → **Manage Nodes and Clouds**
   - Click **Configure Clouds** (or find **Clouds** section)

2. **Add Kubernetes Cloud:**
   - Click **Add a new cloud**
   - Select **Kubernetes**
   - Click **OK**

3. **Basic Configuration:**
   
   **Name:** `kubernetes`
   
   **Kubernetes URL:**
   - If Jenkins is IN Kubernetes: `https://kubernetes.default.svc.cluster.local`
   - If Jenkins is OUTSIDE Kubernetes: Your cluster API URL
     - Find it: `kubectl cluster-info`
   
   **Kubernetes server certificate key:**
   - Leave **empty** if Jenkins is in K8s (uses ServiceAccount)
   - Or paste certificate if outside K8s
   
   **Credentials:**
   - If Jenkins is IN Kubernetes: Leave **empty** (uses ServiceAccount)
   - If Jenkins is OUTSIDE: Add kubeconfig credential
   
   **Jenkins URL:**
   - If Jenkins is IN Kubernetes: `http://jenkins-service.jenkins.svc.cluster.local:8080`
   - If Jenkins is OUTSIDE: `http://<jenkins-ip>:8080`
     - Find IP: `kubectl get svc -n jenkins` (if NodePort)
   
   **Jenkins tunnel:**
   - Leave **empty** (for JNLP communication)

4. **Configure Pod Template (The Agent):**
   
   Scroll down to **Pod Templates** section
   
   Click **Add Pod Template**
   
   **Basic Pod Configuration:**
   - **Name**: `jenkins-agent`
   - **Namespace**: `jenkins` (or leave empty for default)
   - **Labels**: `jenkins-agent`
     - ⚠️ This label MUST match what you use in Jenkinsfile: `agent { label 'jenkins-agent' }`
   - **Usage**: Select **Only build jobs with label expressions matching this node**
     - This means: Only use this agent when pipeline asks for `jenkins-agent` label
   
   **Container Configuration:**
   - Click **Add Container** under **Containers**
   - **Name**: `jnlp`
     - This is the Jenkins agent container
   - **Docker image**: `jenkins/inbound-agent:latest`
     - This is the official Jenkins agent image
   - **Working directory**: `/home/jenkins/agent`
   - **Command**: Leave empty
   - **Arguments**: Leave empty
   - **Allocate pseudo-TTY**: ✅ Check (helps with some commands)
   
   **Volumes (For Docker Access):**
   
   The agent needs Docker to build images. Add these volumes:
   
   **Volume 1: Docker Socket**
   - Click **Add Volume** → **Host Path Volume**
   - **Host path**: `/var/run/docker.sock`
   - **Mount path**: `/var/run/docker.sock`
   - **Read only**: ❌ Uncheck (needs write access)
   
   **Volume 2: Docker Binary**
   - Click **Add Volume** → **Host Path Volume**
   - **Host path**: `/usr/bin/docker`
   - **Mount path**: `/usr/bin/docker`
   - **Read only**: ✅ Check (binary is read-only)
   
   **Optional: Add Sidecar Container for Tools**
   
   You can add another container with Maven, kubectl, etc.:
   - Click **Add Container**
   - **Name**: `tools`
   - **Docker image**: `maven:3.9-eclipse-temurin-17` (or your custom image)
   - **Command**: `cat` (keeps container running)
   - **Working directory**: `/workspace`
   
   Or install tools in the jnlp container (see Step 4.3)

5. **Save Configuration:**
   - Click **Save** at the bottom
   - Jenkins will test the connection to Kubernetes

6. **Test Agent Creation:**
   - Create a simple test pipeline:
     ```groovy
     pipeline {
         agent { label 'jenkins-agent' }
         stages {
             stage('Test') {
                 steps {
                     sh 'echo "Running on agent!"'
                     sh 'docker --version'
                 }
             }
         }
     }
     ```
   - Run it
   - Check if pod is created: `kubectl get pods -n jenkins`
   - You should see a pod like: `jenkins-agent-xxxxx-xxxxx`
   - After build completes, pod should be deleted

#### 4.3 Install Tools on Agent (If Needed)

**Option A: Use Custom Agent Image (Best)**

1. **Build custom image** using `Dockerfile.agent`:
   ```bash
   docker build -f Dockerfile.agent -t your-username/jenkins-agent:latest .
   docker push your-username/jenkins-agent:latest
   ```

2. **Update Pod Template:**
   - Change **Docker image** from `jenkins/inbound-agent:latest` to `your-username/jenkins-agent:latest`

**Option B: Install Tools in Shared Library**

The shared library functions can install tools on-the-fly:
- `scanImage()` installs Trivy if not found
- You can add similar logic for Maven, kubectl, etc.

**Option C: Use Init Container (Advanced)**

Add init container in pod template to install tools before agent starts.

### Step 5: Create Pipeline Using Shared Library

1. **Create New Pipeline Job:**
   - **New Item** → Name: `test-shared-library` → **Pipeline** → **OK**

2. **Configure Pipeline:**
   - **Pipeline Definition**: **Pipeline script** (for testing)
   - Paste this test Jenkinsfile:
   ```groovy
   @Library('ivolve-shared-library') _
   
   pipeline {
       agent { label 'jenkins-agent' }
       
       environment {
           DOCKERHUB_USER = 'your-username'
           DOCKERHUB_REPO = "${DOCKERHUB_USER}/jenkins-app"
           IMAGE_TAG = "${env.BUILD_NUMBER}"
       }
       
       stages {
           stage('Test Shared Library') {
               steps {
                   script {
                       echo "Testing shared library functions..."
                       // Test a simple function
                       runUnitTest('.')
                   }
               }
           }
       }
   }
   ```

3. **Run Pipeline:**
   - Click **Build Now**
   - Watch console output
   - Should see: "Stage: RunUnitTest" (from shared library)

4. **Verify It's Running on Agent:**
   - In console output, look for: "Running on agent-xxxxx"
   - Check: `kubectl get pods -n jenkins` (should see agent pod)

### Step 6: Full Pipeline with All Stages

Once shared library and agent work, use the full Jenkinsfile:

```groovy
@Library('ivolve-shared-library') _

pipeline {
    agent { label 'jenkins-agent' }  // ← Runs on agent
    
    environment {
        DOCKERHUB_USER = "${env.DOCKERHUB_USERNAME ?: 'your-username'}"
        DOCKERHUB_REPO = "${DOCKERHUB_USER}/jenkins-app"
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        K8S_NAMESPACE = 'ivolve'
    }
    
    stages {
        stage('Checkout') {
            steps {
                git clone https://github.com/Ibrahim-Adel15/Jenkins_App.git
            }
        }
        
        stage('RunUnitTest') {
            steps {
                runUnitTest('Jenkins_App')  // ← Shared library function
            }
        }
        
        stage('BuildApp') {
            steps {
                buildApp('Jenkins_App')  // ← Shared library function
            }
        }
        
        // ... all other stages use shared library functions
    }
}
```

## Part 5: How Shared Library Functions Work

### Writing a Shared Library Function

**File:** `shared-library/vars/buildApp.groovy`

```groovy
#!/usr/bin/env groovy

/**
 * This function builds the application
 * File name = Function name
 * So buildApp.groovy → you call buildApp()
 */
def call(String workDir = '.') {
    // This code runs when you call buildApp() in pipeline
    
    echo "Building application in ${workDir}"
    
    dir(workDir) {
        if (fileExists('pom.xml')) {
            sh 'mvn clean package'
        }
    }
}
```

**How it works:**
1. Jenkins loads `buildApp.groovy` from shared library
2. When pipeline calls `buildApp('.')`, Jenkins executes the `call()` method
3. The code inside `call()` runs in the pipeline context

### Function Parameters

**Simple function:**
```groovy
// vars/simpleFunction.groovy
def call() {
    echo "Hello"
}

// Usage in pipeline:
simpleFunction()
```

**Function with parameters:**
```groovy
// vars/buildApp.groovy
def call(String workDir) {
    echo "Building in ${workDir}"
}

// Usage in pipeline:
buildApp('.')
buildApp('Jenkins_App')
```

**Function with default parameters:**
```groovy
// vars/buildApp.groovy
def call(String workDir = '.') {
    echo "Building in ${workDir}"
}

// Usage in pipeline:
buildApp()        // Uses default: '.'
buildApp('app')   // Uses: 'app'
```

### Accessing Pipeline Context

Shared library functions can use pipeline steps:

```groovy
def call() {
    // Available pipeline steps:
    sh 'echo "Hello"'           // Shell command
    echo "Message"              // Print message
    dir('folder') { }           // Change directory
    fileExists('file.txt')      // Check if file exists
    writeFile file: 'file', text: 'content'  // Write file
    withCredentials([...]) { }  // Use credentials
}
```

## Part 6: Complete Setup Walkthrough

### Scenario: You have Jenkins running, now set up Lab 23

**Step 1: Copy Shared Library to Jenkins**
```bash
# Get Jenkins pod
JENKINS_POD=$(kubectl get pods -n jenkins -l app=jenkins -o jsonpath='{.items[0].metadata.name}')

# Copy shared library
kubectl cp shared-library jenkins/${JENKINS_POD}:/var/jenkins_home/shared-library -n jenkins

# Verify
kubectl exec -it -n jenkins ${JENKINS_POD} -- ls -la /var/jenkins_home/shared-library/vars
```

**Step 2: Configure in Jenkins UI**
- Follow Step 2 instructions above
- Use path: `/var/jenkins_home/shared-library`

**Step 3: Install Kubernetes Plugin**
- Follow Step 4.1 instructions above

**Step 4: Configure Kubernetes Cloud**
- Follow Step 4.2 instructions above
- Use label: `jenkins-agent`

**Step 5: Test Agent**
- Create test pipeline with `agent { label 'jenkins-agent' }`
- Run it
- Verify pod is created

**Step 6: Create Full Pipeline**
- Use the Jenkinsfile from task-23
- Run it
- Watch it execute on agent using shared library functions

## Part 7: Common Questions

### Q: Where does the pipeline run - master or agent?

**A:** It depends on your `agent` configuration:

```groovy
pipeline {
    agent any  // ← Can run on master OR agent
}

pipeline {
    agent { label 'jenkins-agent' }  // ← Runs ONLY on agent
}

pipeline {
    agent none  // ← No agent, you specify per stage
    stages {
        stage('Build') {
            agent { label 'jenkins-agent' }  // ← This stage runs on agent
            steps { ... }
        }
    }
}
```

### Q: How does Jenkins find the shared library?

**A:** Jenkins looks in this order:
1. **Configured libraries** (from **Configure System** → **Global Pipeline Libraries**)
2. Checks if it's Git or filesystem
3. Downloads/clones if Git
4. Loads functions from `vars/` folder
5. Makes them available in pipeline

### Q: Can I use shared library without agent?

**A:** Yes! Shared library and agents are separate:
- **Shared library** = Reusable code
- **Agent** = Where pipeline runs

You can use shared library on master:
```groovy
@Library('my-library') _
pipeline {
    agent any  // ← Can run on master
    stages {
        stage('Build') {
            steps {
                buildApp()  // ← Shared library function
            }
        }
    }
}
```

### Q: What if agent is offline?

**A:** Pipeline will wait or fail:
- If `agent { label 'jenkins-agent' }` and no agent available → Pipeline waits in queue
- If agent never comes online → Pipeline times out

**Solution:**
- Make sure agent is online: **Manage Jenkins** → **Manage Nodes**
- Or use `agent any` as fallback

### Q: Can I have multiple shared libraries?

**A:** Yes! Configure multiple libraries:
```groovy
@Library('library1') _
@Library('library2') _

pipeline {
    stages {
        stage('Build') {
            steps {
                library1.buildApp()    // From library1
                library2.deploy()      // From library2
            }
        }
    }
}
```

## Summary

**Jenkins Agents:**
- Separate machines/containers that execute builds
- Offload work from master
- Enable parallel builds
- Configure via Kubernetes Plugin or static pods

**Shared Libraries:**
- Reusable Groovy code
- Stored in Git or filesystem
- Functions in `vars/` folder
- Loaded with `@Library('name') _`

**Pipeline Configuration:**
- `agent any` = Master or any agent
- `agent { label 'name' }` = Specific agent
- Shared library functions work on whatever agent runs the pipeline

Now you're ready to set up Lab 23! Follow the step-by-step instructions in the README.
