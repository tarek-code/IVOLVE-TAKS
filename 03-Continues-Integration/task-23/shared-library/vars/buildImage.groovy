#!/usr/bin/env groovy

/**
 * Shared Library Function: BuildImage
 * Builds Docker image from Dockerfile
 * 
 * @param imageName Full image name with tag (e.g., username/repo:tag)
 * @param workDir Working directory where Dockerfile is located
 */
def call(String imageName, String workDir = '.') {
    echo "============================================"
    echo "Stage: BuildImage"
    echo "============================================"
    
    dir(workDir) {
        script {
            if (!fileExists('Dockerfile')) {
                error("Dockerfile not found in ${workDir}")
            }
            
            echo "Building Docker image: ${imageName}"
            sh """
                docker build -t ${imageName} .
                docker tag ${imageName} ${imageName.split(':')[0]}:latest
            """
        }
    }
    
    echo "Build image stage completed"
}
