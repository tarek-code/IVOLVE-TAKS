# 🎓 START HERE - Complete Learning Guide for Lab 23

Welcome! This guide will teach you everything about Jenkins agents and shared libraries step by step.

## 📖 Reading Order (Follow This!)

### 1️⃣ First: Read the Tutorial
**File:** [TUTORIAL.md](TUTORIAL.md)

**Time:** 15-20 minutes

**What you'll learn:**
- ✅ What Jenkins agents are (workers that do the build)
- ✅ What shared libraries are (reusable code)
- ✅ Why we use them (better organization, reusability)
- ✅ How they work together
- ✅ Where everything lives (filesystem, Git, Jenkins)

**Key concepts:**
- Master = Coordinator (web UI, manages jobs)
- Agent = Worker (executes builds)
- Shared Library = Reusable functions

### 2️⃣ Second: Try the Simple Example
**File:** [SIMPLE-EXAMPLE.md](SIMPLE-EXAMPLE.md)

**Time:** 10-15 minutes

**What you'll do:**
- Create a simple shared library function
- Copy it to Jenkins
- Configure it in Jenkins UI
- Test it in a pipeline
- See the complete flow in action

**This helps you understand:**
- How to write shared library functions
- How Jenkins finds and loads libraries
- How pipelines use shared library functions

### 3️⃣ Third: Read the Main README
**File:** [README.md](README.md)

**Time:** 20-30 minutes

**What you'll learn:**
- Complete setup instructions for Lab 23
- How to configure Kubernetes Plugin
- How to set up agents
- All 7 shared library functions explained
- Troubleshooting guide

### 4️⃣ Fourth: Use Quick Reference
**File:** [QUICK-REFERENCE.md](QUICK-REFERENCE.md)

**When to use:** While working on the lab

**What it contains:**
- Quick lookup table
- Common commands
- Troubleshooting quick fixes
- Checklist

## 🎯 Learning Objectives

By the end, you should understand:

1. **Jenkins Agents:**
   - What they are (separate workers)
   - Why we use them (offload master, parallel builds)
   - How to set them up (Kubernetes Plugin or static pods)
   - How pipelines use them (`agent { label 'name' }`)

2. **Shared Libraries:**
   - What they are (reusable Groovy code)
   - Why we use them (no code duplication)
   - How to write them (files in `vars/` folder)
   - Where to put them (Git or filesystem)
   - How Jenkins finds them (configured in UI)

3. **How They Work Together:**
   - Pipeline loads shared library (`@Library('name') _`)
   - Pipeline runs on agent (`agent { label 'name' }`)
   - Agent executes shared library functions
   - Results sent back to master

## 🗺️ Visual Learning Path

```
┌─────────────────────────────────────────────────┐
│  START: You don't know about agents/libraries    │
└────────────────────┬────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────┐
│  STEP 1: Read TUTORIAL.md                       │
│  Learn: What are agents? What are libraries?    │
└────────────────────┬────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────┐
│  STEP 2: Try SIMPLE-EXAMPLE.md                  │
│  Practice: Create simple function, test it      │
└────────────────────┬────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────┐
│  STEP 3: Read README.md                          │
│  Build: Complete Lab 23 setup                   │
└────────────────────┬────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────┐
│  STEP 4: Use QUICK-REFERENCE.md                  │
│  Reference: Quick lookup while working          │
└────────────────────┬────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────┐
│  DONE: You understand and can use both!         │
└─────────────────────────────────────────────────┘
```

## 📝 Key Questions Answered

### Q: What is a Jenkins agent/slave?
**A:** A separate machine/container that executes build work. The master coordinates, agents do the work.

### Q: Why use agents?
**A:** 
- Master stays free (just coordinates)
- Multiple builds can run in parallel
- Each agent has dedicated resources
- Can scale by adding more agents

### Q: What is a shared library?
**A:** Reusable Groovy code stored in Git or filesystem. Functions you can use in multiple pipelines.

### Q: Why use shared libraries?
**A:**
- Write code once, use everywhere
- Update in one place, all pipelines benefit
- Consistent behavior
- Easy to maintain

### Q: Where do I put the shared library?
**A:** 
- **Option 1:** Git repository (recommended)
- **Option 2:** Jenkins filesystem: `/var/jenkins_home/shared-library`

### Q: How does Jenkins find the shared library?
**A:** 
1. You configure it in Jenkins UI (Manage Jenkins → Configure System)
2. Jenkins downloads/clones it (if Git) or reads it (if filesystem)
3. When pipeline uses `@Library('name') _`, Jenkins loads it

### Q: Where does the pipeline run - master or agent?
**A:** Depends on `agent` configuration:
- `agent any` = Master or any agent
- `agent { label 'name' }` = Specific agent only

### Q: How do shared library functions run on agents?
**A:** 
1. Pipeline runs on agent (because of `agent { label 'name' }`)
2. Shared library functions execute on that same agent
3. Everything happens on the agent, not master

## 🛠️ Setup Checklist

Before starting Lab 23, make sure you have:

- [ ] Jenkins running (from Lab 22)
- [ ] Kubernetes cluster accessible
- [ ] Docker Hub account
- [ ] kubectl configured
- [ ] Read TUTORIAL.md
- [ ] Tried SIMPLE-EXAMPLE.md
- [ ] Understand the concepts

## 🚀 Ready to Start?

1. **Read:** [TUTORIAL.md](TUTORIAL.md) - Learn the concepts
2. **Practice:** [SIMPLE-EXAMPLE.md](SIMPLE-EXAMPLE.md) - Try it yourself
3. **Build:** [README.md](README.md) - Complete Lab 23
4. **Reference:** [QUICK-REFERENCE.md](QUICK-REFERENCE.md) - Quick lookup

## 💡 Pro Tips

1. **Start simple:** Get one shared library function working first
2. **Test incrementally:** Test each function before moving to next
3. **Check logs:** If something fails, check Jenkins logs and agent logs
4. **Verify agent:** Make sure agent is online before running pipeline
5. **Use labels:** Always use labels to control which agent runs which pipeline

## 🆘 Need Help?

- **Concepts unclear?** → Re-read [TUTORIAL.md](TUTORIAL.md)
- **Setup issues?** → Check [README.md](README.md) troubleshooting section
- **Quick question?** → Check [QUICK-REFERENCE.md](QUICK-REFERENCE.md)
- **Want to practice?** → Try [SIMPLE-EXAMPLE.md](SIMPLE-EXAMPLE.md)

Good luck! 🎉
