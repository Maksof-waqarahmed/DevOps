# 🧠 Git Interview Questions & Answers (Beginner to Advanced)

A curated list of essential Git interview questions with concise and accurate answers, covering core commands, advanced workflows, internal architecture, and recovery strategies.

---

## 📚 Table of Contents

1. [Difference Between `git add .`, `git add -A`, and `git add -u`](#1-difference-between-git-add--git-add--a-and-git-add--u)
2. [View All Remotes and URLs](#2-view-all-remotes-and-urls)
3. [HEAD vs HEAD~1 vs HEAD^](#3-head-vs-head1-vs-head)
4. [Stage Part of a File](#4-stage-part-of-a-file)
5. [Find Author of a Line](#5-find-author-of-a-line)
6. [Visual Commit Graph](#6-visual-commit-graph)
7. [Revert Multiple Commits](#7-revert-multiple-commits)
8. [Snapshot vs Line-Based Tracking](#8-snapshot-vs-line-based-tracking)
9. [Merge: `--no-ff` vs `--squash`](#9-merge---no-ff-vs---squash)
10. [Git Index (Staging Area)](#10-git-index-staging-area)
11. [Use of `git pull --rebase`](#11-use-of-git-pull---rebase)
12. [Recover Deleted Branch](#12-recover-deleted-branch)
13. [`git worktree` Usage](#13-git-worktree-usage)
14. [Shallow Clone vs Full Clone](#14-shallow-clone-vs-full-clone)
15. [Git Hooks + Use Case](#15-git-hooks--use-case)
16. [Risks of `git reset --hard`](#16-risks-of-git-reset---hard)
17. [Merging Unrelated Histories](#17-merging-unrelated-histories)
18. [`git rebase -i` and When Not to Use](#18-git-rebase--i-and-when-not-to-use)
19. [Tracked vs Untracked vs Modified vs Staged](#19-tracked-vs-untracked-vs-modified-vs-staged)
20. [How Git Identifies Duplicate Files](#20-how-git-identifies-duplicate-files)
21. [Submodules vs Subtrees](#21-submodules-vs-subtrees)
22. [`reflog` vs `git log`](#22-reflog-vs-git-log)
23. [Move a Commit Between Branches](#23-move-a-commit-between-branches)
24. [Git Object Model](#24-git-object-model)
25. [Effect of `git push --force`](#25-effect-of-git-push---force)

---

### 1. Difference Between `git add .`, `git add -A`, and `git add -u`

- `git add .` adds new/modified files in the current directory (not deletions).  
- `git add -A` stages all changes (including deletions).  
- `git add -u` stages modifications and deletions but not untracked files.

---

### 2. View All Remotes and URLs

```bash
git remote -v
````

---

### 3. HEAD vs HEAD\~1 vs HEAD^

* `HEAD` refers to the latest commit on the current branch.
* `HEAD~1` is one commit before `HEAD`.
* `HEAD^` is also the parent of `HEAD` (same as `HEAD~1` unless it’s a merge commit).

---

### 4. Stage Part of a File

```bash
git add -p
```

Allows interactively staging parts (hunks) of a file.

---

### 5. Find Author of a Line

```bash
git blame <filename>
```

---

### 6. Visual Commit Graph

```bash
git log --oneline --graph --all
```

Displays a concise visual commit history.

---

### 7. Revert Multiple Commits

```bash
git revert HEAD~2..HEAD
```

Reverts the last 3 commits as individual commits without losing history.

---

### 8. Snapshot vs Line-Based Tracking

Git uses **snapshot-based tracking** (not diff/line-based). Each commit stores the entire snapshot with deduplication using SHA-1 hashes.

---

### 9. Merge: `--no-ff` vs `--squash`

* `--no-ff`: Forces a merge commit even if a fast-forward is possible.
* `--squash`: Combines all commits into one but does **not** create a merge commit.

---

### 10. Git Index (Staging Area)

The **index** is a cached snapshot between the working directory and repository.

* `git add`: Moves changes to index
* `git commit`: Saves indexed changes into history

---

### 11. Use of `git pull --rebase`

Fetches remote changes and rebases your local commits on top—used to **maintain linear history**.

---

### 12. Recover Deleted Branch

If you know the last commit hash:

```bash
git checkout -b branch-name <commit-hash>
```

Or find it using:

```bash
git reflog
```

---

### 13. `git worktree` Usage

Allows multiple working directories from one Git repo. Great for testing or parallel development.

---

### 14. Shallow Clone vs Full Clone

* **Shallow Clone**: Uses `--depth` to reduce clone size and history.
* **Full Clone**: Copies the entire history and branches.

---

### 15. Git Hooks + Use Case

Custom scripts triggered on events like `pre-commit`, `post-merge`, etc.

**Example:** Prevent pushing code without passing lint checks.

---

### 16. Risks of `git reset --hard`

It **permanently deletes local changes**.
Recovery only possible if commits are in `reflog`.

---

### 17. Merging Unrelated Histories

```bash
git merge other-branch --allow-unrelated-histories
```

Used when combining repos or starting history from scratch.

---

### 18. `git rebase -i` and When Not to Use

Used to **reorder, squash, or edit commits** interactively.
⚠️ **Do not use** on public/shared branches—can corrupt team history.

---

### 19. Tracked vs Untracked vs Modified vs Staged

* **Untracked**: New files not added to Git
* **Tracked**: Files under Git’s control
* **Modified**: Changes made but not staged
* **Staged**: Changes added to index, ready for commit

---

### 20. How Git Identifies Duplicate Files

Git uses **SHA-1 hashes** for file content. Identical files (even with different names) get the same hash.

---

### 21. Submodules vs Subtrees

* **Submodules**: Link to external Git repo, managed separately
* **Subtrees**: Merge entire project inside repo, easier but less modular

---

### 22. `reflog` vs `git log`

* `git log`: Shows commit history
* `git reflog`: Shows **HEAD changes**, helps in recovering lost commits

---

### 23. Move a Commit Between Branches

```bash
git checkout new-branch
git cherry-pick <commit-hash>
```

---

### 24. Git Object Model

Git stores four object types:

* **Blob**: File content
* **Tree**: Directory snapshot
* **Commit**: Snapshot metadata
* **Tag**: Reference pointer with annotation

---

### 25. Effect of `git push --force`

Overwrites remote history.
⚠️ Can **break others' work** — instead, use:

```bash
git push --force-with-lease
```

---
