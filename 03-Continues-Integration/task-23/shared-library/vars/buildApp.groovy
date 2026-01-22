#!/usr/bin/env groovy

/**
 * Shared Library Function: BuildApp
 * Builds the application based on the project type
 * 
 * @param workDir Working directory where the project is located
 */
def call(String workDir = '.') {
    echo "============================================"
    echo "Stage: BuildApp"
    echo "============================================"
    
    dir(workDir) {
        script {
            if (fileExists('pom.xml')) {
                echo "Detected Maven project - Building application..."
                sh 'mvn clean package -DskipTests'
            } else if (fileExists('package.json')) {
                echo "Detected Node.js project - Building application..."
                sh 'npm install && npm run build || echo "npm not found, Docker build will handle it"'
            } else if (fileExists('requirements.txt')) {
                echo "Detected Python project - Installing dependencies..."
                sh 'pip install -r requirements.txt || echo "pip not found, Docker build will handle it"'
            } else {
                echo "No build step needed - Dockerfile will handle build"
            }
        }
    }
    
    echo "Build application stage completed"
}
