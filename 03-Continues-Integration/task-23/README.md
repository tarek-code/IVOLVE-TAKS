# IVOLVE Task 23 - CI/CD Pipeline Implementation with Jenkins Agents and Shared Libraries

This lab demonstrates how to create a **Jenkins CI/CD pipeline** using **shared libraries** and **Jenkins agents/slaves** for distributed builds.

---

## 🎓 START HERE - Complete Learning Guide

Welcome! This guide will teach you everything about Jenkins agents and shared libraries step by step.

### 📖 Reading Order (Follow This!)

#### 1️⃣ First: Read the Complete Tutorial

**Time:** 15-20 minutes

**What you'll learn:**

- ✅ What Jenkins agents are (workers that do the build)
- ✅ What shared libraries are (reusable code)
- ✅ Why we use them (better organization, reusability)
- ✅ How they work together
- ✅ Where everything lives (filesystem, Git, Jenkins)

**Key concepts:**

- Master = Coordinator (web UI, manages jobs)
- Agent = Worker (executes builds)
- Shared Library = Reusable functions

#### 2️⃣ Second: Try the Simple Example

**Time:** 10-15 minutes

**What you'll do:**

- Create a simple shared library function
- Copy it to Jenkins
- Configure it in Jenkins UI
- Test it in a pipeline
- See the complete flow in action

**This helps you understand:**

- How to write shared library functions
- How Jenkins finds and loads libraries
- How pipelines use shared library functions

#### 3️⃣ Third: Do the Lab

**Time:** 20-30 minutes

**What you'll build:**

- Complete shared library with 7 functions
- Configure Jenkins agent
- Create full pipeline using shared library
- Deploy application to Kubernetes

### 🎯 Learning Objectives

By the end, you should understand:

1. **Jenkins Agents:**

   - What they are (separate workers)
   - Why we use them (offload master, parallel builds)
   - How to set them up (Kubernetes Plugin or static pods)
   - How pipelines use them (`agent { label 'name' }`)
2. **Shared Libraries:**

   - What they are (reusable Groovy code)
   - Why we use them (no code duplication)
   - How to write them (files in `vars/` folder)
   - Where to put them (Git or filesystem)
   - How Jenkins finds them (configured in UI)
3. **How They Work Together:**

   - Pipeline loads shared library (`@Library('name') _`)
   - Pipeline runs on agent (`agent { label 'name' }`)
   - Agent executes shared library functions
   - Results sent back to master

### 📝 Key Questions Answered

**Q: What is a Jenkins agent/slave?**
A: A separate machine/container that executes build work. The master coordinates, agents do the work.

**Q: Why use agents?**
A:

- Master stays free (just coordinates)
- Multiple builds can run in parallel
- Each agent has dedicated resources
- Can scale by adding more agents

**Q: What is a shared library?**
A: Reusable Groovy code stored in Git or filesystem. Functions you can use in multiple pipelines.

**Q: Why use shared libraries?**
A:

- Write code once, use everywhere
- Update in one place, all pipelines benefit
- Consistent behavior
- Easy to maintain

**Q: Where do I put the shared library?**
A:

- **Option 1:** Git repository (recommended)
- **Option 2:** Jenkins filesystem: `/var/jenkins_home/shared-library`

**Q: How does Jenkins find the shared library?**
A:

1. You configure it in Jenkins UI (Manage Jenkins → Configure System)
2. Jenkins downloads/clones it (if Git) or reads it (if filesystem)
3. When pipeline uses `@Library('name') _`, Jenkins loads it

**Q: Where does the pipeline run - master or agent?**
A: Depends on `agent` configuration:

- `agent any` = Master or any agent
- `agent { label 'name' }` = Specific agent only

**Q: How do shared library functions run on agents?**
A:

1. Pipeline runs on agent (because of `agent { label 'name' }`)
2. Shared library functions execute on that same agent
3. Everything happens on the agent, not master

---

## 📚 Complete Tutorial: Jenkins Agents and Shared Libraries

This tutorial explains everything you need to know about Jenkins agents (slaves) and shared libraries from scratch.

### Part 1: Understanding Jenkins Architecture

#### What is Jenkins Master?

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

#### What are Jenkins Agents/Slaves?

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

#### How It Works

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

### Part 2: Understanding Shared Libraries

#### What is a Shared Library?

**Shared Library** is a collection of reusable Groovy code that:

- Contains common pipeline functions
- Can be used across multiple Jenkinsfiles
- Stored in a Git repository or filesystem
- Loaded into pipelines with `@Library('name') _`

#### Why Use Shared Libraries?

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

#### Shared Library Structure

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

### Part 3: Where Does Jenkins Find Shared Libraries?

#### Option 1: Git Repository (Recommended)

**How it works:**

1. You store shared library in a Git repository
2. Jenkins downloads it when pipeline runs
3. Jenkins caches it locally

**Configuration:**

- **Manage Jenkins** → **Configure System** → **Global Trusted Pipeline Libraries**
- Click **Add**
- Select **Legacy SCM** as retrieval method
- Select **Git** as Source Code Management
- Add repository URL
- Jenkins automatically fetches it

**Example:**

```
Repository: https://github.com/your-username/shared-library.git
Branch: main
Jenkins downloads → /var/jenkins_home/.jenkins/cache/...
```

#### Option 2: Local Filesystem

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

#### Why Put It in Jenkins Path?

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

### Part 4: Where to Copy Shared Library? (Common Confusion Explained)

#### The Question

**You asked:** "Copy to master one or what?"

**Answer:** Copy it to the **Jenkins Master** (the main Jenkins server pod).

#### Visual Explanation

