# Simple Branch Setup - All Branches Same as Main

This guide shows how to create branches (prod/stag/dev) that have the **same content as main** (entire IVOLVE-TAKS repository).

---

## 🎯 Goal

Create 3 branches (prod/stag/dev) from main, where each branch contains the **entire IVOLVE-TAKS repository** (same as main).

---

## 📋 Quick Setup Steps

### Step 1: Clone IVOLVE-TAKS Repository

```bash
# Clone your repository
git clone https://github.com/tarek-code/IVOLVE-TAKS.git
cd IVOLVE-TAKS

# Ensure you're on main branch
git checkout main
```

### Step 2: Verify Jenkins_App Content Exists

```bash
# Check that Jenkins_App exists
ls -la 03-Continues-Integration/task-24/Jenkins_App/
# Should see: Dockerfile, pom.xml, src/

# Check Jenkinsfile exists
ls -la 03-Continues-Integration/task-24/Jenkinsfile
```

### Step 3: Create Branches from Main

Since you want all branches to have the same content as main, just create branches from main:

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

**That's it!** All branches now have the same content as main (entire IVOLVE-TAKS repository).

---

## 📁 Repository Structure (All Branches)

Each branch (main/prod/stag/dev) will have:

```
IVOLVE-TAKS/
├── 00-Build-Tools-Overview/
├── 01-Containerization-with-docker/
├── 02-Orchestration/
├── 03-Continues-Integration/
│   ├── task-22/
│   ├── task-23/
│   └── task-24/
│       ├── Jenkinsfile                    ← Jenkins uses this
│       ├── namespaces.yaml
│       └── Jenkins_App/                   ← Application code here
│           ├── Dockerfile
│           ├── pom.xml
│           └── src/
└── ... (all other folders)
```

**All branches are identical to main!**

---

## 🔧 Jenkins Configuration

### Step 4: Configure Jenkins Multi Branch Pipeline

1. **Repository URL**: `https://github.com/tarek-code/IVOLVE-TAKS.git` ✅

2. **Script Path**: `03-Continues-Integration/task-24/Jenkinsfile` ⚠️ **IMPORTANT!**

3. **Branch Filter**:
   - Click **"Add"** under Behaviors
   - Select **"Filter by name (with wildcards)"**
   - **Include**: `prod`, `stag`, `dev`, `main`
   - **Exclude**: (empty)

4. **Click Save**

---

## ✅ Verification

After creating branches:

```bash
# Verify branches exist
git branch -a

# Check each branch has the same content
git checkout dev
ls -la 03-Continues-Integration/task-24/Jenkins_App/

git checkout stag
ls -la 03-Continues-Integration/task-24/Jenkins_App/

git checkout prod
ls -la 03-Continues-Integration/task-24/Jenkins_App/
```

All should show the same files!

---

## 🎯 How It Works

1. **Main branch** = Full IVOLVE-TAKS repository
2. **Dev branch** = Copy of main (full IVOLVE-TAKS)
3. **Stag branch** = Copy of main (full IVOLVE-TAKS)
4. **Prod branch** = Copy of main (full IVOLVE-TAKS)

**Jenkinsfile automatically finds source code in:**
- `03-Continues-Integration/task-24/Jenkins_App/` (if in IVOLVE-TAKS repo)
- Falls back to `Jenkins_App/` or root if not found

---

## 🚀 Next Steps

1. **Create namespaces**: `kubectl apply -f 03-Continues-Integration/task-24/namespaces.yaml`
2. **Configure Jenkins**: Use repository `https://github.com/tarek-code/IVOLVE-TAKS.git`
3. **Set Script Path**: `03-Continues-Integration/task-24/Jenkinsfile`
4. **Scan branches**: Click "Scan Multibranch Pipeline Now"
5. **Run pipeline**: Build on each branch

---

**Simple and clean!** All branches have the same content as main. ✅
