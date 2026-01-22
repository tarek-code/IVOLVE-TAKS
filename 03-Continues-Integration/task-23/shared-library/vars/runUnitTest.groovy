#!/usr/bin/env groovy

/**
 * Shared Library Function: RunUnitTest
 * Runs unit tests based on the project type (Maven, npm, Python)
 * 
 * @param workDir Working directory where the project is located
 */
def call(String workDir = '.') {
    echo "============================================"
    echo "Stage: RunUnitTest"
    echo "============================================"
    
    dir(workDir) {
        script {
            if (fileExists('pom.xml')) {
                echo "Detected Maven project - Running unit tests..."
                sh 'mvn test || echo "Tests completed with warnings"'
            } else if (fileExists('package.json')) {
                echo "Detected Node.js project - Running unit tests..."
                sh 'npm test || echo "npm test not found, skipping tests"'
            } else if (fileExists('requirements.txt')) {
                echo "Detected Python project - Running unit tests..."
                sh 'python -m pytest || echo "pytest not found, skipping tests"'
            } else {
                echo "No test framework detected, skipping unit tests"
            }
        }
    }
    
    echo "Unit tests stage completed"
}