```
┌─────────────────────────────────────────────────────────┐
│  YOUR LOCAL MACHINE                                      │
│  ┌──────────────────┐                                    │
│  │ shared-library/ │  ← You have this locally          │
│  │ ├── vars/       │                                    │
│  │ └── src/        │                                    │
│  └──────────────────┘                                    │
└────────────────────┬────────────────────────────────────┘
                     │
                     │ kubectl cp shared-library ...
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│  KUBERNETES CLUSTER                                      │
│                                                          │
│  ┌──────────────────────────────────────────────────┐  │
│  │  JENKINS MASTER POD                              │  │
│  │  ┌────────────────────────────────────────────┐  │  │
│  │  │ /var/jenkins_home/                        │  │  │
│  │  │ └── shared-library/  ← COPY HERE!          │  │  │
│  │  │     ├── vars/                              │  │  │
│  │  │     └── src/                               │  │  │
│  │  └────────────────────────────────────────────┘  │  │
│  │                                                   │  │
│  │  Jenkins Master:                                 │  │
│  │  - Reads shared library from here                │  │
│  │  - Loads functions when pipeline starts         │  │
│  │  - Sends code to agent when needed              │  │
│  └──────────────────────────────────────────────────┘  │
│                                                          │
│  ┌──────────────────────────────────────────────────┐  │
│  │  JENKINS AGENT POD (Created when needed)        │  │
│  │                                                   │  │
│  │  Agent:                                          │  │
│  │  - Does NOT need shared library files            │  │
│  │  - Receives code from master                     │  │
│  │  - Executes the functions                        │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

#### Step-by-Step: Where to Copy

**Step 1: Find Your Jenkins Master Pod**

```bash
# List all pods in jenkins namespace
kubectl get pods -n jenkins

# You'll see something like:
# NAME                    READY   STATUS    RESTARTS   AGE
# jenkins-7d8f9c4b5-abc123 1/1     Running   0          5d
```

**The pod with name like `jenkins-xxxxx` is your Jenkins master.**

**Step 2: Copy to Jenkins Master**

```bash
# Replace <pod-name> with your actual Jenkins pod name
kubectl cp shared-library jenkins/<pod-name>:/var/jenkins_home/shared-library -n jenkins

# Example:
kubectl cp shared-library jenkins/jenkins-7d8f9c4b5-abc123:/var/jenkins_home/shared-library -n jenkins
```

**This command:**

- Takes `shared-library` folder from your **local machine** (current directory)
- Copies it **into** the Jenkins master pod
- Places it at `/var/jenkins_home/shared-library` **inside the pod**

**Step 3: Verify It's There**

```bash
# Check if files are in Jenkins master
kubectl exec -it -n jenkins <pod-name> -- ls -la /var/jenkins_home/shared-library/vars

# You should see:
# buildApp.groovy
# buildImage.groovy
# deployOnK8s.groovy
# ... etc
```

#### Important Points

**✅ Copy to Master (Correct)**

**Why?**

- Jenkins master **loads** the shared library
- Master **reads** the functions from filesystem
- Master **sends** the code to agent when pipeline runs

**Where?**

- Inside Jenkins master pod
- At `/var/jenkins_home/shared-library`

**❌ Don't Copy to Agent (Wrong)**

**Why not?**

- Agent pods are created dynamically (they come and go)
- Agent doesn't need the files
- Master handles loading and distribution

**What happens:**

1. Master loads shared library
2. Pipeline runs on agent
3. Master sends function code to agent
4. Agent executes it
5. Agent doesn't need the original files

#### Complete Flow

```
1. YOU COPY:
   Local machine → Jenkins master pod
   kubectl cp shared-library jenkins/pod:/var/jenkins_home/shared-library

2. YOU CONFIGURE IN JENKINS UI:
   Manage Jenkins → Configure System → Global Trusted Pipeline Libraries
   Click Add:
   - Name: ivolve-shared-library
   - Retrieval method: Legacy SCM
   - Source Code Management: Git
   - Library Path (optional): /var/jenkins_home/shared-library
   - Load implicitly: Uncheck
   - Allow default version to be overridden: Check

3. PIPELINE STARTS:
   @Library('ivolve-shared-library') _
   ↓
   Jenkins master reads from /var/jenkins_home/shared-library
   ↓
   Master loads functions into memory

4. PIPELINE RUNS ON AGENT:
   agent { label 'jenkins-agent' }
   ↓
   Master sends pipeline code + shared library functions to agent
   ↓
   Agent executes the functions
   ↓
   Agent doesn't need the original files - it has the code in memory
```

#### Common Mistakes

**❌ Mistake 1: Copying to Agent Pod**

```bash
# WRONG - Don't do this!
kubectl cp shared-library jenkins-agent-xxxxx:/shared-library -n jenkins
```

**Why wrong:** Agent pods are temporary, and they don't need the files.

**❌ Mistake 2: Copying to Wrong Path**

```bash
# WRONG - Wrong path
kubectl cp shared-library jenkins/pod:/tmp/shared-library -n jenkins
```

**Why wrong:** Jenkins looks for it at `/var/jenkins_home/shared-library` (or path you configure).

**✅ Correct Way**

```bash
# CORRECT - Copy to Jenkins master at correct path
kubectl cp shared-library jenkins/<master-pod>:/var/jenkins_home/shared-library -n jenkins
```

#### Quick Command Reference

```bash
# 1. Get Jenkins master pod name
JENKINS_POD=$(kubectl get pods -n jenkins -l app=jenkins -o jsonpath='{.items[0].metadata.name}')

# 2. Copy shared library to master
kubectl cp shared-library jenkins/${JENKINS_POD}:/var/jenkins_home/shared-library -n jenkins

# 3. Verify it's there
kubectl exec -it -n jenkins ${JENKINS_POD} -- ls -la /var/jenkins_home/shared-library/vars

