#!/usr/bin/env groovy

/**
 * Shared Library Function: PushImage
 * Pushes Docker image to Docker Hub
 * 
 * @param imageName Full image name with tag (e.g., username/repo:tag)
 * @param credentialsId Jenkins credential ID for Docker Hub (default: 'dockerhub-credentials')
 */
def call(String imageName, String credentialsId = 'dockerhub-credentials') {
    echo "============================================"
    echo "Stage: PushImage"
    echo "============================================"
    
    script {
        def imageRepo = imageName.split(':')[0]
        def imageTag = imageName.split(':').length > 1 ? imageName.split(':')[1] : 'latest'
        
        try {
            withCredentials([usernamePassword(credentialsId: credentialsId, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                sh """
                    echo \${DOCKER_PASS} | docker login -u \${DOCKER_USER} --password-stdin
                    docker push ${imageName}
                    docker push ${imageRepo}:latest
                """
            }
        } catch (Exception e) {
            echo "Credentials not found, trying environment variables..."
            sh """
                docker login -u \${DOCKERHUB_USER} -p \${DOCKERHUB_PASSWORD ?: ''} || echo "Login failed"
                docker push ${imageName} || echo "Push failed"
                docker push ${imageRepo}:latest || echo "Push latest failed"
            """
        }
    }
    
    echo "Push image stage completed"
}
