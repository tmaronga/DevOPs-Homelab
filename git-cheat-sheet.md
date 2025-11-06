# Complete workflow
nano file                          # Edit
Ctrl+X, Y, Enter                   # Save and exit
git status                         # Check changes
git diff                           # See detailed changes
git add .                          # Stage all
git commit -m "message"            # Commit
git push                           # Push to GitHub

# Quick checks
git status                         # What changed?
git log --oneline                  # Recent commits
git diff file                      # What changed in file?
git diff --staged                  # What's staged?

# Common operations
git add file                       # Stage one file
git add .                          # Stage everything
git commit -m "msg"                # Commit with message
git push                           # Send to GitHub
git pull                           # Get latest from GitHub

# Undo operations
git checkout -- file               # Discard changes
git reset HEAD file                # Unstage file
git commit --amend                 # Fix last commit
