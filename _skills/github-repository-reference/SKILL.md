---
name: github-repository-reference
description: Inspect files from GitHub repositories by cloning the repository to a temporary local directory and working from that copy. Use when a task references a GitHub repository, file, or source tree that is not already available locally.
---

# GitHub Repository Reference

When a task asks you to inspect files in a GitHub repository, try to clone the repository into a unique directory under `/tmp` and work from the local copy. Local files are usually faster and easier to search and inspect than browsing individual GitHub file pages.

## Workflow

1. Identify the repository URL from the link. For a URL such as `https://github.com/OWNER/REPO/blob/BRANCH/path/to/file`, the repository is `https://github.com/OWNER/REPO.git`; the branch and file path identify what to inspect after cloning.
2. Create a unique temporary destination under `/tmp` so you do not overwrite another task's files. Use a shallow clone when full history is unnecessary.
3. Inspect and search the relevant files locally. If the link names a branch, tag, or commit, use that revision rather than assuming the default branch contains the referenced file.
4. Keep the clone temporary. Do not modify, commit, or push changes to the referenced repository unless the user explicitly asks.
5. If cloning fails or is unavailable, explain the limitation and use the best available fallback, such as the GitHub page or raw file URL.

Do not clone repositories when the relevant source is already present in the current workspace or when the user explicitly requests a different inspection method.
