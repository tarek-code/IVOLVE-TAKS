#!/bin/bash

# Script to set up Git repository with multiple branches for Lab 24
# Usage: ./setup-branches.sh

set -e

echo "============================================"
echo "Lab 24: Setting up Git branches"
echo "============================================"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if we're in a git repository
if [ ! -d .git ]; then
    echo -e "${YELLOW}Warning: Not in a git repository. Initializing...${NC}"
    git init
    git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git
    echo -e "${YELLOW}Please update the remote URL above with your repository${NC}"
fi

# Ensure we're on main/master branch
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "main" ] && [ "$CURRENT_BRANCH" != "master" ]; then
    echo -e "${YELLOW}Switching to main branch...${NC}"
    git checkout main 2>/dev/null || git checkout master 2>/dev/null || {
        echo "Error: Could not find main or master branch"
        exit 1
    }
fi

# Ensure Dockerfile exists
if [ ! -f Dockerfile ]; then
    echo -e "${YELLOW}Dockerfile not found. Please ensure Dockerfile exists in repository root.${NC}"
    exit 1
fi

echo -e "${GREEN}Creating branches...${NC}"

# Create dev branch
echo "Creating 'dev' branch..."
git checkout -b dev 2>/dev/null || git checkout dev
git push -u origin dev || echo "Note: Push dev branch manually if needed"

# Create stag branch
echo "Creating 'stag' branch..."
git checkout main 2>/dev/null || git checkout master
git checkout -b stag 2>/dev/null || git checkout stag
git push -u origin stag || echo "Note: Push stag branch manually if needed"

# Create prod branch
echo "Creating 'prod' branch..."
git checkout main 2>/dev/null || git checkout master
git checkout -b prod 2>/dev/null || git checkout prod
git push -u origin prod || echo "Note: Push prod branch manually if needed"

# Return to main/master
git checkout main 2>/dev/null || git checkout master

echo ""
echo -e "${GREEN}============================================"
echo "Branches created successfully!"
echo "============================================${NC}"
echo ""
echo "Branches:"
git branch -a
echo ""
echo "Next steps:"
echo "1. Verify branches on GitHub/GitLab"
echo "2. Create Kubernetes namespaces: kubectl apply -f namespaces.yaml"
echo "3. Create Multi Branch Pipeline in Jenkins"
echo "4. Configure branch sources in Jenkins"
echo ""
