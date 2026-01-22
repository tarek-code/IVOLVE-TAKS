# What to Push to Each Branch

## ✅ Correct: Push Only Jenkins_App Project

Each branch (prod/stag/dev) should contain **only the application code**, not the entire IVOLVE-TAKS repository.

---

## 📁 Branch Structure

Each branch should have this structure:

```
Jenkins_App/                    # Repository root
├── Dockerfile                  # Required: Docker image definition
├── Jenkinsfile                 # Required: Pipeline definition
├── pom.xml                     # Required: Maven build file (or package.json for Node.js)
├── src/                        # Required: Application source code
│   └── main/
│       └── java/
│           └── com/
│               └── example/
│                   └── demo/
│                       └── DemoApplication.java
└── .gitignore                  # Optional: Git ignore file
```

---

## ❌ Do NOT Push

- ❌ Entire `IVOLVE-TAKS` repository
- ❌ `task-22/`, `task-23/`, `task-24/` folders
- ❌ Other lab files
- ❌ Documentation files (README.md, etc.) - unless specific to the app

---

## 🎯 Why Only Jenkins_App?

1. **Pipeline Expectation:**
   - Jenkinsfile runs `buildApp('.')` which expects `pom.xml` in root
   - Pipeline runs `buildImage()` which expects `Dockerfile` in root
   - Pipeline runs `runUnitTest('.')` which expects source code in `src/`

2. **Repository Purpose:**
   - The repository `https://github.com/Ibrahim-Adel15/Jenkins_App.git` is specifically for the application
   - It's a separate repository from your lab repository (IVOLVE-TAKS)

3. **Best Practice:**
   - Application code should be in its own repository
   - Lab files and documentation stay in IVOLVE-TAKS
   - Clean separation of concerns

---

## 📝 Setup Instructions

### Option 1: Use Existing Jenkins_App Repository

If you already have `https://github.com/Ibrahim-Adel15/Jenkins_App.git`:

```bash
# Clone the repository
git clone https://github.com/Ibrahim-Adel15/Jenkins_App.git
cd Jenkins_App

# Ensure Dockerfile exists
ls -la Dockerfile

# Copy Jenkinsfile from task-24
cp ../IVOLVE-TAKS/03-Continues-Integration/task-24/Jenkinsfile .

# Add and commit
git add Jenkinsfile
git commit -m "Add multi-branch Jenkinsfile"
git push origin main

# Create branches
git checkout -b dev
git push -u origin dev

git checkout main
git checkout -b stag
git push -u origin stag

git checkout main
git checkout -b prod
git push -u origin prod
```

### Option 2: Create New Repository

If you want to create a new repository:

```bash
# Create new directory
mkdir jenkins-app-repo
cd jenkins-app-repo

# Copy application files from task-24/Jenkins_App
cp -r ../IVOLVE-TAKS/03-Continues-Integration/task-24/Jenkins_App/* .

# Copy Jenkinsfile
cp ../IVOLVE-TAKS/03-Continues-Integration/task-24/Jenkinsfile .

# Initialize git
git init
git add .
git commit -m "Initial commit: Jenkins App with multi-branch pipeline"

# Add remote (replace with your repository URL)
git remote add origin https://github.com/YOUR_USERNAME/jenkins-app.git
git push -u origin main

# Create branches
git checkout -b dev
git push -u origin dev

git checkout main
git checkout -b stag
git push -u origin stag

git checkout main
git checkout -b prod
git push -u origin prod
```

---

## ✅ Verification

After pushing, verify each branch contains:

```bash
# Checkout each branch and verify
git checkout dev
ls -la
# Should see: Dockerfile, Jenkinsfile, pom.xml, src/

git checkout stag
ls -la
# Should see: Dockerfile, Jenkinsfile, pom.xml, src/

git checkout prod
ls -la
# Should see: Dockerfile, Jenkinsfile, pom.xml, src/
```

---

## 🔍 What Jenkins Expects

When Jenkins checks out a branch, it expects:

1. **Dockerfile** - To build the Docker image
2. **Jenkinsfile** - To run the pipeline
3. **pom.xml** (or package.json) - To build the application
4. **src/** - Application source code
5. **target/** - Generated after build (not in git, created during build)

---

## 📊 Summary

| Item | Push to Branch? | Why |
|------|----------------|-----|
| Dockerfile | ✅ Yes | Needed to build image |
| Jenkinsfile | ✅ Yes | Pipeline definition |
| pom.xml | ✅ Yes | Build configuration |
| src/ | ✅ Yes | Application code |
| task-24/ folder | ❌ No | Lab documentation |
| IVOLVE-TAKS/ | ❌ No | Entire lab repository |
| README.md | ⚠️ Optional | Only if app-specific |

---

**Remember:** Each branch should be a **standalone application repository**, not a lab repository!