# 4. Check structure
kubectl exec -it -n jenkins ${JENKINS_POD} -- tree /var/jenkins_home/shared-library
```

### Part 5: How Shared Library Functions Work

#### Writing a Shared Library Function

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

#### Function Parameters

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

#### Accessing Pipeline Context

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

---

## 🎯 Simple Example: Understanding Shared Libraries and Agents

This is a simple, step-by-step example to help you understand how everything works.

### Example 1: Without Shared Library (Old Way)

**Problem:** Every pipeline has the same code repeated.

**Pipeline 1:**

```groovy
pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                sh 'mvn clean package'  // ← Same code
            }
        }
    }
}
```

**Pipeline 2:**

```groovy
pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                sh 'mvn clean package'  // ← Same code repeated!
            }
        }
    }
}
```

**If you need to change the build command, you update 10+ pipelines!**

### Example 2: With Shared Library (New Way)

**Step 1: Create Shared Library Function**

**File:** `shared-library/vars/buildApp.groovy`

```groovy
def call() {
    sh 'mvn clean package'
}
```

**Step 2: Configure in Jenkins**

- **Manage Jenkins** → **Configure System** → **Global Trusted Pipeline Libraries**
- Click **Add**
- Configure:
  - **Name**: `my-library`
  - **Retrieval method**: **Legacy SCM**
  - **Source Code Management**: **Git**
  - **Library Path (optional)**: `/var/jenkins_home/shared-library`
  - **Load implicitly**: ❌ Uncheck
  - **Allow default version to be overridden**: ✅ Check

**Step 3: Use in Pipeline**

**Pipeline 1:**

```groovy
@Library('my-library') _  // ← Load the library

pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                buildApp()  // ← Use the function!
            }
        }
    }
}
```

**Pipeline 2:**

```groovy
@Library('my-library') _  // ← Same library

pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                buildApp()  // ← Same function, no duplication!
            }
        }
    }
}
```

**Now if you need to change build command, update ONE file!**

### Example 3: Understanding Agents

#### Without Agent (Runs on Master)

```groovy
pipeline {
    agent any  // ← Can run on master
  
    stages {
        stage('Build') {
            steps {
                sh 'mvn clean package'  // ← Runs on master
            }
        }
    }
}
```

**What happens:**

1. You click "Build Now" in Jenkins UI
2. Master executes the build
3. Master's resources are used
4. If master is busy, build waits

#### With Agent (Runs on Separate Machine/Container)

```groovy
pipeline {
    agent { label 'my-agent' }  // ← Must run on agent
  
    stages {
        stage('Build') {
            steps {
                sh 'mvn clean package'  // ← Runs on agent!
            }
        }
    }
}
```

**What happens:**

1. You click "Build Now" in Jenkins UI
2. Master looks for agent with label `my-agent`
3. Master sends build task to agent
4. Agent executes the build (uses agent's resources)
5. Agent sends results back to master
6. You see results in Jenkins UI

**Benefits:**

- Master stays free
- Multiple agents can run builds in parallel
- Each agent has its own resources

### Example 4: Complete Flow

**Scenario:** You have a pipeline that builds and deploys an app.

#### Step 1: Create Shared Library Functions

**File:** `shared-library/vars/buildApp.groovy`

```groovy
def call() {
    echo "Building application..."
    sh 'mvn clean package'
}
```

**File:** `shared-library/vars/deploy.groovy`

```groovy
def call() {
    echo "Deploying application..."
    sh 'kubectl apply -f deployment.yaml'
}
```

#### Step 2: Copy to Jenkins

```bash
# Copy shared library to Jenkins
kubectl cp shared-library jenkins/<pod>:/var/jenkins_home/shared-library -n jenkins
```

#### Step 3: Configure in Jenkins UI

1. **Manage Jenkins** → **Configure System**
2. Scroll to **Global Trusted Pipeline Libraries** section
3. Click **Add**
4. Fill in:
   - **Name**: `my-library`
   - **Retrieval method**: **Legacy SCM**
   - **Source Code Management**: **Git**
   - **Library Path (optional)**: `/var/jenkins_home/shared-library`
   - **Load implicitly**: ❌ Uncheck
   - **Allow default version to be overridden**: ✅ Check
5. Click **Save**

#### Step 4: Set Up Agent

**Option A: Kubernetes Plugin (Automatic)**

1. Install **Kubernetes Plugin**
2. Configure Kubernetes Cloud
3. Add Pod Template with label `my-agent`
4. Agent pods are created automatically when needed

**Option B: Static Pod (Manual)**

1. Create pod using YAML
2. Configure node in Jenkins UI
3. Agent stays running

#### Step 5: Create Pipeline

```groovy
@Library('my-library') _  // ← Load shared library

