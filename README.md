# IVOLVE DevOps Training Program - Complete Task Repository

Welcome to the **IVOLVE Cloud DevOps Accelerator** hands-on training repository! This repository contains all 30 practical tasks covering the complete DevOps lifecycle, from build tools to infrastructure automation.

---

## 📚 Documentation

**📄 Complete Task Documentation:** [Cloud DevOps Accelerator - Hands-On.pdf](IVOLVE_TASKS_PDF/Cloud%20DevOps%20Accelerator%20-%20Hands-On.pdf)

This PDF contains detailed instructions, objectives, and requirements for all 30 tasks. Refer to it for comprehensive guidance on each task.

---

## 🎯 Program Overview

This training program is designed to take you through the complete DevOps journey, covering:

1. **Build Tools & Version Control** - Maven, Gradle, Git
2. **Containerization** - Docker fundamentals and advanced patterns
3. **Orchestration** - Kubernetes deployment and management
4. **Continuous Integration** - Jenkins pipelines and automation
5. **GitOps** - ArgoCD and declarative deployments
6. **Infrastructure Automation** - Ansible configuration management

Each task builds upon previous concepts, creating a comprehensive learning path from basic build tools to advanced infrastructure automation.

---

## 📋 Task Structure

### **00 - Build Tools Overview** (Tasks 1-2)

**Foundation: Build Automation and Version Control**

| Task | Title | Description |
|------|-------|-------------|
| [Task 1](00-Build-Tools-Overview/task-1) | Java Gradle Project | Build and test a Java application using Gradle |
| [Task 2](00-Build-Tools-Overview/task-2) | Java Maven Project | Build, test, and package a Java application using Maven |

**Key Concepts:** Build automation, dependency management, testing, packaging

---

### **01 - Containerization with Docker** (Tasks 3-9)

**Containerization Fundamentals and Advanced Patterns**

| Task | Title | Description |
|------|-------|-------------|
| [Task 3](01-Containerization-with-docker/task-3) | Dockerized Spring Boot Application | Containerize a Spring Boot application with Docker |
| [Task 4](01-Containerization-with-docker/task-4) | Multi-Stage Docker Build | Optimize Docker images using multi-stage builds |
| [Task 5](01-Containerization-with-docker/task-5) | Docker Multi-Stage Build | Advanced multi-stage build patterns for production |
| [Task 6](01-Containerization-with-docker/task-6) | Docker Environment Variables | Manage application configuration with environment variables |
| [Task 7](01-Containerization-with-docker/task-7) | Docker Volume Management | Persist data using Docker volumes |
| [Task 8](01-Containerization-with-docker/task-8) | Docker Networking | Connect multiple containers using Docker networks |
| [Task 9](01-Containerization-with-docker/task-9) | Docker Compose | Orchestrate multi-container applications with Docker Compose |

**Key Concepts:** Dockerfile, image optimization, volumes, networking, multi-container orchestration

---

### **02 - Orchestration** (Tasks 10-20)

**Kubernetes Deployment and Management**

| Task | Title | Description |
|------|-------|-------------|
| [Task 10](02-Orchestration/task-10) | Kubernetes Node Management | Configure node taints and tolerations |
| [Task 11](02-Orchestration/task-11) | Resource Quotas and Limits | Implement resource quotas and pod limits |
| [Task 12](02-Orchestration/task-12) | ConfigMaps and Secrets | Manage application configuration and sensitive data |
| [Task 13](02-Orchestration/task-13) | Persistent Volumes | Configure persistent storage for applications |
| [Task 14](02-Orchestration/task-14) | StatefulSets | Deploy stateful applications with StatefulSets |
| [Task 15](02-Orchestration/task-15) | Deployments and Services | Create and manage deployments and services |
| [Task 16](02-Orchestration/task-16) | Init Containers | Use init containers for application initialization |
| [Task 17](02-Orchestration/task-17) | Resource Management | Configure CPU and memory requests/limits |
| [Task 18](02-Orchestration/task-18) | Network Policies | Implement network security policies |
| [Task 19](02-Orchestration/task-19) | DaemonSets | Deploy system-level services with DaemonSets |
| [Task 20](02-Orchestration/task-20) | RBAC (Role-Based Access Control) | Configure Kubernetes RBAC for security |

**Key Concepts:** Pods, Deployments, Services, ConfigMaps, Secrets, PersistentVolumes, StatefulSets, RBAC, Network Policies

---

### **03 - Continuous Integration** (Tasks 21-24)

**Jenkins CI/CD Pipelines**

| Task | Title | Description |
|------|-------|-------------|
| [Task 21](03-Continues-Integration/task-21) | Jenkins Pipeline Basics | Create your first Jenkins pipeline |
| [Task 22](03-Continues-Integration/task-22) | Jenkins Multi-Stage Pipeline | Build multi-stage CI/CD pipelines |
| [Task 23](03-Continues-Integration/task-23) | Jenkins Shared Libraries | Create reusable pipeline libraries |
| [Task 24](03-Continues-Integration/task-24) | Jenkins Multi-Branch Pipeline | Implement multi-branch pipeline strategies |

