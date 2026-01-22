#!/bin/bash

# Script to create branches (prod/stag/dev) from main in IVOLVE-TAKS repository
# All branches will have the same content as main (entire IVOLVE-TAKS repository)
# Usage: ./COPY-JENKINS-APP-TO-BRANCHES.sh

set -e

echo "============================================"
echo "Creating branches from main (IVOLVE-TAKS)"
echo "All branches will have same content as main"
echo "============================================"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if we're in IVOLVE-TAKS repository
if [ ! -d ".git" ]; then
    echo -e "${RED}Error: Not in a git repository. Please run this from IVOLVE-TAKS directory.${NC}"
    exit 1
fi

echo -e "${GREEN}Step 1: Ensure we're on main branch${NC}"
git checkout main 2>/dev/null || git checkout master

echo -e "${GREEN}Step 2: Verify repository structure${NC}"
echo "Checking for Jenkins_App..."
if [ -d "03-Continues-Integration/task-24/Jenkins_App" ]; then
    echo -e "${GREEN}✓ Jenkins_App found${NC}"
    ls -la 03-Continues-Integration/task-24/Jenkins_App/ | head -5
else
    echo -e "${YELLOW}⚠ Jenkins_App not found, but continuing...${NC}"
fi

echo ""
echo -e "${GREEN}Step 3: Verify Jenkinsfile exists${NC}"
if [ -f "03-Continues-Integration/task-24/Jenkinsfile" ]; then
    echo -e "${GREEN}✓ Jenkinsfile found${NC}"
else
    echo -e "${RED}Error: Jenkinsfile not found at 03-Continues-Integration/task-24/Jenkinsfile${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}Step 4: Create and push dev branch (copy of main)${NC}"
git checkout -b dev 2>/dev/null || {
    echo "Dev branch already exists, checking it out..."
    git checkout dev
    git merge main || echo "Merge may have conflicts, check manually"
}
git push -u origin dev || echo "Push dev failed or already up to date"

echo ""
echo -e "${GREEN}Step 5: Create and push stag branch (copy of main)${NC}"
git checkout main
git checkout -b stag 2>/dev/null || {
    echo "Stag branch already exists, checking it out..."
    git checkout stag
    git merge main || echo "Merge may have conflicts, check manually"
}
git push -u origin stag || echo "Push stag failed or already up to date"

echo ""
echo -e "${GREEN}Step 6: Create and push prod branch (copy of main)${NC}"
git checkout main
git checkout -b prod 2>/dev/null || {
    echo "Prod branch already exists, checking it out..."
    git checkout prod
    git merge main || echo "Merge may have conflicts, check manually"
}
git push -u origin prod || echo "Push prod failed or already up to date"

echo ""
echo -e "${GREEN}============================================"
echo "Setup complete!"
echo "============================================${NC}"
echo ""
echo "Branches created (all have same content as main):"
git branch -a | grep -E "prod|stag|dev|main|master"
echo ""
echo "Repository structure (same in all branches):"
echo "  IVOLVE-TAKS/"
echo "    └── 03-Continues-Integration/"
echo "        └── task-24/"
echo "            ├── Jenkinsfile"
echo "            └── Jenkins_App/"
echo ""
echo "Next steps:"
echo "1. Verify branches on GitHub: https://github.com/tarek-code/IVOLVE-TAKS"
echo "2. Configure Jenkins Multi Branch Pipeline:"
echo "   - Repository: https://github.com/tarek-code/IVOLVE-TAKS.git"
echo "   - Script Path: 03-Continues-Integration/task-24/Jenkinsfile"
echo "   - Branch filter: Include prod, stag, dev, main"
echo "3. Create Kubernetes namespaces:"
echo "   kubectl apply -f 03-Continues-Integration/task-24/namespaces.yaml"
echo ""
