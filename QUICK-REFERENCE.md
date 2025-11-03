# DevOps Quick Reference Guide

## 🔥 Most Used Commands

### Navigation
```bash
pwd                    # Where am I?
cd ~                   # Go home
cd -                   # Go back
ls -lah                # List all files
```

### Files
```bash
cat file               # View file
nano file              # Edit file
cp src dest            # Copy
mv src dest            # Move/rename
rm file                # Delete
chmod +x file          # Make executable
```

### Search
```bash
grep "text" file       # Search in file
find . -name "*.sh"    # Find files
```

### System
```bash
df -h                  # Disk space
free -h                # Memory
htop                   # Processes
whoami                 # Current user
```

### Git Workflow
```bash
git status             # Check status
git add .              # Stage changes
git commit -m "msg"    # Commit
git push               # Push to GitHub
git log --oneline      # View history
```

---

## 📋 File Permissions
```
-rwxr-xr-x
 │││ ││ ││
 │││ ││ └└─ Others: read + execute
 │││ └└──── Group: read + execute  
 │└└─────── Owner: read + write + execute
 └────────── Type (- = file, d = directory)
```

**Common chmod:**
- `755` = rwxr-xr-x (scripts)
- `644` = rw-r--r-- (files)
- `+x` = add execute permission

---

## 💡 Special Characters
```bash
~        # Home directory
.        # Current directory
..       # Parent directory
*        # All files
>        # Overwrite file
>>       # Append to file
|        # Pipe to next command
&        # Run in background
```

---

## 🚨 Emergency Commands
```bash
Ctrl + C               # Cancel command
Ctrl + Z               # Suspend process
kill -9 PID            # Force kill process
sudo apt clean         # Clean disk space
```

---

## 📊 My System Stats
- **CPU:** AMD PRO A12-8800B (4 cores)
- **RAM:** 14GB
- **Storage:** 233GB (196GB free)
- **OS:** Ubuntu 24.04.3 LTS

---

## 🔗 Resources
- **Repository:** https://github.com/tmaronga/DevOPs-Homelab
- **Journey Start:** November 4, 2025
- **Goal:** Tech Support → DevOps Engineer

---

*Quick reference for daily DevOps tasks*
