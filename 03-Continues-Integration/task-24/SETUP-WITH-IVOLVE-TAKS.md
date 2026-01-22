# Setup Lab 24 Using IVOLVE-TAKS Repository

This guide shows how to set up Lab 24 using the **IVOLVE-TAKS repository** with Jenkins_App content in each branch.

---

## 🎯 Overview

**Goal:** Create branches (prod/stag/dev) from main, where each branch contains the **entire IVOLVE-TAKS repository** (same as main).

**Repository:** `https://github.com/tarek-code/IVOLVE-TAKS.git`

**Jenkinsfile Path:** `03-Continues-Integration/task-24/Jenkinsfile`

**Important:** All branches (prod/stag/dev/main) will have the **same content** - the entire IVOLVE-TAKS repository structure.

---

## 📋 Step-by-Step Setup

### Step 1: Clone IVOLVE-TAKS Repository

```bash
# Clone your IVOLVE-TAKS repository
git clone https://github.com/tarek-code/IVOLVE-TAKS.git
cd IVOLVE-TAKS
```

### Step 2: Verify Content Exists

```bash
# Ensure you're on main branch
git checkout main

# Verify Jenkins_App exists (should already be there)
ls -la 03-Continues-Integration/task-24/Jenkins_App/
# Should see: Dockerfile, pom.xml, src/

# Verify Jenkinsfile exists
ls -la 03-Continues-Integration/task-24/Jenkinsfile
```

**Note:** If Jenkins_App doesn't exist, you may need to copy it from the cloned source, but it should already be in your repository.

### Step 3: Create Branches from Main

Since you want all branches to have the same content as main (entire IVOLVE-TAKS), just create branches from main:

```bash
# Create dev branch (copies everything from main)
git checkout -b dev
git push -u origin dev

# Create stag branch (copies everything from main)
git checkout main
git checkout -b stag
git push -u origin stag

# Create prod branch (copies everything from main)
git checkout main
git checkout -b prod
git push -u origin prod

# Verify all branches
git branch -a
```

**Result:** All branches (prod/stag/dev/main) now have the **same content** - the entire IVOLVE-TAKS repository!

### Step 4: Verify Branches on GitHub

1. Go to: `https://github.com/tarek-code/IVOLVE-TAKS`
2. Click branch dropdown
3. Verify you see: `main`, `dev`, `stag`, `prod`
4. Switch to each branch and verify `03-Continues-Integration/task-24/Jenkins_App/` exists

---

## 🔧 Jenkins Configuration

### Step 5: Configure Multi Branch Pipeline in Jenkins

1. **Go to Jenkins Dashboard** → **New Item**

2. **Create Multi Branch Pipeline:**
   - **Name**: `jenkins-app-multibranch`
   - **Type**: **Multibranch Pipeline**
   - Click **OK**

3. **Configure Branch Sources:**
   - Click **Add source** → **Git**
   - **Project Repository**: `https://github.com/tarek-code/IVOLVE-TAKS.git` ✅
   - **Credentials**: Add if repository is private
   
   **Behaviors:**
   - Click **Add** → **Discover branches**
     - **Strategy**: **All branches**
   - Click **Add** → **Filter by name (with wildcards)**
     - **Include**: `prod`, `stag`, `dev`, `main`
     - **Exclude**: (leave empty)
   
   **Build Configuration:**
   - **Mode**: **by Jenkinsfile**
   - **Script Path**: `03-Continues-Integration/task-24/Jenkinsfile` ⚠️ **IMPORTANT!**

4. **Configure Build Triggers:**
   - ✅ **Poll SCM**: Check
   - **Schedule**: `H/5 * * * *` (every 5 minutes)

5. **Orphaned Item Strategy:**
   - ✅ **Discard old items**: Check
   - **Days to keep**: `7`
   - **Max # of old items**: `10`

6. **Click Save**

---

## 📁 Repository Structure

After setup, your IVOLVE-TAKS repository structure should be:

```
IVOLVE-TAKS/
├── 03-Continues-Integration/
│   └── task-24/
│       ├── Jenkinsfile                    # Pipeline definition
│       └── Jenkins_App/                   # Application code
│           ├── Dockerfile
│           ├── pom.xml
│           └── src/
│               └── main/
│                   └── java/
│                       └── com/
│                           └── example/
│                               └── demo/
│                                   └── DemoApplication.java
├── task-22/
├── task-23/
└── ... (other folders)
```

**Each branch (prod/stag/dev/main) has this structure - they're all identical to main!**

---

## 🔍 Important Configuration Details

### Jenkinsfile Location

Since Jenkins_App is in a subdirectory, the Jenkinsfile needs to:

1. **Be in the correct path**: `03-Continues-Integration/task-24/Jenkinsfile`
2. **Work with subdirectory**: The Jenkinsfile should handle the fact that source code is in `Jenkins_App/` subdirectory

### Update Jenkinsfile for Subdirectory

The current Jenkinsfile assumes files are in root. We need to update it to work with the subdirectory structure.

---

## ✅ Verification Checklist

- [ ] IVOLVE-TAKS repository cloned
- [ ] Verified Jenkins_App exists in `03-Continues-Integration/task-24/Jenkins_App/`
- [ ] Verified Jenkinsfile exists at `03-Continues-Integration/task-24/Jenkinsfile`
- [ ] Branches created from main: prod, stag, dev
- [ ] All branches pushed to GitHub
- [ ] Verified all branches have same content as main
- [ ] Jenkins Multi Branch Pipeline configured
- [ ] Repository URL: `https://github.com/tarek-code/IVOLVE-TAKS.git`
- [ ] Script Path: `03-Continues-Integration/task-24/Jenkinsfile`
- [ ] Branch filter configured (Include: prod, stag, dev, main)
- [ ] Kubernetes namespaces created (prod, stag, dev)

---

## 🚀 Next Steps

1. **Scan repository in Jenkins**: Click "Scan Multibranch Pipeline Now"
2. **Verify branches detected**: Should see prod, stag, dev, main
3. **Run pipeline**: Click on a branch → Build Now
4. **Verify deployment**: Check pods in corresponding namespace

---

## 🐛 Troubleshooting

### Jenkinsfile Not Found

**Problem**: Build fails with "Jenkinsfile not found"

**Solution**: 
- Verify Script Path is: `03-Continues-Integration/task-24/Jenkinsfile`
- Check branch has Jenkinsfile in that path
- Verify path is correct (case-sensitive)

### Source Code Not Found

**Problem**: Build fails because pom.xml or src/ not found

**Solution**:
- Update Jenkinsfile to use correct workDir
- Source code is in: `03-Continues-Integration/task-24/Jenkins_App/`
- Update `buildApp()`, `runUnitTest()`, etc. to use correct path

---

**Ready to proceed!** Follow these steps to set up Lab 24 with IVOLVE-TAKS repository.
