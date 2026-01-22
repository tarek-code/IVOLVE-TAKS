# Setup Lab 24 Using IVOLVE-TAKS Repository

This guide shows how to set up Lab 24 using the **IVOLVE-TAKS repository** with Jenkins_App content in each branch.

---

## 🎯 Overview

**Goal:** Add Jenkins_App content to prod/stag/dev branches in IVOLVE-TAKS repository, then configure Jenkins to use it.

**Repository:** `https://github.com/tarek-code/IVOLVE-TAKS.git`

**Jenkinsfile Path:** `03-Continues-Integration/task-24/Jenkinsfile`

---

## 📋 Step-by-Step Setup

### Step 1: Clone IVOLVE-TAKS Repository

```bash
# Clone your IVOLVE-TAKS repository
git clone https://github.com/tarek-code/IVOLVE-TAKS.git
cd IVOLVE-TAKS
```

### Step 2: Copy Jenkins_App Content to Repository

```bash
# Ensure you're on main branch
git checkout main

# Copy Jenkins_App files to a location in the repo
# Option A: Copy to root (if you want it at root level)
cp -r 03-Continues-Integration/task-24/Jenkins_App/* .

# Option B: Keep it in task-24 folder (recommended - keeps structure)
# Files are already in: 03-Continues-Integration/task-24/Jenkins_App/
# Just need to copy Jenkinsfile to the right location
cp 03-Continues-Integration/task-24/Jenkinsfile 03-Continues-Integration/task-24/Jenkins_App/

# Verify files exist
ls -la 03-Continues-Integration/task-24/Jenkins_App/
# Should see: Dockerfile, pom.xml, src/, Jenkinsfile
```

### Step 3: Commit Jenkins_App Content to Main Branch

```bash
# Add all Jenkins_App files
git add 03-Continues-Integration/task-24/Jenkins_App/
git add 03-Continues-Integration/task-24/Jenkinsfile

# Commit
git commit -m "Add Jenkins_App content and Jenkinsfile for Lab 24"

# Push to main
git push origin main
```

### Step 4: Create and Push Branches (prod/stag/dev)

```bash
# Create dev branch from main
git checkout -b dev
git push -u origin dev

# Create stag branch from main
git checkout main
git checkout -b stag
git push -u origin stag

# Create prod branch from main
git checkout main
git checkout -b prod
git push -u origin prod

# Verify all branches
git branch -a
```

### Step 5: Verify Branches on GitHub

1. Go to: `https://github.com/tarek-code/IVOLVE-TAKS`
2. Click branch dropdown
3. Verify you see: `main`, `dev`, `stag`, `prod`
4. Switch to each branch and verify `03-Continues-Integration/task-24/Jenkins_App/` exists

---

## 🔧 Jenkins Configuration

### Step 6: Configure Multi Branch Pipeline in Jenkins

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

**Each branch (prod/stag/dev/main) should have this structure.**

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
- [ ] Jenkins_App content copied to `03-Continues-Integration/task-24/Jenkins_App/`
- [ ] Jenkinsfile copied to `03-Continues-Integration/task-24/Jenkinsfile`
- [ ] All files committed to main branch
- [ ] Branches created: prod, stag, dev
- [ ] Branches pushed to GitHub
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
