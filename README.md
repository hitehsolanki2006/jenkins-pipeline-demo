# Jenkins Pipeline Demo - Production-Ready Structure

This repository demonstrates how to create a **production-ready Jenkins pipeline structure** where Jenkins jobs pull Jenkinsfiles from a GitHub repository and execute them dynamically.

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Repository Structure](#repository-structure)
- [How It Works](#how-it-works)
- [Setup Instructions](#setup-instructions)
- [Pipeline Flow](#pipeline-flow)
- [Files Explained](#files-explained)
- [Troubleshooting](#troubleshooting)

---

## 🎯 Overview

This project showcases a **modular Jenkins pipeline architecture** where:

1. **Jenkins Job UI** triggers a local Jenkinsfile
2. **Local Jenkinsfile** (`jenkinsfile-local`) clones this GitHub repository
3. **GitHub Jenkinsfile** (`jenkinsfile-github`) contains the actual pipeline stages
4. Pipeline executes stages like creating folders, generating files, and cleanup

This separation allows you to:
- ✅ Version control your pipeline code
- ✅ Update pipelines without modifying Jenkins job configuration
- ✅ Reuse pipeline logic across multiple jobs
- ✅ Maintain a clean separation between Jenkins config and pipeline logic

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        Jenkins Job (UI)                         │
│                     Configured in Jenkins                       │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│                     jenkinsfile-local                           │
│              (Stored on Jenkins Server)                         │
│                                                                 │
│  • Loads from Jenkins workspace                                 │
│  • Clones GitHub repository                                     │
│  • Calls jenkinsfile-github from cloned repo                    │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           ▼ (git clone)
┌─────────────────────────────────────────────────────────────────┐
│                  GitHub Repository                              │
│           jenkins-pipeline-demo                                 │
│                                                                 │
│  ├── jenkinsfile-github    (Pipeline stages)                    │
│  ├── run.bat               (Demo script)                        │
│  └── README.md             (Documentation)                      │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│                   jenkinsfile-github                            │
│             (Cloned from GitHub)                                │
│                                                                 │
│  • Runs run.bat                                                 │
│  • Creates demo-folder                                          │
│  • Generates test file with BUILD_NUMBER                        │
│  • Displays content                                             │
│  • Cleans up folders                                            │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📁 Repository Structure

```
jenkins-pipeline-demo/
│
├── jenkinsfile-github          # GitHub-stored pipeline (version controlled)
├── jenkinsfile-local           # Jenkins server file (not in repo - template only)
├── run.bat                     # Demo batch script
├── README.md                   # This documentation
├── .gitignore                  # Git ignore rules
│
└── assets/                     # Screenshots (optional)
    ├── image1.png
    ├── image2.png
    └── ...
```

**Important:** `jenkinsfile-local` is **NOT** stored in this repository. It lives on your Jenkins server at:
```
C:\ProgramData\Jenkins\.jenkins\workspace\<JOB_NAME>\jenkinsfile-local
```

---

## ⚙️ How It Works

### Step-by-Step Execution

1. **User triggers Jenkins job** from Jenkins UI

2. **Jenkins UI Jenkinsfile** (stored in Jenkins job configuration) loads `jenkinsfile-local`:
   ```groovy
   load("jenkinsfile-local").stages()
   ```

3. **jenkinsfile-local** executes:
   - Checks if repo folder exists and removes it (avoids "already exists" errors)
   - Clones this GitHub repository
   - Loads `jenkinsfile-github` from the cloned repo
   - Calls its `stages()` method

4. **jenkinsfile-github** executes pipeline stages:
   - Displays introduction message via `run.bat`
   - Shows current path
   - Lists directory contents
   - Creates `demo-folder`
   - Generates a text file named after the build number
   - Displays file content
   - Cleans up created folders

---

## 🚀 Setup Instructions

### Prerequisites

- Jenkins installed and running
- Git installed on Jenkins server
- Windows environment (cmd shell)
- GitHub repository access

### Step 1: Create Jenkins Job

1. Open Jenkins UI
2. Click **New Item**
3. Enter job name (e.g., `Jenkins-Github-Demo`)
4. Select **Pipeline** and click **OK**

### Step 2: Configure Pipeline Script

In the job configuration, under **Pipeline**, select **Pipeline script** and paste:

```groovy
#!/usr/bin/env groovy

pipeline {
    agent any
    stages {
        stage("Loading Local Jenkins file") {
            steps {
                script {
                    load("jenkinsfile-local").stages()
                }
            }
        }
    }
}
```

### Step 3: Create jenkinsfile-local on Jenkins Server

On your Jenkins server, navigate to the workspace:
```
C:\ProgramData\Jenkins\.jenkins\workspace\<YOUR_JOB_NAME>\
```

Create `jenkinsfile-local` with this content:

```groovy
def stages(){
    echo "Hello from Local jenkins file"
    echo "we are cloning the repo"

    bat '''
    if exist jenkins-pipeline-demo (
        echo repo folder already exists, removing it...
        rmdir /s /q jenkins-pipeline-demo
    )
    git clone https://github.com/YOUR_USERNAME/jenkins-pipeline-demo.git
    '''

    echo "repo cloned successfully"

    load("jenkins-pipeline-demo/jenkinsfile-github").stages()
}

return this
```

**Important:** Replace `YOUR_USERNAME` with your GitHub username.

### Step 4: Clone and Push This Repo

```bash
git clone https://github.com/YOUR_USERNAME/jenkins-pipeline-demo.git
cd jenkins-pipeline-demo

# Add your files
git add jenkinsfile-github run.bat README.md .gitignore
git commit -m "Initial commit"
git push origin main
```

### Step 5: Run the Job

1. Go to your Jenkins job
2. Click **Build Now**
3. Watch the console output

---

## 🔄 Pipeline Flow

```
[Jenkins UI] 
    ↓
[Load jenkinsfile-local]
    ↓
[Clone GitHub Repo]
    ↓
[Load jenkinsfile-github from cloned repo]
    ↓
[Execute Pipeline Stages]
    │
    ├── Introduction (run run.bat)
    ├── Current path (show workspace path)
    ├── List Directory (show contents)
    ├── Create demofolder (mkdir demo-folder)
    ├── Creating test file (echo > BUILD_NUMBER.txt)
    ├── Showing content (type file)
    ├── List Directory After Create (verify)
    └── Cleanup (remove folders)
```

---

## 📄 Files Explained

### 1. `jenkinsfile-github`

**Purpose:** Contains the actual pipeline stages (version controlled).

**Key Features:**
- Runs the `run.bat` script to display project info
- Demonstrates file and folder operations
- Uses Jenkins environment variables (`%BUILD_NUMBER%`)
- Cleans up created artifacts at the end
- Escapes special characters for Windows cmd (`^>`, `^<`, `^|`)

**Why it's in GitHub:**
- Version controlled
- Easy to update without touching Jenkins config
- Can be reviewed via pull requests
- Shareable across teams

### 2. `jenkinsfile-local`

**Purpose:** Acts as a bridge between Jenkins and GitHub.

**Key Features:**
- Removes old clone folder (prevents "already exists" errors)
- Clones the GitHub repository
- Loads `jenkinsfile-github` from cloned repo
- Must return `this` so Jenkins can call `.stages()`

**Why it's on Jenkins server:**
- Contains environment-specific logic
- May contain credentials or server paths
- Different Jenkins instances may have different configurations

### 3. `run.bat`

**Purpose:** Demo batch script that explains the pipeline structure.

**Key Features:**
- Uses `@echo off` to suppress command echo
- Escapes pipe characters (`^|`) for proper display
- Shows visual flow diagram
- Educational/informative output

---

## 🛠️ Troubleshooting

### Issue: `jenkinsfile-local` not found

**Error:**
```
java.nio.file.NoSuchFileException: jenkinsfile-local
```

**Solution:**
Make sure `jenkinsfile-local` exists in the Jenkins workspace:
```
C:\ProgramData\Jenkins\.jenkins\workspace\<JOB_NAME>\jenkinsfile-local
```

---

### Issue: "repo already exists" error

**Error:**
```
fatal: destination path 'jenkins-pipeline-demo' already exists
```

**Solution:**
The `jenkinsfile-local` now includes automatic cleanup:
```groovy
if exist jenkins-pipeline-demo (
    rmdir /s /q jenkins-pipeline-demo
)
```
Update your `jenkinsfile-local` with this logic.

---

### Issue: Backslash causing Groovy errors

**Error:**
```
unexpected char: '\'
```

**Solution:**
In Groovy triple-quoted strings (`'''`), use double backslashes:
```groovy
bat'''
echo file > demo-folder\\%BUILD_NUMBER%.txt
'''
```

---

### Issue: Special characters creating files

**Error:**
Files named `Printing`, `listing`, `credting`, `showing` appear in workspace.

**Cause:**
Characters like `>`, `<`, `|` are cmd operators and must be escaped.

**Solution:**
Use `^` to escape:
```bat
echo --^> This is a message ^<--
```

---

### Issue: `NullPointerException` when calling `.stages()`

**Error:**
```
Cannot invoke method stages() on null object
```

**Solution:**
Both `jenkinsfile-local` and `jenkinsfile-github` must end with:
```groovy
return this
```

---

## 📊 Expected Console Output

```
Started by user Admin User
[Pipeline] Start of Pipeline
[Pipeline] node
Running on Jenkins in C:\ProgramData\Jenkins\.jenkins\workspace\...
[Pipeline] {
[Pipeline] stage
[Pipeline] { (Loading Local Jenkins file)
[Pipeline] script
[Pipeline] {
[Pipeline] load
[Pipeline] echo
Hello from Local jenkins file
[Pipeline] echo
we are cloning the repo
[Pipeline] bat
Cloning into 'jenkins-pipeline-demo'...
[Pipeline] echo
repo cloned successfully
[Pipeline] load
[Pipeline] stage
[Pipeline] { (Introduction)
=======================================================
  Hello, from inside the GitHub Repo!
=======================================================
...
[Pipeline] stage
[Pipeline] { (Cleanup)
--> Cleaning up created folders <--
--> Cleanup done <--
[Pipeline] End of Pipeline
Finished: SUCCESS
```

---

## 📚 Learning Resources

- [Jenkins Pipeline Documentation](https://www.jenkins.io/doc/book/pipeline/)
- [Groovy Syntax for Jenkinsfile](https://groovy-lang.org/syntax.html)
- [Windows CMD Special Characters](https://ss64.com/nt/syntax-esc.html)

---

## 🤝 Contributing

Feel free to open issues or submit pull requests to improve this demo!

---

## 📝 License

This project is open-source and available for educational purposes.

---

## 📧 Contact

For questions or feedback, reach out via GitHub issues.

---

**Happy Pipelining! 🚀**
