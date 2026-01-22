# Jenkins Shared Library for Lab 23

This shared library contains reusable Groovy functions for CI/CD pipelines.

## Structure

```
shared-library/
├── vars/                    # Global variables (pipeline steps)
│   ├── runUnitTest.groovy
│   ├── buildApp.groovy
│   ├── buildImage.groovy
│   ├── scanImage.groovy
│   ├── pushImage.groovy
│   ├── removeImageLocally.groovy
│   └── deployOnK8s.groovy
└── src/                     # Source files (classes)
    └── org/ivolve/
        └── PipelineUtils.groovy
```

## Available Functions

### runUnitTest(workDir)
Runs unit tests based on project type (Maven, npm, Python).

### buildApp(workDir)
Builds the application based on project type.

### buildImage(imageName, workDir)
Builds Docker image from Dockerfile.

### scanImage(imageName)
Scans Docker image for vulnerabilities using Trivy.

### pushImage(imageName, credentialsId)
Pushes Docker image to Docker Hub.

### removeImageLocally(imageName)
Removes Docker image from local Docker daemon.

### deployOnK8s(imageName, namespace, deploymentFile, workDir)
Deploys application to Kubernetes cluster.

## Usage in Jenkinsfile

```groovy
@Library('ivolve-shared-library') _

pipeline {
    agent any
    stages {
        stage('RunUnitTest') {
            steps {
                runUnitTest('.')
            }
        }
        // ... other stages
    }
}
```