pipeline {
    agent { label 'my-agent' }  // ← Run on agent
  
    stages {
        stage('Build') {
            steps {
                buildApp()  // ← Shared library function
            }
        }
      
        stage('Deploy') {
            steps {
                deploy()  // ← Shared library function
            }
        }
    }
}
```

#### Step 6: What Happens When You Run It

1. **You click "Build Now"** in Jenkins UI (on master)
2. **Master reads Jenkinsfile:**
   - Sees `@Library('my-library') _` → Loads shared library
   - Sees `agent { label 'my-agent' }` → Looks for agent
3. **Master finds agent:**
   - Agent with label `my-agent` is available
4. **Master sends pipeline to agent:**
   - "Hey agent, run this pipeline"
5. **Agent executes:**
   - Runs `buildApp()` function (from shared library)
   - Runs `deploy()` function (from shared library)
6. **Agent sends results to master:**
   - "Build completed, here are the logs"
7. **You see results in Jenkins UI**

### Visual Flow Diagram

```
┌─────────────────────────────────────────────────────────┐
│                    YOU (Browser)                        │
│              Click "Build Now" in Jenkins UI             │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│              JENKINS MASTER (Web Server)                │
│  ┌──────────────────────────────────────────────────┐  │
│  │ 1. Reads Jenkinsfile                              │  │
│  │    @Library('my-library') _  ← Loads library     │  │
│  │    agent { label 'my-agent' }  ← Finds agent      │  │
│  └──────────────────────────────────────────────────┘  │
│                                                          │
│  ┌──────────────────────────────────────────────────┐  │
│  │ 2. Loads Shared Library                           │  │
│  │    Reads: /var/jenkins_home/shared-library/vars/ │  │
│  │    - buildApp.groovy                             │  │
│  │    - deploy.groovy                               │  │
│  └──────────────────────────────────────────────────┘  │
│                                                          │
│  ┌──────────────────────────────────────────────────┐  │
│  │ 3. Finds Agent                                    │  │
│  │    Looks for agent with label 'my-agent'          │  │
│  │    Agent found!                                  │  │
│  └──────────────────────────────────────────────────┘  │
└────────────────────┬────────────────────────────────────┘
                     │
                     │ Sends pipeline code + shared library
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│              JENKINS AGENT (Worker)                      │
│  ┌──────────────────────────────────────────────────┐  │
│  │ 4. Receives Pipeline                              │  │
│  │    "Run this pipeline code"                      │  │
│  └──────────────────────────────────────────────────┘  │
│                                                          │
│  ┌──────────────────────────────────────────────────┐  │
│  │ 5. Executes Stages                                │  │
│  │    Stage: Build                                   │  │
│  │      → Calls buildApp() from shared library      │  │
│  │      → Runs: mvn clean package                   │  │
│  │                                                   │  │
│  │    Stage: Deploy                                 │  │
│  │      → Calls deploy() from shared library        │  │
│  │      → Runs: kubectl apply -f deployment.yaml   │  │
│  └──────────────────────────────────────────────────┘  │
│                                                          │
│  ┌──────────────────────────────────────────────────┐  │
│  │ 6. Sends Results Back                             │  │
│  │    "Build completed successfully"                │  │
│  │    + Console logs                                 │  │
│  └──────────────────────────────────────────────────┘  │
└────────────────────┬────────────────────────────────────┘
                     │
                     │ Sends results
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│              JENKINS MASTER                              │
│  ┌──────────────────────────────────────────────────┐  │
│  │ 7. Displays Results                               │  │
│  │    Shows in Jenkins UI                            │  │
│  │    You see: "Build #1 Success"                    │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

### Key Points to Remember

1. **Shared Library = Reusable Code**

   - Write functions once
   - Use in multiple pipelines
   - Update in one place
2. **Agent = Worker Machine**

   - Does the actual build work
   - Offloads work from master
   - Can run multiple builds in parallel
3. **Master = Coordinator**

   - Manages everything
   - Sends tasks to agents
   - Shows results in UI
4. **Pipeline Configuration:**

   - `@Library('name') _` = Load shared library
   - `agent { label 'name' }` = Run on specific agent
   - Functions from library work on whatever agent runs the pipeline

### Practice Exercise

Try this step by step:

1. **Create a simple shared library function:**

   ```groovy
   // shared-library/vars/sayHello.groovy
   def call(String name) {
       echo "Hello, ${name}!"
   }
   ```
2. **Copy to Jenkins:**

   ```bash
   kubectl cp shared-library jenkins/<pod>:/var/jenkins_home/shared-library -n jenkins
   ```
3. **Configure in Jenkins:**

   - Add library: `my-library`
   - Path: `/var/jenkins_home/shared-library`
4. **Create test pipeline:**

   ```groovy
   @Library('my-library') _
   pipeline {
       agent any
       stages {
           stage('Test') {
               steps {
                   sayHello('World')
               }
           }
       }
   }
   ```
5. **Run it and see:**

   - Console output: "Hello, World!"

Once this works, you understand the basics! Now you can use the full shared library for Lab 23.

---

## 📋 Quick Reference: Jenkins Agents and Shared Libraries

### What is What?

| Term                     | What It Is               | Where It Lives                 | Purpose                            |
| ------------------------ | ------------------------ | ------------------------------ | ---------------------------------- |
| **Jenkins Master** | Main Jenkins server      | Your Kubernetes cluster or VM  | Provides web UI, manages jobs      |
| **Jenkins Agent**  | Worker machine/container | Separate pod/VM/machine        | Executes actual build work         |
| **Shared Library** | Reusable Groovy code     | Git repo or Jenkins filesystem | Functions you can use in pipelines |
| **Pipeline**       | Build definition         | Jenkinsfile in Git or Jenkins  | Defines what to build and how      |

### Where Does Pipeline Run?

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

### Where Does Shared Library Live?

**Option 1: Git Repository (Recommended)**

```
GitHub/GitLab
└── shared-library/
    ├── vars/
    └── src/
```

- Jenkins downloads it when pipeline runs
- Configure: Manage Jenkins → Configure System → Global Trusted Pipeline Libraries

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

### How to Use Shared Library?

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

### How to Set Up Agent?

**Option 1: Kubernetes Plugin (Best for K8s)**

1. Install Kubernetes Plugin
2. Configure Cloud → Add Kubernetes
3. Add Pod Template with label `jenkins-agent`
4. Agent pods created automatically when needed

**Option 2: Static Pod**

1. Create pod using YAML
2. Configure node in Jenkins UI
3. Agent stays running

### Complete Setup Checklist

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

### Common Commands

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

- **Manage Jenkins** → **System Configuration** → **Nodes**
- Should see agent with status "Connected"

### Troubleshooting Quick Fixes

**Library not found:**

- Check name matches: `@Library('name') _` = Configured library name
- Verify path is correct
- Check Jenkins logs

**Agent not found:**

- Check agent is online: **Manage Jenkins** → **System Configuration** → **Nodes**
- Verify label matches: `agent { label 'name' }` = Agent label
- Check agent can connect to master

**Docker not found on agent:**

- Verify volumes are mounted in pod template
- Check Docker socket permissions
- Verify Docker binary is mounted

---

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

1. **Copy shared library to Jenkins Master:**

   **Important:** Copy it to the **Jenkins Master pod** (not the agent!)

   ```bash
   # First, get your Jenkins master pod name
   kubectl get pods -n jenkins

   # Copy shared library INTO the Jenkins master pod
   kubectl cp shared-library jenkins/<pod-name>:/var/jenkins_home/shared-library -n jenkins
   ```

   **What this does:**

   - Copies `shared-library` folder from your local machine
   - Into the Jenkins master pod at `/var/jenkins_home/shared-library`
   - Jenkins master will read it from there
   - **The agent doesn't need it** - master loads it and sends code to agent when needed