**Key Concepts:** Jenkins pipelines, CI/CD automation, shared libraries, multi-branch workflows

---

### **04 - GitOps** (Task 25)

**Declarative Infrastructure Management**

| Task | Title | Description |
|------|-------|-------------|
| [Task 25](04-GitOps/task-25) | ArgoCD GitOps Deployment | Implement GitOps workflow with ArgoCD |

**Key Concepts:** GitOps, ArgoCD, declarative deployments, automated synchronization

---

### **05 - Ansible Automation** (Tasks 26-30)

**Infrastructure as Code and Configuration Management**

| Task | Title | Description |
|------|-------|-------------|
| [Task 26](05-Ansible-Automatio/task-26) | Ansible Initial Configuration | Set up Ansible and perform ad-hoc commands |
| [Task 27](05-Ansible-Automatio/task-27) | Automated Web Server | Automate web server deployment with Ansible playbooks |
| [Task 28](05-Ansible-Automatio/task-28) | DevOps Tools Configuration with Roles | Install Docker, Kubernetes tools, and Jenkins using Ansible roles |
| [Task 29](05-Ansible-Automatio/task-29) | Ansible Vault | Secure sensitive data with Ansible Vault |
| [Task 30](05-Ansible-Automatio/task-30) | Dynamic Inventory with AWS EC2 | Automate host discovery and management with AWS EC2 dynamic inventory |

**Key Concepts:** Ansible playbooks, roles, vault encryption, dynamic inventory, infrastructure automation

---

## 🚀 Getting Started

### Prerequisites

Before starting, ensure you have:

- **Linux Environment** (CentOS/RHEL recommended)
- **Java Development Kit** (JDK 8 or 17, depending on task)
- **Docker** installed and running
- **Kubernetes Cluster** (for orchestration tasks)
- **Jenkins** installed and configured (for CI tasks)
- **Ansible** installed (for automation tasks)
- **AWS Account** (for Task 30)

### Quick Start Guide

1. **Clone the Repository:**
   ```bash
   git clone <repository-url>
   cd IVOLVE-TAKS
   ```

2. **Review the PDF Documentation:**
   - Open `IVOLVE_TASKS_PDF/Cloud DevOps Accelerator - Hands-On.pdf`
   - Read the overview and task-specific instructions

3. **Start with Task 1:**
   - Navigate to `00-Build-Tools-Overview/task-1`
   - Follow the README instructions
   - Complete tasks sequentially for best learning experience

4. **Each Task Contains:**
   - Detailed README with step-by-step instructions
   - Required files and configurations
   - Screenshots demonstrating expected results
   - Troubleshooting sections for common issues

---

## 📁 Repository Structure

```
IVOLVE-TAKS/
├── README.md                          # This file
├── IVOLVE_TASKS_PDF/                  # Complete task documentation PDF
│   └── Cloud DevOps Accelerator - Hands-On.pdf
├── 00-Build-Tools-Overview/           # Tasks 1-2
│   ├── task-1/
│   └── task-2/
├── 01-Containerization-with-docker/   # Tasks 3-9
│   ├── task-3/
│   ├── task-4/
│   ├── task-5/
│   ├── task-6/
│   ├── task-7/
│   ├── task-8/
│   └── task-9/
├── 02-Orchestration/                   # Tasks 10-20
│   ├── task-10/
│   ├── task-11/
│   ├── ... (tasks 12-19)
│   └── task-20/
├── 03-Continues-Integration/           # Tasks 21-24
│   ├── task-21/
│   ├── task-22/
│   ├── task-23/
│   └── task-24/
├── 04-GitOps/                          # Task 25
│   └── task-25/
└── 05-Ansible-Automatio/               # Tasks 26-30
    ├── task-26/
    ├── task-27/
    ├── task-28/
    ├── task-29/
    └── task-30/
```

---

## 🎓 Learning Path

### Phase 1: Foundations (Tasks 1-2)
**Build Tools & Version Control**
- Understand build automation
- Learn dependency management
- Master version control workflows

### Phase 2: Containerization (Tasks 3-9)
**Docker Fundamentals**
- Containerize applications
- Optimize Docker images
- Manage multi-container applications
- Understand Docker networking and volumes

### Phase 3: Orchestration (Tasks 10-20)
**Kubernetes Mastery**
- Deploy and manage applications
- Configure storage and networking
- Implement security policies
- Manage stateful applications

### Phase 4: Automation (Tasks 21-25)
**CI/CD and GitOps**
- Build CI/CD pipelines
- Implement GitOps workflows
- Automate deployment processes

### Phase 5: Infrastructure as Code (Tasks 26-30)
**Ansible Automation**
- Automate configuration management
- Secure sensitive data
- Discover and manage cloud resources
- Implement infrastructure automation

---

## 🔧 Technology Stack

This training program covers:

