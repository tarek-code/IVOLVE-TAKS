#!/bin/bash

# ArgoCD Installation Script for Kubernetes
# This script installs ArgoCD in the argocd namespace

set -e

echo "============================================"
echo "Installing ArgoCD in Kubernetes"
echo "============================================"

# Create argocd namespace
echo "Creating argocd namespace..."
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

# Install ArgoCD
echo "Installing ArgoCD..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "Waiting for ArgoCD pods to be ready..."
kubectl wait --for=condition=ready pod --all -n argocd --timeout=300s

# Get ArgoCD server service
echo ""
echo "============================================"
echo "ArgoCD Installation Complete!"
echo "============================================"
echo ""
echo "To access ArgoCD UI:"
echo "1. Port forward: kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo "2. Get admin password: kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath=\"{.data.password}\" | base64 -d"
echo "3. Access UI at: https://localhost:8080"
echo "   Username: admin"
echo "   Password: (from step 2)"
echo ""
echo "Or expose via NodePort/LoadBalancer:"
echo "kubectl patch svc argocd-server -n argocd -p '{\"spec\": {\"type\": \"NodePort\"}}'"
echo "kubectl get svc argocd-server -n argocd"
