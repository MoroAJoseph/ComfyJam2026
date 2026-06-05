# ComfyJam2026

Welcome to the **ComfyJam2026** repository! This document contains everything
you need to get set up, manage your files, and collaborate effectively with the
team.

---

## Table of Contents

1. [I. Quick Start](#i-quick-start)
2. [II. Git & GitHub Reference](#ii-git--github-reference)
3. [III. The Workflow: Branching & Merging](#iii-the-workflow-branching--merging)
4. [IV. File Management & Rules](#iv-file-management--rules)
5. [V. Learning Resources](#v-learning-resources)
6. [VI. Best Practices & Team Etiquette](#vi-best-practices--team-etiquette)
7. [VII. Try It Yourself!](#vii-try-it-yourself!)

## Repository Structure

```bash
ComfyJam2026/
├── .git/               # Git tracking (do not edit)
├── .ignore/            # Personal WIP, junk files, & local tests
├── dev_sandbox/        # Personal folders for each developer
├── game/               # Main Godot Project
│   ├── project.godot
│   └── res/            # Source code, assets, and game files
└── dist/               # Game builds (exported files)
```

---

## I. Quick Start

_If you are new to Git/GitHub, start here to get your environment ready._

### A. Prerequisites

- **Install Git:** [Download here](https://git-scm.com/)
- **Install Git LFS:** [Download here](https://git-lfs.com/)

### B. Initial Setup

Open your terminal or command prompt and run these commands once:

> **Note:** When using the terminal, use these keys to copy/paste:
>
> - **Copy:** `ctrl` + `shift` + `c`
> - **Paste:** `ctrl` + `shift` + `v`

```bash
# Install Git LFS to your machine
git lfs install

# Copy the project files to your local machine
git clone https://github.com/MoroAJoseph/ComfyJam2026

# Change Directory to the project directory
cd ComfyJam2026

# Ensure all Large Files (art/audio) are downloaded
git lfs pull
```

---

## II. Git & GitHub Reference

_Understand the environment we are working in._

- **Repository (Repo):** The project folder stored online on GitHub.
- **Branch:** A separate version of the project. We use:
    - `main`: The stable, finished game. (Do not work here).
    - `development`: The current active workspace.
    - `feature/name`: Your personal sandbox for specific tasks.
- **Commit:** A local "save point" for your project.
- **Push:** Uploading your local commits to GitHub.
- **Pull:** Downloading changes from GitHub to your computer.

---

## III. The Workflow: Branching & Merging

### A. How to Start a Task

Before you start any work, always update and branch off from `development`:

```bash
# Change to the development branch
git checkout development

# Pull the latest code AND latest LFS assets
git pull origin development
git lfs pull

# Creates a new branch off of the current (development) branch
git checkout -b feature/your-task-name
```

### B. How to Save Your Work

```bash
# Stage changes locally
git add .

# Commit changes locally
git commit -m "Brief title" -m "Brief description of what you did"

# Commit your changes to the remote repo
git push origin feature/your-task-name
```

> Note: Always push your branch to GitHub even if you aren't done yet—it acts as
> a cloud backup for your work.

### C. How to Merge to Development

_Once your task is finished and tested:_

```bash
# Change to the development branch
git checkout development

# Pull the latest code AND latest LFS assets
git pull origin development
git lfs pull

# Merge your work into the current (development) branch
git merge feature/your-task-name

# Commit your changes to the remote repo
git push origin development
```

---

## IV. File Management & Rules

### The `/ignore` Folder

If you have work-in-progress files or personal tests that you don't want to
clutter the game project with, move them into the `/ignore` folder. This folder
is ignored by Git and will not be pushed.

### Naming Conventions

- **No spaces:** Use `snake_case` (e.g., `player_character.png` instead of
  `Player Character.png`).
- **Consistency:** Use lowercase for all file names.
- **Descriptive:** Name files based on what they are (e.g., `grass_tile_01.png`,
  `main_theme_v2.wav`).

### Communication

- **Discord:** Before editing a major scene file, post in our Discord channel:
  _"I am working on [filename]"_ This prevents two people from editing the same
  file at once.

---

## V. Learning Resources

_Visual guides to help you master these tools._

- **Git Branching Explained:**
  [https://www.youtube.com/watch?v=9gaTargV5BY](https://www.youtube.com/watch?v=9gaTargV5BY)
- **What is Git LFS?:**
  [https://www.youtube.com/watch?v=QV0kVNvkMxc](https://www.youtube.com/watch?v=QV0kVNvkMxc)
- **How to Resolve Merge Conflicts:**
  [https://www.youtube.com/watch?v=DloR0BOGNU0](https://www.youtube.com/watch?v=DloR0BOGNU0)

> **Note:** If you run into any "rejected" messages or errors, don't panic!
> Stop, ask for help in our Discord, and do not force anything until we look at
> it together.

## VI. Best Practices & Team Etiquette

To keep our collaboration smooth and stress-free, please follow these
guidelines:

- **Always Pull First:** Before you create a new branch or start a task, always
  `pull` the latest changes from `development`. This ensures you are building on
  top of the most recent version of the game.

- **Keep Commits Frequent & Focused:** Don't wait until you've finished a
  massive feature to `commit`. Save your work with small, frequent commits. This
  makes it much easier to "undo" changes if something breaks.

- **Push Often:** If others depend on your work (e.g., your code is needed for a
  shader the artist is making), `push` your branch to GitHub frequently so the
  team can see your progress.

- **Clean Up Before You Merge:** Before you ask to merge into `development`,
  ensure your project is clean. Delete (or `/ignore`) any test scenes or
  temporary assets that aren't part of the final feature.

- **Use the `/ignore` Folder:** If you have personal experiments, "messy" WIP
  art, or high-poly source files that don't need to be in the final game build,
  keep them in your personal folder within `/ignore`. This keeps the main
  project folder professional and lightweight.

- **Don't "Force" Anything:** If you see an error message (especially about
  "rejected" pushes or "merge conflicts"), do not use commands that force
  changes (like `--force`). Stop, and ask for help in Discord. We can fix it
  together!

- **The "One-at-a-Time" Rule:** Scene files (`.tscn`) and Resource files
  (`.tres`) are difficult for Git to merge. If you know you are going to be
  working on a major scene for an hour or more, let the team know in Discord to
  avoid overlapping work.

- **Use the Godot FileSystem:** Never move, rename, or delete files from your
  computer's file explorer. Always perform these actions inside the
  `Godot FileSystem` dock. Godot needs to track these changes to keep your scene
  dependencies from breaking.

---

# VII. Try It Yourself!

> **Note**: Replace [your_name] with your actual name

## Clone

```bash
# Clone the repository to your machine
git clone https://github.com/MoroAJoseph/ComfyJam2026

# Enter the project folder
cd ComfyJam2026

# Ensure Git LFS is ready
git lfs install
git lfs pull
```

## Sync

```bash
# Move to the development branch
git checkout development

# Fetch the latest changes
git pull origin development
git lfs pull
```

## Create

**Feature Branch**

```bash
# Create and switch to your test branch
git checkout -b feature/test-run-[your_name]

# Create your personal folder
mkdir dev_sandbox/[your_name]
```

**Test File**

```bash
# Create the file and add the confirmation message
echo "I did it!" > dev_sandbox/[your_name]/test.txt
```

## Stage, Commit, and Push

```bash
# Stage the new folder and file
git add .

# Save the changes locally
git commit -m "Test: Added verification file for [your_name]"

# Upload your branch to GitHub
git push origin feature/test-run-[your_name]
```

## Merge

```bash
# Switch back to development
git checkout development

# Merge your test branch
git merge feature/test-run-[your_name]

# Push the updated development branch
git push origin development
```