| Technology | Purpose | Tasks |
|------------|---------|-------|
| **Gradle** | Build automation | 1 |
| **Maven** | Build automation | 2 |
| **Docker** | Containerization | 3-9 |
| **Kubernetes** | Container orchestration | 10-20 |
| **Jenkins** | CI/CD automation | 21-24 |
| **ArgoCD** | GitOps deployment | 25 |
| **Ansible** | Configuration management | 26-30 |
| **AWS EC2** | Cloud infrastructure | 30 |

---

## 📸 Screenshots and Verification

Each task includes:
- ✅ Screenshots demonstrating expected results
- ✅ Verification steps to confirm successful completion
- ✅ Troubleshooting guides for common issues
- ✅ Step-by-step instructions with code examples

---

## 🐛 Troubleshooting

Each task directory contains a comprehensive README with:
- **Common errors** and their solutions
- **Prerequisites** and setup instructions
- **Verification steps** to confirm completion
- **Troubleshooting sections** for specific issues

For task-specific issues, refer to the individual task README files.

---

## 📚 Additional Resources

### Official Documentation
- [Docker Documentation](https://docs.docker.com/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Jenkins Documentation](https://www.jenkins.io/doc/)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [Ansible Documentation](https://docs.ansible.com/)

### Learning Resources
- Kubernetes.io - Official Kubernetes tutorials
- Docker Hub - Container image registry
- Jenkins Pipeline Syntax - Pipeline DSL reference
- Ansible Galaxy - Pre-built roles and collections

---

## ✅ Completion Checklist

Track your progress through all 30 tasks:

### Build Tools (2 tasks)
- [ ] Task 1: Java Gradle Project
- [ ] Task 2: Java Maven Project

### Containerization (7 tasks)
- [ ] Task 3: Dockerized Spring Boot
- [ ] Task 4: Multi-Stage Docker Build
- [ ] Task 5: Advanced Multi-Stage Build
- [ ] Task 6: Docker Environment Variables
- [ ] Task 7: Docker Volume Management
- [ ] Task 8: Docker Networking
- [ ] Task 9: Docker Compose

### Orchestration (11 tasks)
- [ ] Task 10: Kubernetes Node Management
- [ ] Task 11: Resource Quotas
- [ ] Task 12: ConfigMaps and Secrets
- [ ] Task 13: Persistent Volumes
- [ ] Task 14: StatefulSets
- [ ] Task 15: Deployments and Services
- [ ] Task 16: Init Containers
- [ ] Task 17: Resource Management
- [ ] Task 18: Network Policies
- [ ] Task 19: DaemonSets
- [ ] Task 20: RBAC

### Continuous Integration (4 tasks)
- [ ] Task 21: Jenkins Pipeline Basics
- [ ] Task 22: Multi-Stage Pipeline
- [ ] Task 23: Jenkins Shared Libraries
- [ ] Task 24: Multi-Branch Pipeline

### GitOps (1 task)
- [ ] Task 25: ArgoCD GitOps Deployment

### Ansible Automation (5 tasks)
- [ ] Task 26: Ansible Initial Configuration
- [ ] Task 27: Automated Web Server
- [ ] Task 28: DevOps Tools with Roles
- [ ] Task 29: Ansible Vault
- [ ] Task 30: Dynamic Inventory with AWS EC2

---

## 🤝 Contributing

This is a training repository. If you find issues or have improvements:

1. Document the issue clearly
2. Provide steps to reproduce
3. Suggest solutions if possible
4. Update README files with additional troubleshooting steps

---

## 📝 Notes

- **Sequential Learning:** Tasks are designed to build upon each other. Complete them in order for the best learning experience.
- **Practice Makes Perfect:** Don't hesitate to repeat tasks to reinforce concepts.
- **Documentation:** Always refer to the PDF for detailed requirements and objectives.
- **Screenshots:** Take screenshots of your work to verify completion and for future reference.

---

## 🎯 Learning Objectives

By completing all 30 tasks, you will have:

✅ **Mastered Build Tools** - Gradle and Maven for Java applications  
✅ **Containerized Applications** - Docker fundamentals and advanced patterns  
✅ **Orchestrated Containers** - Kubernetes deployment and management  
✅ **Automated CI/CD** - Jenkins pipeline creation and management  
✅ **Implemented GitOps** - Declarative infrastructure management  
✅ **Automated Infrastructure** - Ansible configuration management  
✅ **Cloud Integration** - AWS EC2 dynamic inventory and automation  

---

## 📞 Support

For questions or issues:
1. Review the task-specific README
2. Check the troubleshooting section
3. Refer to the PDF documentation
4. Review screenshots for expected results

---

## 📄 License

This repository is part of the IVOLVE training program. See individual task directories for specific licensing information.

---

## 🎓 Final Notes

**Congratulations on starting your DevOps journey!**

This comprehensive training program covers the entire DevOps lifecycle. Take your time with each task, understand the concepts, and don't hesitate to experiment. The hands-on experience you gain here will be invaluable in your DevOps career.

**Remember:**
- Read the PDF documentation for detailed instructions
- Follow each task's README for step-by-step guidance
- Take screenshots to verify your work
- Troubleshoot issues using the provided guides
- Build upon previous knowledge as you progress

**Good luck with your training! 🚀**

---

*Last Updated: January 2026*
