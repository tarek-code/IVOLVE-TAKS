#!/bin/bash

# Create gitops namespace for ArgoCD deployments

set -e

echo "============================================"
echo "Creating gitops namespace"
echo "============================================"

kubectl create namespace gitops --dry-run=client -o yaml | kubectl apply -f -

echo "Namespace 'gitops' created successfully!"
echo ""
echo "Verify:"
kubectl get namespace gitops
