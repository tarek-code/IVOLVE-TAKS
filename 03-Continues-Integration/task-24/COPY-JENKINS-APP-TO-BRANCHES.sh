#!/bin/bash

# Script to copy Jenkins_App content to IVOLVE-TAKS repository branches
# Usage: ./COPY-JENKINS-APP-TO-BRANCHES.sh

set -e

echo "============================================"
echo "Copying Jenkins_App to IVOLVE-TAKS branches"
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

# Check if Jenkins_App source exists
if [ ! -d "03-Continues-Integration/task-24/Jenkins_App" ]; then
    echo -e "${YELLOW}Warning: 03-Continues-Integration/task-24/Jenkins_App not found.${NC}"
    echo "Please ensure you're in the IVOLVE-TAKS repository root."
    exit 1
fi

# Ensure Jenkinsfile exists
if [ ! -f "03-Continues-Integration/task-24/Jenkinsfile" ]; then
    echo -e "${RED}Error: Jenkinsfile not found at 03-Continues-Integration/task-24/Jenkinsfile${NC}"
    exit 1
fi

echo -e "${GREEN}Step 1: Ensure we're on main branch${NC}"
git checkout main 2>/dev/null || git checkout master

echo -e "${GREEN}Step 2: Verify Jenkins_App content exists${NC}"
ls -la 03-Continues-Integration/task-24/Jenkins_App/

echo -e "${GREEN}Step 3: Copy Jenkinsfile to Jenkins_App directory${NC}"
cp 03-Continues-Integration/task-24/Jenkinsfile 03-Continues-Integration/task-24/Jenkins_App/ 2>/dev/null || echo "Jenkinsfile already in place or copy failed"

echo -e "${GREEN}Step 4: Commit to main branch${NC}"
git add 03-Continues-Integration/task-24/Jenkins_App/
git add 03-Continues-Integration/task-24/Jenkinsfile
git commit -m "Add Jenkins_App content and Jenkinsfile for Lab 24" || echo "No changes to commit"
git push origin main || echo "Push to main failed or already up to date"

echo -e "${GREEN}Step 5: Create and push dev branch${NC}"
git checkout -b dev 2>/dev/null || git checkout dev
git push -u origin dev || echo "Push dev failed or already exists"

echo -e "${GREEN}Step 6: Create and push stag branch${NC}"
git checkout main
git checkout -b stag 2>/dev/null || git checkout stag
git push -u origin stag || echo "Push stag failed or already exists"

echo -e "${GREEN}Step 7: Create and push prod branch${NC}"
git checkout main
git checkout -b prod 2>/dev/null || git checkout prod
git push -u origin prod || echo "Push prod failed or already exists"

echo ""
echo -e "${GREEN}============================================"
echo "Setup complete!"
echo "============================================${NC}"
echo ""
echo "Branches created:"
git branch -a | grep -E "prod|stag|dev|main|master"
echo ""
echo "Next steps:"
echo "1. Verify branches on GitHub: https://github.com/tarek-code/IVOLVE-TAKS"
echo "2. Configure Jenkins Multi Branch Pipeline:"
echo "   - Repository: https://github.com/tarek-code/IVOLVE-TAKS.git"
echo "   - Script Path: 03-Continues-Integration/task-24/Jenkinsfile"
echo "   - Branch filter: Include prod, stag, dev, main"
echo "3. Create Kubernetes namespaces: kubectl apply -f 03-Continues-Integration/task-24/namespaces.yaml"
echo ""
