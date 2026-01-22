# Simple Example: Understanding Shared Libraries and Agents

This is a simple, step-by-step example to help you understand how everything works.

## Example 1: Without Shared Library (Old Way)

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

## Example 2: With Shared Library (New Way)

**Step 1: Create Shared Library Function**

**File:** `shared-library/vars/buildApp.groovy`
```groovy
def call() {
    sh 'mvn clean package'
}
```

**Step 2: Configure in Jenkins**
- Manage Jenkins → Configure System → Global Pipeline Libraries
- Name: `my-library`
- Path: `/var/jenkins_home/shared-library`

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

## Example 3: Understanding Agents

### Without Agent (Runs on Master)

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

### With Agent (Runs on Separate Machine/Container)

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

## Example 4: Complete Flow

**Scenario:** You have a pipeline that builds and deploys an app.

### Step 1: Create Shared Library Functions

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

### Step 2: Copy to Jenkins

```bash
# Copy shared library to Jenkins
kubectl cp shared-library jenkins/<pod>:/var/jenkins_home/shared-library -n jenkins
```

### Step 3: Configure in Jenkins UI

1. **Manage Jenkins** → **Configure System**
2. Scroll to **Global Pipeline Libraries**
3. Click **Add**
4. Fill in:
   - **Name**: `my-library`
   - **Path**: `/var/jenkins_home/shared-library`
5. Click **Save**

### Step 4: Set Up Agent

**Option A: Kubernetes Plugin (Automatic)**
1. Install **Kubernetes Plugin**
2. Configure Kubernetes Cloud
3. Add Pod Template with label `my-agent`
4. Agent pods are created automatically when needed

**Option B: Static Pod (Manual)**
1. Create pod using YAML
2. Configure node in Jenkins UI
3. Agent stays running

### Step 5: Create Pipeline

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

### Step 6: What Happens When You Run It

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

## Visual Flow Diagram

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

## Key Points to Remember

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

## Practice Exercise

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
