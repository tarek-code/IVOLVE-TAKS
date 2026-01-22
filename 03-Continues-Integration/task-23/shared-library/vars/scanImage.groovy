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
                # Try apt method first, fallback to direct download if apt-key not available
                if command -v apt-key >/dev/null 2>&1; then
                    wget -qO- https://aquasecurity.github.io/trivy-repo/deb/public.key | apt-key add - && \
                    echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | tee -a /etc/apt/sources.list.d/trivy.list && \
                    apt-get update && \
                    apt-get install -y trivy || echo "apt installation failed, trying direct download..."
                fi
                # Direct download method (works when apt-key is not available)
                if ! command -v trivy >/dev/null 2>&1; then
                    echo "Installing Trivy via direct download..."
                    TRIVY_VERSION=$(curl -s https://api.github.com/repos/aquasecurity/trivy/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')
                    wget -q https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz
                    tar -xzf trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz
                    mv trivy /usr/local/bin/trivy
                    chmod +x /usr/local/bin/trivy
                    rm -f trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz
                fi
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
