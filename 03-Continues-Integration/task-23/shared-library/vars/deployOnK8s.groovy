#!/usr/bin/env groovy

/**
 * Shared Library Function: DeployOnK8s
 * Deploys application to Kubernetes cluster
 * 
 * @param imageName Full image name with tag (e.g., username/repo:tag)
 * @param namespace Kubernetes namespace (default: 'ivolve')
 * @param deploymentFile Path to deployment.yaml file (default: 'deployment.yaml')
 * @param workDir Working directory where deployment.yaml is located (default: '.')
 */
def call(String imageName, String namespace = 'ivolve', String deploymentFile = 'deployment.yaml', String workDir = '.') {
    echo "============================================"
    echo "Stage: DeployOnK8s"
    echo "============================================"
    
    dir(workDir) {
        script {
            // Create or update deployment.yaml with new image
            if (!fileExists(deploymentFile)) {
                echo "${deploymentFile} not found, creating it..."
                writeFile file: deploymentFile, text: """apiVersion: apps/v1
kind: Deployment
metadata:
  name: jenkins-app
  namespace: ${namespace}
  labels:
    app: jenkins-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: jenkins-app
  template:
    metadata:
      labels:
        app: jenkins-app
    spec:
      containers:
        - name: jenkins-app
          image: ${imageName}
          ports:
            - containerPort: 3000
              name: http
          resources:
            requests:
              memory: "256Mi"
              cpu: "100m"
            limits:
              memory: "512Mi"
              cpu: "500m"
          livenessProbe:
            httpGet:
              path: /
              port: 3000
            initialDelaySeconds: 60
            periodSeconds: 10
            timeoutSeconds: 5
            failureThreshold: 3
          readinessProbe:
            httpGet:
              path: /
              port: 3000
            initialDelaySeconds: 30
            periodSeconds: 10
            timeoutSeconds: 5
            failureThreshold: 3
---
apiVersion: v1
kind: Service
metadata:
  name: jenkins-app-service
  namespace: ${namespace}
spec:
  type: ClusterIP
  ports:
    - port: 80
      targetPort: 3000
      protocol: TCP
      name: http
  selector:
    app: jenkins-app
"""
            } else {
                // Update existing deployment.yaml
                echo "Updating ${deploymentFile} with new image: ${imageName}"
                sh """
                    sed -i 's|image: .*|image: ${imageName}|g' ${deploymentFile}
                """
            }
            
            // Deploy to Kubernetes
            try {
                withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG_FILE')]) {
                    sh """
                        export KUBECONFIG=\${KUBECONFIG_FILE}
                        kubectl create namespace ${namespace} --dry-run=client -o yaml | kubectl apply -f - || true
                        kubectl apply -f ${deploymentFile}
                        kubectl rollout status deployment/jenkins-app -n ${namespace} --timeout=300s || echo "Rollout status check completed or timed out"
                        echo "=== Deployment Status ==="
                        kubectl get deployment jenkins-app -n ${namespace}
                        echo "=== Pod Status ==="
                        kubectl get pods -n ${namespace} -l app=jenkins-app
                    """
                }
            } catch (Exception e) {
                echo "kubeconfig credential not found, trying ServiceAccount (if Jenkins is in K8s)..."
                sh """
                    kubectl create namespace ${namespace} --dry-run=client -o yaml | kubectl apply -f - || true
                    kubectl apply -f ${deploymentFile}
                    kubectl rollout status deployment/jenkins-app -n ${namespace} --timeout=300s || echo "Rollout status check completed or timed out"
                    echo "=== Deployment Status ==="
                    kubectl get deployment jenkins-app -n ${namespace}
                    echo "=== Pod Status ==="
                    kubectl get pods -n ${namespace} -l app=jenkins-app
                """
            }
        }
    }
    
    echo "Deploy on K8s stage completed"
}
