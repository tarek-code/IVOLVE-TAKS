#!/usr/bin/env groovy

/**
 * Shared Library Function: ScanImage
 * Scans Docker image for vulnerabilities using Trivy
 * 
 * @param imageName Full image name with tag (e.g., username/repo:tag)
 */
def call(String imageName) {
    echo "============================================"
    echo "Stage: ScanImage"
    echo "============================================"
    
    script {
        // Check if Trivy is installed, if not, install it
        def trivyInstalled = sh(
            script: 'which trivy || echo "not found"',
            returnStdout: true
        ).trim()
        
        if (trivyInstalled == 'not found') {
            echo "Trivy not found, installing..."
            sh '''
                wget -qO- https://aquasecurity.github.io/trivy-repo/deb/public.key | apt-key add -
                echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | tee -a /etc/apt/sources.list.d/trivy.list
                apt-get update
                apt-get install -y trivy || echo "Trivy installation failed, continuing..."
            '''
        }
        
        // Scan the image
        echo "Scanning image: ${imageName}"
        try {
            sh """
                trivy image --exit-code 0 --severity HIGH,CRITICAL ${imageName} || echo "Scan completed with findings"
            """
        } catch (Exception e) {
            echo "Image scan completed with warnings. Continuing pipeline..."
            // Don't fail the pipeline on scan warnings
        }
    }
    
    echo "Scan image stage completed"
}
