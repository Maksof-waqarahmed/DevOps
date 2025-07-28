# 📘 Git & GitHub: Complete Guide (Beginner to Advanced)

---

## 📦 Table of Contents

1. [What is Git?](#-what-is-git)
2. [What is GitHub?](#-what-is-github)
3. [Installation & Setup](#-installation--setup)
4. [Core Git Workflow](#-git-workflow-overview)
5. [Branching in Git](#-branching-in-git)
6. [Pull Requests (PR)](#-pull-request-pr)
7. [PR Conflicts & Resolution](#-pr-conflicts--resolution-strategies)
8. [Undoing Mistakes Safely](#-undoing-mistakes-safely)
9. [Git Remote](#-git-remote)
10. [Pull vs Fetch](#-pull-vs-fetch)
11. [HEAD in Git](#-head-in-git)
12. [Git Stash](#-git-stash)
13. [Git Log](#-git-log)
14. [Git Diff](#-git-diff)
15. [Undoing Mistakes (Quick Reference)](#-undoing-mistakes-quick-reference)
16. [Semantic Versioning & Mobile Releases](#-version-control-terminology)
17. [Other Useful Git Commands](#-other-useful-git-commands)
18. [Best Practices](#-best-practices)
19. [Additional Topics](#-additional-topics)
20. [Additional Resources](#-additional-resources)

---

## 🔹 What is Git?

**Git** is a **distributed version control system (DVCS)** used to track changes in source code during software development. It allows multiple developers to work on a project without interfering with each other’s work.

---

## 🔹 What is GitHub?

**GitHub** is a cloud-based platform that hosts Git repositories. It provides collaboration features like **pull requests**, **issues**, **code review**, and **team management**.

---

## 🔹 Installation & Setup

```bash
# Set user identity
git config --global user.name "Your Name"
git config --global user.email "you@example.com"

# Set default branch name
git config --global init.defaultBranch main
````

**Install Git:**

* **Windows:** [git-scm.com](https://git-scm.com)
* **macOS:** `brew install git`
* **Linux:** `sudo apt-get install git`

---

## 🔹 Git Workflow Overview

1. `git init` – Initialize a new Git repo
2. `git add` – Stage changes
3. `git commit` – Commit staged changes
4. `git push` – Send changes to remote (GitHub)
5. `git pull` – Fetch + merge updates from remote
6. `git clone` – Copy a remote repo locally

---

## 🔹 Branching in Git

Branches help in working on different features or bug fixes independently.

### Common Commands

```bash
git branch                # list branches
git branch feature-x      # create a new branch
git checkout feature-x    # switch to the branch
git merge feature-x       # merge feature-x into current branch
git branch -d feature-x   # delete the branch
```

**Best Practice:**
Use descriptive names like `feature/login`, `hotfix/crash`, or `bugfix/ui`.

---

## 🔹 Pull Request (PR)

A **pull request** lets you request to merge changes from one branch into another (often from a feature branch to `main`).
Used in team environments for **code review** and **approval**.

---

## 🔹 PR Conflicts & Resolution Strategies

When multiple changes affect the same part of a file, **merge conflicts** happen.

### Options

* `ours` – Keep your branch’s version
* `theirs` – Keep incoming branch’s version
* `git restore --staged <file>` – Unstage conflict file to redo merge manually

---

## 🔹 Undoing Mistakes Safely

| Task                              | Command                       |
| --------------------------------- | ----------------------------- |
| Discard file changes              | `git restore <file>`          |
| Unstage a file                    | `git restore --staged <file>` |
| Undo commit (keep changes)        | `git reset --soft HEAD~1`     |
| Undo commit + clear staging       | `git reset --mixed HEAD~1`    |
| Undo everything (unrecoverable)   | `git reset --hard HEAD~1`     |
| Revert commit (safe undo)         | `git revert <commit-hash>`    |
| Temporarily save work in progress | `git stash` + `git stash pop` |

---

## 🔹 Git Remote

```bash
git remote add origin <repo_url>  # Link local repo to GitHub
git remote -v                     # View current remotes
```

---

## 🔹 Pull vs Fetch

| Command     | What It Does                                  |
| ----------- | --------------------------------------------- |
| `git fetch` | Download latest changes from remote only      |
| `git pull`  | Fetch + Merge the changes into current branch |

---

## 🔹 HEAD in Git

* `HEAD` refers to the **current commit** your branch is pointing to.
* `HEAD~1`, `HEAD~2` means 1 or 2 commits before HEAD.

---

## 🔹 Git Stash

Temporarily saves your changes without committing them.

```bash
git stash            # save current changes
git stash pop        # apply and remove the stash
git stash list       # list all stashes
```

---

## 🔹 Git Log

```bash
git log              # show commits
git log --oneline    # short format
git log -p           # patch (with code changes)
```

---

## 🔹 Git Diff

```bash
git diff                     # view unstaged changes
git diff --staged            # view staged changes
git diff HEAD~1 HEAD         # compare two commits
```

---

## 🔹 Undoing Mistakes (Quick Reference)

| Task                     | Command                       |
| ------------------------ | ----------------------------- |
| Undo file changes        | `git restore <file>`          |
| Undo staged file         | `git restore --staged <file>` |
| Revert a commit          | `git revert <commit>`         |
| Reset to previous commit | `git reset --hard <commit>`   |
| Undo last commit (soft)  | `git reset --soft HEAD~1`     |
| Amend last commit        | `git commit --amend`          |

---

## 🔹 Version Control Terminology

* **Major** – Big changes, possibly breaking old features.
* **Minor** – New features, backward compatible.
* **Patch** – Bug fixes only.
* **Hotfix** – Emergency fix directly to production.

Example: `v2.3.1` (Major.Minor.Patch)

---

## 🔹 Mobile Development Versioning

In mobile apps (iOS/Android):

* **versionCode** – internal number for updates (e.g., `24`)
* **versionName** – public visible version (e.g., `1.4.2`)
* Use **hotfix branches** to patch live apps quickly.

---

## 🔹 Other Useful Git Commands

```bash
git status                    # current status of files
git clean -fd                 # delete untracked files/folders
git cherry-pick <sha>         # apply a specific commit
git rebase <branch>           # reapply commits on top of another branch
git tag v1.0                  # mark a specific commit
git config --global alias.co checkout  # create shortcut
```

---

## ✅ Best Practices

* Use **feature branches** for new work.
* Commit often with meaningful messages.
* Always **pull** before pushing.
* Don’t commit sensitive data (add `.env` to `.gitignore`).
* Resolve PR conflicts **locally** and then push changes.

---

## 🔹 Additional Topics

### 🔸 `.gitignore` File

Used to exclude files from being tracked (e.g., `node_modules`, `.env`, `dist/`).

```bash
# Example .gitignore
node_modules/
.env
dist/
```

### 🔸 Rebase vs Merge

* `git merge`: creates a merge commit (safe, keeps history)
* `git rebase`: rewrites history, makes it linear (clean history)

Use `rebase` with caution, especially in team projects.

---

## 🔹 Additional Resources

* [Pro Git Book](https://git-scm.com/book/en/v2)
* [GitHub Docs](https://docs.github.com/)
* [Oh My Git! Interactive Git Game](https://ohmygit.org/)
* [Learn Git Branching (Visualizer)](https://learngitbranching.js.org/)

---