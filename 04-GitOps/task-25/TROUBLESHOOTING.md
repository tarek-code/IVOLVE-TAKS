# Troubleshooting: ArgoCD Path Not Found

## Error: `app path does not exist`

**Error Message:**
```
Unable to create application: application spec for jenkins-app-gitops is invalid: 
InvalidSpecError: Unable to generate manifests in 04-GitOps/task-25: 
rpc error: code = Unknown desc = 04-GitOps/task-25: app path does not exist
```

**Cause:** The path `04-GitOps/task-25` doesn't exist in your GitHub repository. The files are only on your local machine and haven't been pushed to GitHub.

---

## Solution: Commit and Push Files to GitHub

### Step 1: Verify Files Exist Locally

```bash
# Navigate to your repository
cd /path/to/IVOLVE-TAKS

# Check if files exist
ls -la 04-GitOps/task-25/

# Should see:
# - deployment.yaml
# - Jenkinsfile
# - argocd-application.yaml
# - README.md
# etc.
```

### Step 2: Check Git Status

```bash
# Check what files are not committed
git status

# You should see 04-GitOps/task-25/ listed as untracked or modified
```

### Step 3: Add Files to Git

```bash
# Add all files in task-25 directory
git add 04-GitOps/task-25/

# Or add specific files
git add 04-GitOps/task-25/deployment.yaml
git add 04-GitOps/task-25/Jenkinsfile
git add 04-GitOps/task-25/argocd-application.yaml
git add 04-GitOps/task-25/README.md
```

### Step 4: Commit Files

```bash
git commit -m "Add Lab 25: GitOps workflow with ArgoCD"
```

### Step 5: Push to GitHub

```bash
# Push to main branch
git push origin main

# Or if you're on a different branch
git push origin <your-branch-name>
```

### Step 6: Verify on GitHub

1. Go to: https://github.com/tarek-code/IVOLVE-TAKS
2. Navigate to: `04-GitOps/task-25/`
3. Verify `deployment.yaml` exists

### Step 7: Retry ArgoCD Application

1. Go to ArgoCD UI
2. Try creating the application again
3. Or if already created, click **"Refresh"** or **"Hard Refresh"**

---

## Alternative: Verify Path in ArgoCD

### Check Repository Connection

1. **ArgoCD UI** → **Settings** → **Repositories**
2. Click on your repository
3. Click **"Test Connection"**
4. Should show ✅ **"Successful"**

### Verify Path Exists

1. **ArgoCD UI** → **Settings** → **Repositories**
2. Click on your repository
3. Click **"App Details"** or **"..."** menu
4. You can browse the repository structure

### Manual Path Check

In ArgoCD UI, when creating application:
- Try different paths:
  - `04-GitOps/task-25` (if folder exists)
  - `04-GitOps/task-25/` (with trailing slash)
  - Just `task-25` (if 04-GitOps is root)

---

## Quick Verification Commands

### Check if Path Exists in Repository

```bash
# Clone fresh copy to verify
cd /tmp
git clone https://github.com/tarek-code/IVOLVE-TAKS.git test-repo
cd test-repo
ls -la 04-GitOps/task-25/

# If this works, the path exists in GitHub
# If it fails, files aren't pushed yet
```

### Check Current Branch

```bash
# Make sure you're on the right branch
git branch

# Should show: * main (or your branch)
```

### Check Remote URL

```bash
# Verify remote is correct
git remote -v

# Should show:
# origin  https://github.com/tarek-code/IVOLVE-TAKS.git (fetch)
# origin  https://github.com/tarek-code/IVOLVE-TAKS.git (push)
```

---

## Common Issues

### Issue 1: Files in Wrong Location

**Problem:** Files are in `03-Continues-Integration/task-25` instead of `04-GitOps/task-25`

**Solution:**
```bash
# Move files to correct location
mv 03-Continues-Integration/task-25 04-GitOps/task-25
git add 04-GitOps/task-25/
git commit -m "Move task-25 to 04-GitOps directory"
git push origin main
```

### Issue 2: Wrong Branch

**Problem:** Files pushed to different branch than ArgoCD is watching

**Solution:**
1. Check ArgoCD Application → Source → Revision
2. Make sure it matches the branch you pushed to
3. Or push to the correct branch:
   ```bash
   git checkout main
   git add 04-GitOps/task-25/
   git commit -m "Add task-25 files"
   git push origin main
   ```

### Issue 3: Repository Not Connected

**Problem:** ArgoCD can't access the repository

**Solution:**
1. **ArgoCD UI** → **Settings** → **Repositories**
2. Verify repository is connected (green checkmark)
3. Test connection
4. Check credentials (Personal Access Token)

### Issue 4: Path Case Sensitivity

**Problem:** Path case doesn't match

**Solution:**
- Use exact case: `04-GitOps/task-25` (capital G, capital O)
- Not: `04-gitops/task-25` or `04-GITOPS/task-25`

---

## Step-by-Step Fix

**Complete fix in 5 steps:**

```bash
# 1. Navigate to repository
cd /path/to/IVOLVE-TAKS

# 2. Check current status
git status

# 3. Add files
git add 04-GitOps/task-25/

# 4. Commit
git commit -m "Add Lab 25: GitOps workflow files"

# 5. Push
git push origin main
```

**Then in ArgoCD:**
1. Refresh the repository (Settings → Repositories → Refresh)
2. Try creating application again
3. Or click "Hard Refresh" on existing application

---

## Verify Fix

After pushing, verify:

```bash
# Check on GitHub web interface
# Go to: https://github.com/tarek-code/IVOLVE-TAKS/tree/main/04-GitOps/task-25

# Or via command line
git ls-remote --heads origin main
git ls-tree -r main --name-only | grep "04-GitOps/task-25"
```

If you see `deployment.yaml` listed, the path exists!

---

## Still Not Working?

1. **Check ArgoCD logs:**
   ```bash
   kubectl logs -n argocd deployment/argocd-repo-server | tail -50
   ```

2. **Check repository connection:**
   - ArgoCD UI → Settings → Repositories → Test Connection

3. **Try different path:**
   - If `04-GitOps/task-25` doesn't work, try just the filename:
     - Path: `04-GitOps/task-25/deployment.yaml`
     - But this requires different configuration

4. **Verify branch name:**
   - Make sure ArgoCD is watching the correct branch
   - Check: Application → Source → Revision
