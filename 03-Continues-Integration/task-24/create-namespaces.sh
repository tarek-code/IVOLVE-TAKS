#!/bin/bash

# Script to create Kubernetes namespaces for Lab 24
# Usage: ./create-namespaces.sh

set -e

echo "============================================"
echo "Creating Kubernetes namespaces"
echo "============================================"

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "Error: kubectl is not installed or not in PATH"
    exit 1
fi

# Apply namespaces
echo "Applying namespaces.yaml..."
kubectl apply -f namespaces.yaml

# Wait a moment for namespaces to be created
sleep 2

# Verify namespaces
echo ""
echo "Verifying namespaces..."
kubectl get namespaces | grep -E "prod|stag|dev" || echo "Namespaces not found. Check if they were created."

echo ""
echo "Namespace details:"
kubectl get namespace prod stag dev --show-labels 2>/dev/null || echo "Some namespaces may not exist yet."

echo ""
echo "============================================"
echo "Namespaces setup complete!"
echo "============================================"
echo ""
echo "Created namespaces:"
echo "  - prod (production)"
echo "  - stag (staging)"
echo "  - dev (development)"
echo ""
