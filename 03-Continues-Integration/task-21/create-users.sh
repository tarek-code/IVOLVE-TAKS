#!/bin/bash
# Create user1 and user2 for Kubernetes RBAC using client certificates.
# This script matches the manual steps: creates certs and adds them to kubectl config.
# Run this on the master node where you have access to the cluster CA.
set -e

# Detect cluster type and set default CA paths
# For k3s:
if [ -f "/var/lib/rancher/k3s/server/tls/client-ca.crt" ]; then
  CA="${CA:-/var/lib/rancher/k3s/server/tls/client-ca.crt}"
  CAKEY="${CAKEY:-/var/lib/rancher/k3s/server/tls/client-ca.key}"
# For kubeadm:
elif [ -f "/etc/kubernetes/pki/ca.crt" ]; then
  CA="${CA:-/etc/kubernetes/pki/ca.crt}"
  CAKEY="${CAKEY:-/etc/kubernetes/pki/ca.key}"
else
  echo "Error: Could not find cluster CA. Please set CA and CAKEY environment variables."
  echo "  Example: CA=/path/to/ca.crt CAKEY=/path/to/ca.key $0"
  exit 1
fi

echo "Using CA: $CA"
echo "Using CA Key: $CAKEY"

# Create certificates in current directory (like you did)
for u in user1 user2; do
  echo "Creating key and CSR for $u (CN=$u) ..."
  openssl genrsa -out "${u}.key" 2048
  openssl req -new -key "${u}.key" -out "${u}.csr" -subj "/CN=${u}"
  echo "Signing certificate for $u ..."
  openssl x509 -req -in "${u}.csr" -CA "$CA" -CAkey "$CAKEY" -CAcreateserial -out "${u}.crt" -days 365
  rm -f "${u}.csr"
done

echo ""
echo "Certificates created:"
ls -la user1.key user1.crt user2.key user2.crt 2>/dev/null || true

# Add credentials to kubectl config (like you did)
echo ""
echo "Adding credentials to kubectl config ..."
kubectl config set-credentials user1 \
  --client-certificate=user1.crt \
  --client-key=user1.key

kubectl config set-credentials user2 \
  --client-certificate=user2.crt \
  --client-key=user2.key

# Get cluster name from current context
CLUSTER=$(kubectl config view --minify -o jsonpath='{.clusters[0].name}' 2>/dev/null || echo "default")

echo ""
echo "Creating contexts ..."
kubectl config set-context user1-context \
  --cluster="$CLUSTER" \
  --user=user1

kubectl config set-context user2-context \
  --cluster="$CLUSTER" \
  --user=user2

echo ""
echo "Done! Verify with:"
echo "  kubectl config get-contexts"
echo "  kubectl config get-users"
echo ""
echo "To test permissions:"
echo "  kubectl auth can-i get pods --as=user1 -n ivolve"
echo "  kubectl auth can-i get pods --as=user2 -n ivolve"