2. **Configure in Jenkins UI:**

   - **Manage Jenkins** → **Configure System**
   - Scroll to **Global Trusted Pipeline Libraries** section
   - Click **Add**
   - Configure:
     - **Name**: `ivolve-shared-library`
     - **Retrieval method**: **Legacy SCM**
     - **Source Code Management**: **Git** (even for filesystem, Legacy SCM requires this)
     - **Library Path (optional)**: `/var/jenkins_home/shared-library`
       - ⚠️ **Note:** This path is **inside the Jenkins master pod**, where you copied the files
     - **Load implicitly**: ❌ Uncheck
     - **Allow default version to be overridden**: ✅ Check
   - Click **Save**
3. **Install Kubernetes Plugin:**

   - Manage Plugins → Install "Kubernetes" plugin
4. **Configure Kubernetes Cloud:**

   - **Manage Jenkins** → **System Configuration** → **Clouds** → Click **Add a new cloud** → **Kubernetes**
   - Add Pod Template with label `jenkins-agent`
5. **Create pipeline job** using the Jenkinsfile

---

## Step-by-Step Instructions

**Important:** Steps are clearly marked as **(MASTER)** or **(SLAVE)** to show where each action happens.

**Workflow Overview:**
1. **Phase 1: Setup on Master** (Steps 1-2): Copy shared library, configure in Jenkins UI
2. **Phase 2: Create and Configure Slave** (Steps 3-4): Create Kubernetes pod, register in Jenkins, install tools
3. **Phase 3: Create and Run Pipeline** (Steps 5-8): Create pipeline job, run it (executes on slave)

**When to Start the Slave:**
- ✅ **After** Step 1-2 (shared library setup on master)
- ✅ **Before** Step 8 (running the pipeline)
- The slave must be **running and connected** before you run the pipeline!

## Master vs Slave: Step-by-Step Breakdown

This section clearly shows which steps are done on **MASTER** vs **SLAVE**.

### Visual Workflow

```
┌─────────────────────────────────────────────────────────┐
│  PHASE 1: SETUP ON MASTER                               │
│  ┌──────────────────────────────────────────────────┐  │
│  │ Step 1: Copy shared library to master pod       │  │
│  │ Step 2: Configure shared library in Jenkins UI  │  │
│  └──────────────────────────────────────────────────┘  │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│  PHASE 2: CREATE AND CONFIGURE SLAVE                  │
│  ┌──────────────────────────────────────────────────┐  │
│  │ Step 3: Create agent pod in K8s (SLAVE)         │  │
│  │ Step 3: Configure agent in Jenkins UI (MASTER)  │  │
│  │ Step 4: Install tools on agent pod (SLAVE)        │  │
│  └──────────────────────────────────────────────────┘  │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│  PHASE 3: CREATE AND RUN PIPELINE                      │
│  ┌──────────────────────────────────────────────────┐  │
│  │ Step 5-7: Create pipeline job (MASTER)            │  │
│  │ Step 8: Run pipeline → Executes on SLAVE          │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

### Quick Reference Table

| Step | Action | Where | Why |
|------|--------|-------|-----|
| 1 | Copy shared library | **Master pod** | Master loads and distributes it |
| 2 | Configure shared library | **Master UI** | Master needs to know where library is |
| 3A | Create agent pod | **K8s cluster (SLAVE)** | Pod will execute builds |
| 3B | Configure agent | **Master UI** | Master needs to know about agent |
| 4 | Install tools | **Agent pod (SLAVE)** | Agent needs tools to run pipeline |
| 5-7 | Create pipeline | **Master UI** | Master manages jobs |
| 8 | Run pipeline | **Agent pod (SLAVE)** | Agent executes all stages |

### Phase 1: Setup on Master (Do This First)

#### Step 1: Copy Shared Library **(MASTER)**

**Where:** Jenkins Master pod

**Action:** Copy files from your local machine to Jenkins master pod

```bash
# On your local machine
kubectl cp shared-library jenkins/<master-pod>:/var/jenkins_home/shared-library -n jenkins
```

**Why master?** Master loads the library and sends code to agent when needed.

#### Step 2: Configure Shared Library **(MASTER)**

**Where:** Jenkins Master (Web UI)

**Action:** Configure shared library in Jenkins configuration

- Go to: **Manage Jenkins** → **Configure System** → **Global Trusted Pipeline Libraries**
- Add library configuration
- Save

**Why master?** Master needs to know where to find the library.

### Phase 2: Create and Configure Slave (Do This Second)

#### Step 3A: Create Agent Pod **(SLAVE)**

**Where:** Kubernetes cluster (same cluster as master)

**Action:** Create a pod that will act as Jenkins agent

```bash
# On your local machine (where you have kubectl)
kubectl apply -f jenkins-agent-config.yaml
```

**Why slave?** This pod will execute builds.

#### Step 3B: Configure Agent in Jenkins **(MASTER)**

**Where:** Jenkins Master (Web UI)

**Action:** Register the agent pod in Jenkins

- Go to: **Manage Jenkins** → **System Configuration** → **Nodes**
- Create new node: `jenkins-agent`
- Configure connection settings

**Why master?** Master needs to know about the agent to send it work.

#### Step 4: Install Tools on Agent Pod **(SLAVE)**

**Where:** Jenkins Agent pod (in Kubernetes)

**Action:** Install Docker, kubectl, Maven, Trivy on the agent

```bash
# Exec into agent pod
kubectl exec -it -n jenkins jenkins-agent -- bash

# Install tools
apt-get update
apt-get install -y maven curl ca-certificates

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/

