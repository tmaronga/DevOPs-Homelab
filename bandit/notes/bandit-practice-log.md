# Bandit OverTheWire Practice Log

## Session Format
For each level, document:
1. Level number and date
2. Challenge description
3. Commands used
4. Solution approach
5. Key learning
6. Time taken

---

## Level 0 → Level 1
**Date:** November 6, 2025  
**Time Taken:** 5 minutes

### Challenge
Connect to the game using SSH. The goal is to log in using SSH with the provided credentials.

### Commands Used
```bash
ssh bandit0@bandit.labs.overthewire.org -p 2220
# Password: bandit0

# Once connected:
ls -la
cat readme
```

### Solution
- The password for level 1 is stored in a file called `readme` in the home directory.


### Password for Next Level
```
ZjLjTmM6FvvyRnrb2rfNWOZOTa6ip5If
```

### Key Learning
- SSH connection to remote server
- Basic file listing
- Reading file contents with cat
- Understanding home directory (~)


### Commands Practiced
- `ssh` - Secure shell connection
- `ls -la` - List all files including hidden
- `cat` - Display file contents
- `pwd` - Print working directory


---

## Level 1 → Level 2
**Date:** November 6, 2025
**Time Taken:** 8 mins 

### Challenge
The password for the next level is stored in a file called `-` located in the home directory.

### Commands Used
```bash
- `ssh` - Secure shell connection
- `ls -la` - List all files including hidden
- `cat ./-` - Display file contents
- `pwd`- Print working directory

```

### Solution
- The dash `-` is a special character (means stdin). Use `./-` to specify it as a filename.
- The password for level 1 is stored in a file called `-` in the /home/bandit1home directory

### Password for Next Level
```
263JGJPfgU6LtdEvgfWU1XP5yac29mFx

```

### Key Learning
- The primary learning is that the forward slash / is the root directory from which all other files and directories descend in a unified tree structure. Understanding this hierarchy is fundamental for navigating the system and locating files. 
- Handling special characters in filenames
- Using `./ ` to reference current directory
- Alternative input redirection with `< `

### Commands Practiced
```bash
- `ssh` - Secure shell connection
- `ls -la` - List all files including hidden
- `cat ./-` - Display file contents
- `pwd` - Print working directory
- `find` - find the file 
- `du` - measures the disk space occupied by files or directories
- `cat ./-` - Read file with special name
- `cat < -` - Alternative approach

---

## Level 2 → Level 3
**Date:** November 6, 2025 
**Time Taken:** 25  mins

### Challenge
The password for the next level is stored in a file called --spaces in this filename-- located in the home directory

### Commands Used
```bash
- `ls -la` - List all files including hidden
- `cat -- "` - Display file contents
- `pwd` - Print working directory
- `find` - find the file 
- `du` - measures the disk space occupied by files or directories


### Solution
The password for the next level is in a file with spaces named "--spaces in this filename--"


### Password for Next Level
```
MNk8KNH3Usiio41PRUEoDFPqfxLPlSmx

```

### Key Learning
- Because the filename starts with a dash -, Linux thinks it’s an option.So you must tell the command
- -- tells Linux: anything after this is not an option
- the filename contains spaces, so you must put it in quotes
---

# Level 3 → Level 4
**Date:** November 7, 2025
**Time Taken:** 5 mins

### Challenge
The password for the next level is stored in a hidden file in the inhere directory.

### Commands Used
```bash
- `ssh` - Secure shell connection
- `cd ~/inhere` - find directory inhere
- `ls -la` - List all files including hidden
- `cat ...Hiding-From-You` - Display file contents

```

### Solution
The password for nex level  is stored in a hidden file called `...Hiding-From-You` in the home/bandit3/inhere directory

### Password for Next Level
```
2WmrDFRmJIq3IPxneAaMGhap0pFhF3NJ

```

### Key Learning
- inhere is a directory placed in your home folder.
- Linux hides files that start with a dot (.).
- ls normally doesn't show them.
- ls -la shows everything, including hidden files.
- cat <filename> prints the file’s contents.
- Hidden files behave exactly like regular files — they are just visually hidden.

### Commands Practiced
```bash
- `ssh` - Secure shell connection
- `ls -la` - List all files including hidden
- `cat .hidden` - Display hidden file contents
- `pwd` - Print working directory
- `find` - find the file 
- `du` - measures the disk space occupied by files or directories

---
# Level 4 → Level 5
**Date:** November 7, 2025
**Time Taken:** 5 mins

### Challenge
The password for the next level is stored in the only human-readable file in the inhere directory. Tip: if your terminal is messed up, try the “reset” command.



### Commands Used
```bash
- `ssh` - Secure shell connection
- `cd ~/inhere` - find directory inhere
- `ls -la` - List all files including hidden
- `cat ...Hiding-From-You` - Display file contents

```

### Solution
The password for nex level  is stored in a file with human-readable text `-file07` which is showing “ASCII text” (or sometimes “UTF-8 text”)
is the correct file — it's human-readable
 
### Password for Next Level
```
4oQYVPkxZOOEOO5pTW81FB8j8lxXGUQw

```

### Key Learning
- Most files contain weird binary data → not readable by humans.
- The file command tells you what kind of content is inside.
- The only file labeled ASCII text is safe to open with cat.
- That file contains the password.
- `file` command determines file type
- Not all files are text (can be data, binary, etc.)
- Wildcards `*` check multiple files at once

### Commands Practiced
```bash
- `ssh` - Secure shell connection
- `cd ~/inhere` - the directory we are working with
- `ls -la` - List all files including hidden
- `cat -- -file07` - Display hidden file contents
- `pwd` - Print working directory

---

## Summary Statistics

### Progress
- **Levels Completed:** 5/20
- **Total Time Spent:** 3 hours
- **Started:** November 6, 2025
- **Completed:** [Date when finished]

### Commands Mastered Through Bandit
- [ ] ssh
- [ ] ls (all variants)
- [ ] cat
- [ ] find
- [ ] grep
- [ ] file
- [ ] strings
- [ ] base64
- [ ] tr
- [ ] tar
- [ ] gzip
- [ ] xxd
- [ ] nc (netcat)
- [ ] openssl
- [ ] nmap

### Most Challenging Levels
1. Level X - [Why it was challenging]
2. Level Y - [Why it was challenging]
3. Level Z - [Why it was challenging]

### Most Useful Commands Learned
1. [Command] - [Why it's useful]
2. [Command] - [Why it's useful]
3. [Command] - [Why it's useful]

---

**Repository:** https://github.com/tmaronga/DevOPs-Homelab  
**Bandit:** https://overthewire.org/wargames/bandit/
