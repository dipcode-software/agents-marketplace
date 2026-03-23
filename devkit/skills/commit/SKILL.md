---
name: git-create-commit
version: 1.0.0
description: >
  This skill should be used when the user wants to commit changes to git —
  including requests like "commit my changes", "make a commit", "create a git
  commit", "commit this", "save my work to git", or any variation of "git commit".
  It also applies when the user says "save this", "write a commit message",
  "prepare a commit", or "checkpoint my work" and the intended output is a git
  commit. It enforces Conventional Commits format, includes issue key references
  when available, and prevents commits to protected branches (dev, main, master,
  release/*) by creating a working branch first.
---

# Git Create Commit

Create a short, focused commit message and commit staged changes using
Conventional Commits format.

## Git Conventions

- **Branch naming:** `<prefix>/<short-kebab>` (e.g., `feat/token-refresh`, `fix/auth-loop`)
- **Commit format:** `<type>(<scope>): <summary>` — Conventional Commits

## Steps

1. **Check current branch**
   - Run `git branch --show-current` to get the current branch name
   - If the branch is `dev`, `main`, `master`, or matches `release/*`,
     **do NOT commit directly** — proceed to step 2
   - If already on a feature/fix/... branch (e.g., `feat/...`, `fix/...`,
     `refactor/...`, `chore/...`, `docs/...`, `test/...`, `perf/...`),
     skip to step 3

2. **Create a working branch (if on a protected branch)**
   - Inform the user that the current branch is protected and a new working
     branch will be created
   - Review the staged/unstaged changes to determine the appropriate branch
     prefix (`feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `perf`)
   - Ask the user for the branch name if intent is unclear
   - Create and switch to the new branch:
     `git checkout -b <prefix>/<short-kebab>`

3. **Review changes**
   - Run `git diff --cached` for staged changes, or `git diff` if unstaged
   - Understand what changed and why before writing the message

4. **Resolve issue key**
   - Look for a key in the branch name (e.g., `POW-123`, `PROJ-456`, `#123`)
   - If none is found in the branch name, check the conversation context
     for any referenced tickets or issues
   - If a key is found, it **must** be included in the commit message
   - If no key is found from either source, proceed without one — do not
     prompt the user for an issue key

5. **Stage changes (if not already staged)**
   - If the user has already staged specific files, respect that selection
   - Otherwise, run `git add -A` and briefly describe what will be staged

6. **Write and run the commit**
   - Base the message on the actual diff, not assumptions
   - Keep the subject line ≤ 72 characters
   - Use imperative mood: "fix", "add", "update" — not "fixed", "added"
   - Capitalize the first word; no trailing period
   - For complex changes, add a body after a blank line explaining the
     motivation and context; wrap body lines at 72 characters

## Commit Template

```
<type>(<scope>): <Short summary>
```

With issue key (use `#` for GitHub issues, bare key for Jira-style trackers):

```
<type>(<scope>): <Short summary> #<github-issue>
<type>(<scope>): <Short summary> <JIRA-KEY>
```

### Examples

```
fix(auth): Handle expired token refresh
```

```
feat(payments): Add retry logic for failed charges #123
```

```
feat(payments): Add retry logic for failed charges PROJ-123
```

## Common `type` Values

| Type       | When to use                                      |
|------------|--------------------------------------------------|
| `feat`     | New feature or capability                        |
| `fix`      | Bug fix                                          |
| `refactor` | Code change that neither fixes a bug nor adds a feature |
| `docs`     | Documentation only                               |
| `test`     | Adding or updating tests                         |
| `chore`    | Tooling, config, dependencies                    |
| `perf`     | Performance improvement                          |