# Install Trivy
wget -qO- https://aquasecurity.github.io/trivy-repo/deb/public.key | apt-key add -
echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | tee -a /etc/apt/sources.list.d/trivy.list
apt-get update
apt-get install -y trivy
```

**Why slave?** Agent needs these tools to run the pipeline stages.

### Phase 3: Create and Run Pipeline

#### Step 5-7: Create Pipeline Job **(MASTER)**

**Where:** Jenkins Master (Web UI)

**Action:** Create and configure pipeline job

- Create new pipeline job
- Configure Git repository
- Set credentials

**Why master?** Master manages all jobs.

#### Step 8: Run Pipeline **(SLAVE)**

**Where:** Pipeline executes on Jenkins Agent pod

**Action:** All pipeline stages run on the agent

**What happens:**
1. You click "Build Now" in Jenkins UI (on master)
2. Master loads shared library
3. Master sends pipeline code to agent
4. **Agent executes all 7 stages:**
   - RunUnitTest → On agent
   - BuildApp → On agent
   - BuildImage → On agent
   - ScanImage → On agent
   - PushImage → On agent
   - RemoveImageLocally → On agent
   - DeployOnK8s → On agent
5. Agent sends results back to master
6. You see results in Jenkins UI

**Why slave?** Agent has the tools and resources to execute builds.

### Verification Checklist

Before running pipeline, verify:

- [ ] Shared library copied to master pod
- [ ] Shared library configured in Jenkins UI
- [ ] Agent pod created in Kubernetes (`kubectl get pods -n jenkins`)
- [ ] Agent configured in Jenkins UI (Manage Jenkins → System Configuration → Nodes)
- [ ] Agent shows as "Connected" (green icon)
- [ ] Tools installed on agent (Docker, kubectl, Maven, Trivy)
- [ ] Pipeline job created
- [ ] Pipeline configured to use shared library
- [ ] Pipeline configured to run on agent (`agent { label 'jenkins-agent' }`)

### Common Questions

**Q: Do I need to start the slave before configuring shared library?**
A: No. Configure shared library first (on master), then create slave.

**Q: When does the slave need to be running?**
A: The slave must be running and connected before you run the pipeline.

**Q: Can I do steps in different order?**
A: Recommended order:
1. Setup master (Steps 1-2)
2. Create and configure slave (Steps 3-4)
3. Create and run pipeline (Steps 5-8)

**Q: What if slave is not connected?**
A: Check:
- Pod is running: `kubectl get pods -n jenkins`
- Secret is correct in YAML
- Jenkins URL is correct in YAML
- Pod logs: `kubectl logs jenkins-agent -n jenkins`

---

### Step 1: Set Up Shared Library Repository **(MASTER)**

**Where:** Jenkins Master pod

**What:** Copy shared library files to Jenkins master

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

1. **Copy `shared-library` folder to Jenkins Master:**

   **Important:** Copy to the **Jenkins Master pod**, not the agent!

   ```bash
   # Step 1: Get Jenkins master pod name
   kubectl get pods -n jenkins
   # Look for pod like: jenkins-xxxxx-xxxxx

   # Step 2: Copy to Jenkins master pod
   # If Jenkins is in Kubernetes
   kubectl cp shared-library jenkins/<master-pod-name>:/var/jenkins_home/shared-library -n jenkins

   # If Jenkins is in Docker
   docker cp shared-library jenkins:/var/jenkins_home/shared-library
   ```

   **What this does:**

   - Copies shared library **into** the Jenkins master pod
   - Jenkins master will read it from `/var/jenkins_home/shared-library`
   - The agent doesn't need it - master loads and distributes it
2. Configure Jenkins to use local path (see Step 2)

### Step 2: Configure Shared Library in Jenkins UI **(MASTER)**

**Where:** Jenkins Master (Web UI)

**What:** Configure shared library in Jenkins configuration

1. Go to **Manage Jenkins** → **Configure System**
2. Scroll down to **Global Trusted Pipeline Libraries** section
3. Click **Add** button
4. Configure the library with these exact settings:

   **Basic Configuration:**
   - **Name**: `ivolve-shared-library` (must match `@Library` name in Jenkinsfile)
   - **Default version**: `main` (or your branch name, leave empty for filesystem)
   - **Load implicitly**: ❌ **Uncheck** (we'll load explicitly with `@Library`)
   - **Allow default version to be overridden**: ✅ **Check** (allows using different versions)
   - **Include @Library changes in job recent changes**: ✅ **Check** (optional, for tracking)
   - **Cache fetched versions on controller for quick retrieval**: ✅ **Check** (recommended)
   
   **Retrieval Method:**
   - Select **Legacy SCM** (works for both Git and filesystem)
   
   **If using Git (Option A):**
   - **Source Code Management**: Select **Git**
   - **Repositories**: Click **Add Repository**
     - **Repository URL**: Enter your Git repository URL
       - Example: `https://github.com/YOUR_USERNAME/ivolve-jenkins-shared-library.git`
     - **Credentials**: Add if repository is private
   - **Branches to build**: Click **Add Branch**
     - **Branch Specifier**: `*/main` or `*/master`
   - **Library Path (optional)**: Leave empty (Git repo root is used)
   
   **If using Local Filesystem (Option B):**
   - **Retrieval method**: **Legacy SCM**
   - **Source Code Management**: Select **Git** (Legacy SCM still requires SCM selection)
   - **Repositories**: Leave empty or don't add any repository
   - **Library Path (optional)**: `/var/jenkins_home/shared-library`
     - ⚠️ **Important**: This is the path **inside the Jenkins master pod** where you copied the files
   - **Default version**: Leave empty (not needed for filesystem)

5. Click **Save** at the bottom of the page

**Verify Configuration:**
- Go to **Manage Jenkins** → **System Information**
- Look for "Pipeline Libraries" or "Global Trusted Pipeline Libraries" section
- Verify your library `ivolve-shared-library` is listed

