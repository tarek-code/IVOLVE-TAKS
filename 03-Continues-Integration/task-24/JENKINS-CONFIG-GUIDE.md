# Jenkins Multi Branch Pipeline Configuration Guide

This guide shows the exact configuration needed for the Multi Branch Pipeline in Jenkins.

---

## ⚠️ Important: Repository Configuration

**For this lab, we're using the IVOLVE-TAKS repository:**

### Configuration for IVOLVE-TAKS Repository

**Repository:** `https://github.com/tarek-code/IVOLVE-TAKS.git`

**Configuration:**
- **Project Repository**: `https://github.com/tarek-code/IVOLVE-TAKS.git`
- **Script Path**: `03-Continues-Integration/task-24/Jenkinsfile` ⚠️ **Must specify this path!**

**Repository Structure:**
```
IVOLVE-TAKS/
└── 03-Continues-Integration/
    └── task-24/
        ├── Jenkinsfile                    # Pipeline (Script Path points here)
        └── Jenkins_App/                   # Application code
            ├── Dockerfile
            ├── pom.xml
            └── src/
```

**Note:** The Jenkinsfile automatically detects if source code is in `03-Continues-Integration/task-24/Jenkins_App/` or root directory.

---

## 📋 Complete Configuration Steps

### 1. General Section

- **Display Name**: `jenkins-app-multibranch` (or leave default)
- **Description**: (Optional) "Multi-branch pipeline for prod/stag/dev deployments"

### 2. Branch Sources Section

**Click "Add source" → "Git"**

#### Basic Configuration:

- **Project Repository**: 
  - ✅ **Option 1 (Recommended)**: `https://github.com/Ibrahim-Adel15/Jenkins_App.git`
  - ⚠️ **Option 2**: `https://github.com/tarek-code/IVOLVE-TAKS.git` (if using IVOLVE-TAKS)
  
- **Credentials**: 
  - Select credentials if repository is private
  - Or leave "- none -" if repository is public

#### Behaviors (Click "Add"):

1. **Discover branches**:
   - **Strategy**: Select **"All branches"**
   - Click **Add** again

2. **Filter by name (with wildcards)**:
   - **Include**: `prod`, `stag`, `dev`, `main` (or `master`)
   - **Exclude**: Leave empty
   - ⚠️ **Important**: This filters which branches Jenkins will create pipelines for

#### Build Configuration:

- **Mode**: Select **"by Jenkinsfile"**
- **Script Path**: 
  - ✅ **Option 1**: `Jenkinsfile` (if using separate Jenkins_App repo)
  - ⚠️ **Option 2**: `03-Continues-Integration/task-24/Jenkinsfile` (if using IVOLVE-TAKS repo)

### 3. Scan Multibranch Pipeline Triggers

**Recommended Configuration:**

- ✅ **Periodically if not otherwise run**: Check this
  - **Interval**: `H/5 * * * *` (every 5 minutes)
  
**OR**

- ✅ **Poll SCM**: Check this
  - **Schedule**: `H/5 * * * *` (every 5 minutes)

**OR** (Best option)

- Use **GitHub Webhooks** for automatic builds on push (requires webhook configuration in GitHub)

### 4. Orphaned Item Strategy

- ✅ **Discard old items**: Check this
- **Days to keep old items**: `7`
- **Max # of old items to keep**: `10`

### 5. Click "Save"

---

## 🔧 Current Configuration Issues

Based on your screenshot, you need to fix:

### ✅ Repository URL (Correct)

**Current**: `https://github.com/tarek-code/IVOLVE-TAKS.git` ✅ **This is correct!**

**Script Path must be**: `03-Continues-Integration/task-24/Jenkinsfile` ⚠️ **Update this!**

### ❌ Issue 2: Missing Branch Filter

**Current**: Only "Discover branches" is configured

**Fix**: Add branch filter
1. Click **"Add"** under Behaviors
2. Select **"Filter by name (with wildcards)"**
3. **Include**: `prod`, `stag`, `dev`, `main`
4. **Exclude**: Leave empty

### ✅ Correct: Script Path

**Current**: `Jenkinsfile` - This is correct IF using separate Jenkins_App repo

**If using IVOLVE-TAKS repo**: Change to `03-Continues-Integration/task-24/Jenkinsfile`

---

## 📝 Step-by-Step Fix

### Configuration Steps for IVOLVE-TAKS Repository:

1. **Repository URL** (Already correct):
   - **Project Repository**: `https://github.com/tarek-code/IVOLVE-TAKS.git` ✅

2. **Update Script Path** (IMPORTANT):
   - **Script Path**: `03-Continues-Integration/task-24/Jenkinsfile` ⚠️ **Change this!**

3. **Add Branch Filter**:
   - Click **"Add"** under Behaviors
   - Select **"Filter by name (with wildcards)"**
   - **Include**: `prod`, `stag`, `dev`, `main`
   - **Exclude**: (empty)

4. **Click Save**

---

## ✅ Verification Checklist

After configuration, verify:

- [ ] Repository URL points to correct repository
- [ ] Script Path is correct (depends on repository structure)
- [ ] Branch filter is configured (Include: `prod`, `stag`, `dev`, `main`)
- [ ] Build triggers are configured (Poll SCM or webhooks)
- [ ] Orphaned Item Strategy is configured

---

## 🚀 After Configuration

1. **Click "Save"**
2. **Click "Scan Multibranch Pipeline Now"** (on the job page)
3. **Wait for scan to complete**
4. **Verify branches appear**: You should see `prod`, `stag`, `dev`, `main` listed
5. **Run a build** on one of the branches to test

---

## 🐛 Troubleshooting

### Branches Not Appearing After Scan

**Problem**: Scan completes but no branches show up

**Solutions**:
1. Check branch filter - make sure branch names match exactly (case-sensitive)
2. Verify branches exist in repository: `git branch -a`
3. Check repository URL is correct
4. Verify credentials if repository is private
5. Check Jenkins logs: **Manage Jenkins** → **System Log**

### Pipeline Fails with "Jenkinsfile not found"

**Problem**: Build fails saying Jenkinsfile not found

**Solutions**:
1. Check Script Path is correct
2. If using IVOLVE-TAKS repo, Script Path must be: `03-Continues-Integration/task-24/Jenkinsfile`
3. Verify Jenkinsfile exists in the specified path
4. Check branch has Jenkinsfile committed

### Wrong Branches Detected

**Problem**: All branches appear, not just prod/stag/dev

**Solutions**:
1. Add branch filter under Behaviors
2. Include only: `prod`, `stag`, `dev`, `main`
3. Save and rescan

---

## 📚 Related Documentation

- See `README.md` for complete setup instructions
- See `BRANCH-CONTENTS.md` for what should be in each branch
- See `QUICK-START.md` for quick reference
