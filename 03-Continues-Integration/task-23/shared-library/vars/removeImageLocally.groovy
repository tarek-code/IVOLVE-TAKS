#!/usr/bin/env groovy

/**
 * Shared Library Function: RemoveImageLocally
 * Removes Docker image from local Docker daemon
 * 
 * @param imageName Full image name with tag (e.g., username/repo:tag)
 */
def call(String imageName) {
    echo "============================================"
    echo "Stage: RemoveImageLocally"
    echo "============================================"
    
    script {
        def imageRepo = imageName.split(':')[0]
        
        sh """
            docker rmi ${imageName} || echo "Image ${imageName} not found locally"
            docker rmi ${imageRepo}:latest || echo "Image ${imageRepo}:latest not found locally"
        """
    }
    
    echo "Remove image locally stage completed"
}