**Troubleshooting:**
- If library not found: Check the name matches exactly (case-sensitive)
- If path not working: Verify files are at `/var/jenkins_home/shared-library` inside Jenkins pod
- If using Git: Make sure repository is accessible and branch exists

---

### Step 3: Create and Configure Jenkins Agent/Slave Pod in Kubernetes **(SLAVE)**

**Where:** Kubernetes cluster (same cluster as Jenkins master)

**What:** Create a static Jenkins agent pod using YAML and register it in Jenkins

**This is the recommended approach for this lab** - creating a static pod in the same K8s cluster.

#### Part A: Create Agent Pod in Kubernetes

**On your local machine (where you have kubectl):**

1. **Get Jenkins master URL and secret:**

   First, you need to get the connection details from Jenkins:
   
   - Go to **Manage Jenkins** → **System Configuration** → **Nodes**
   - Click **New Node**
   - **Node name**: `jenkins-agent`
   - **Type**: **Permanent Agent**
   - Click **OK**
   - On the configuration page, you'll see connection instructions
   - **Don't configure anything yet** - just note the **secret** shown on the page
   - Click **Cancel** for now (we'll configure after pod is created)

2. **Update the YAML file with Jenkins URL:**

   The `jenkins-agent-config.yaml` file already has the Jenkins URL configured. Verify it matches your setup:
   
   ```yaml
   env:
   - name: JENKINS_URL
     value: "http://jenkins-service.jenkins.svc.cluster.local:8080"
   ```
   
   If your Jenkins service has a different name, update it.

3. **Create the agent pod:**

   ```bash
   # Apply the YAML to create the pod
   kubectl apply -f jenkins-agent-config.yaml
   
   # Verify pod is created
   kubectl get pods -n jenkins
   # You should see: jenkins-agent
   ```

4. **Get the connection secret from Jenkins:**

   - Go to **Manage Jenkins** → **System Configuration** → **Nodes**
   - Click **New Node** again
   - **Node name**: `jenkins-agent`
   - **Type**: **Permanent Agent**
   - Click **OK**
   - On the page, you'll see a **secret** (long random string)
   - Copy this secret

5. **Update the pod with the secret:**

   ```bash
   # Edit the YAML file and add the secret
   # Or use kubectl to update the pod
   kubectl set env deployment/jenkins-agent JENKINS_SECRET="YOUR_SECRET_HERE" -n jenkins
   
   # If using pod directly (not deployment), patch it:
   kubectl patch pod jenkins-agent -n jenkins -p '{"spec":{"containers":[{"name":"jenkins-agent","env":[{"name":"JENKINS_SECRET","value":"YOUR_SECRET_HERE"}]}]}}'
   ```
   
   **Or edit the YAML file and reapply:**
   
   ```yaml
   env:
   - name: JENKINS_SECRET
     value: "YOUR_ACTUAL_SECRET_HERE"  # Paste the secret from Jenkins UI
   ```
   
   Then:
   ```bash
   kubectl delete pod jenkins-agent -n jenkins  # Delete old pod
   kubectl apply -f jenkins-agent-config.yaml   # Create new pod with secret
   ```

#### Part B: Configure Agent in Jenkins UI **(MASTER)**

**Where:** Jenkins Master (Web UI)

**What:** Register the agent pod in Jenkins

1. **Go to Jenkins UI:**
   - **Manage Jenkins** → **System Configuration** → **Nodes**
   - Click **New Node**

2. **Configure the node:**
   - **Node name**: `jenkins-agent` (must match pod name)
   - **Type**: **Permanent Agent**
   - Click **OK**

3. **Configure agent settings:**
   - **Remote root directory**: `/home/jenkins/agent`
   - **Launch method**: **Launch agent via Java Web Start**
   - **Labels**: `jenkins-agent` ⚠️ **Important:** This must match the label in your Jenkinsfile: `agent { label 'jenkins-agent' }`
   - **Usage**: **Only build jobs with label expressions matching this node**
   - **Number of executors**: `2` (or as needed)
   - Click **Save**

4. **Connect the agent:**
   - On the node page, you'll see connection instructions
   - The agent pod should automatically connect using the secret
   - Check agent status: Should show **"Connected"** (green icon)
   - If not connected, check pod logs: `kubectl logs jenkins-agent -n jenkins`

**Alternative: Manual Connection (if automatic doesn't work)**

If the agent doesn't connect automatically:

1. **Get connection command from Jenkins:**
   - On the node page, you'll see a command like:
     ```
     java -jar agent.jar -jnlpUrl http://jenkins:8080/computer/jenkins-agent/slave-agent.jnlp -secret <secret> -workDir /home/jenkins/agent
     ```

2. **Run it in the agent pod:**
   ```bash
   # Exec into the agent pod
   kubectl exec -it -n jenkins jenkins-agent -- bash
   
   # Download agent.jar (if not present)
   wget http://jenkins-service.jenkins.svc.cluster.local:8080/jnlpJars/agent.jar
   
   # Run the connection command
   java -jar agent.jar -jnlpUrl http://jenkins-service.jenkins.svc.cluster.local:8080/computer/jenkins-agent/slave-agent.jnlp -secret YOUR_SECRET -workDir /home/jenkins/agent
   ```

**Verify Agent is Connected:**
- Go to **Manage Jenkins** → **System Configuration** → **Nodes**
- You should see `jenkins-agent` with status **"Connected"** (green icon)
- If it shows "Disconnected" or "Offline", check the pod logs

---

### Step 4: Install Required Tools on Agent Pod **(SLAVE)**

**Where:** Jenkins Agent pod (in Kubernetes)

**What:** Install Docker, kubectl, Maven, and Trivy on the agent pod

**The agent needs these tools to run the pipeline:**
- **Docker** (for building images) - Already available via volume mount
- **kubectl** (for deploying to K8s)
- **Maven** (for building Java apps)
- **Trivy** (for image scanning - will be installed automatically by shared library, but pre-installing is faster)

#### Option A: Install Tools Directly in Pod (Quick Method)

```bash
# Exec into the agent pod
kubectl exec -it -n jenkins jenkins-agent -- bash

# Switch to root (pod runs as root already, but verify)
whoami  # Should show: root

# Install required packages
apt-get update
apt-get install -y \
    maven \
    curl \
    ca-certificates \
    wget \
    gnupg \
    lsb-release

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/kubectl
kubectl version --client

# Install Trivy
wget -qO- https://aquasecurity.github.io/trivy-repo/deb/public.key | apt-key add -
echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | tee -a /etc/apt/sources.list.d/trivy.list
apt-get update
apt-get install -y trivy
trivy --version

# Verify Docker is accessible
docker --version
docker ps

# Exit the pod
exit
```

**Note:** These changes are **temporary** - they'll be lost if the pod restarts. For permanent installation, use Option B.

#### Option B: Create Custom Agent Image with Tools (Permanent Method)

This creates a custom Docker image with all tools pre-installed.

1. **Build custom agent image:**

   Use the provided `Dockerfile.agent`:
   
   ```bash
   # Build the image
   docker build -f Dockerfile.agent -t your-username/jenkins-agent:latest .
   
   # Push to Docker Hub (or your registry)
   docker push your-username/jenkins-agent:latest
   ```

2. **Update the YAML file:**

   Edit `jenkins-agent-config.yaml`:
   
   ```yaml
   containers:
   - name: jenkins-agent
     image: your-username/jenkins-agent:latest  # Changed from jenkins/inbound-agent:latest
     # ... rest of config
   ```

3. **Recreate the pod:**

   ```bash
   # Delete old pod
   kubectl delete pod jenkins-agent -n jenkins
   
   # Create new pod with custom image
   kubectl apply -f jenkins-agent-config.yaml
   ```

**Verify Tools are Installed:**

```bash
# Check tools in agent pod
kubectl exec -it -n jenkins jenkins-agent -- bash -c "mvn -version && kubectl version --client && trivy --version && docker --version"
```

**Note:** Trivy will be installed automatically by the `scanImage` shared library function if not present, but pre-installing it is faster.

---

### Step 5: Create Pipeline Job **(MASTER)**

**Where:** Jenkins Master (Web UI)

**What:** Create a new pipeline job

1. Go to **New Item**
2. Enter name: `jenkins-app-pipeline-lab23`
3. Select **Pipeline**
4. Click **OK**

#### Option 1: Kubernetes Plugin (Recommended for K8s Environment)

This is the **best option** for Kubernetes environments as it dynamically creates agents on demand.

1. **Install Kubernetes Plugin** in Jenkins:

   - Go to **Manage Jenkins** → **Manage Plugins** → **Available**
   - Search for "Kubernetes"
   - Install and restart Jenkins
2. **Configure Kubernetes Cloud:**

   - Go to **Manage Jenkins** → **System Configuration** → **Clouds**
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

   - Go to **Manage Jenkins** → **System Configuration** → **Nodes**
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

   - Go to **Manage Jenkins** → **System Configuration** → **Nodes**
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

**See Step 4 above for detailed instructions on installing tools on the static agent pod.**

### Step 6: Configure Pipeline **(MASTER)**

**Where:** Jenkins Master (Web UI)

**What:** Configure pipeline to use shared library and run on agent

In the pipeline configuration:

1. **Pipeline Definition**: Select **Pipeline script from SCM**
2. **SCM**: Select **Git**
3. **Repository URL**: `https://github.com/Ibrahim-Adel15/Jenkins_App.git`
4. **Branches to build**: `*/main` or `*/master`
5. **Script Path**: `Jenkinsfile` (or path to your Jenkinsfile)
6. Click **Save**

**Note:** Make sure your Jenkinsfile is in the repository or use **Pipeline script** to paste it directly.

### Step 7: Configure Credentials **(MASTER)**

**Where:** Jenkins Master (Web UI)

**What:** Configure Docker Hub and Kubernetes credentials

Ensure these credentials are configured in Jenkins (same as Lab 22):

1. **Docker Hub credentials** (ID: `dockerhub-credentials`)
2. **Kubernetes kubeconfig** (ID: `kubeconfig`) - Optional if using ServiceAccount

### Step 8: Run the Pipeline **(SLAVE)**

**Where:** Pipeline runs on Jenkins Agent pod

**What:** Execute the pipeline - all stages run on the agent

1. Go to your pipeline job: `jenkins-app-pipeline-lab23`
2. Click **Build Now**
3. Watch the pipeline execution

**What happens:**
- Pipeline starts on **Jenkins Master** (you click Build Now)
- Master loads shared library from `/var/jenkins_home/shared-library`
- Master sends pipeline code to **Jenkins Agent** pod
- **All 7 stages execute on the agent pod:**
  1. RunUnitTest - Runs on agent
  2. BuildApp - Runs on agent
  3. BuildImage - Runs on agent (uses Docker on agent)
  4. ScanImage - Runs on agent
  5. PushImage - Runs on agent
  6. RemoveImageLocally - Runs on agent
  7. DeployOnK8s - Runs on agent (uses kubectl on agent)
- Agent sends results back to master
- You see results in Jenkins UI

**Verify it's running on agent:**
- In console output, look for: "Running on jenkins-agent"
- Check agent pod logs: `kubectl logs jenkins-agent -n jenkins -f`

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

1. Verify agent is online: **Manage Jenkins** → **System Configuration** → **Nodes**
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

| Stage | Shared Library Function  | Purpose                  |
| ----- | ------------------------ | ------------------------ |
| 1     | `runUnitTest()`        | Run unit tests           |
| 2     | `buildApp()`           | Build application        |
| 3     | `buildImage()`         | Build Docker image       |
| 4     | `scanImage()`          | Scan for vulnerabilities |
| 5     | `pushImage()`          | Push to Docker Hub       |
| 6     | `removeImageLocally()` | Clean up local images    |
| 7     | `deployOnK8s()`        | Deploy to Kubernetes     |

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
