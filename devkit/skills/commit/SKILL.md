---
name: git-create-commit
version: 1.0.0
description: >
  This skill should be used when the user wants to commit changes to git —
  including requests like "commit my changes", "make a commit", "create a git
  commit", "commit this", "save my work to git", or any variation of "git commit".
  It enforces Conventional Commits format and supports optional Linear/Jira/GitHub 
  issue key prefixes. Use this skill whenever a git commit is the desired output, 
  even if the user just says "save this" or "checkpoint my work".
---

# Git Create Commit

Create a short, focused commit message and commit staged changes using
Conventional Commits format.

## Git Conventions

- **Branch naming:** `<prefix>/<short-kebab>` (e.g., `feat/token-refresh`, `fix/auth-loop`)
- **Commit format:** `<type>(<scope>): <summary>` — Conventional Commits

## Steps

1. **Review changes**
   - Run `git diff --cached` for staged changes, or `git diff` if unstaged
   - Understand what changed and why before writing the message

2. **Check for an issue key (optional)**
   - Look for a key in the branch name (e.g., `POW-123`, `PROJ-456`, `#123`)
   - If none is found and context is unclear, prompt the user — but this is
     optional; commits can be made without one

3. **Stage changes (if not already staged)**
   - `git add -A`

4. **Write and run the commit**
   - Base the message on the actual diff, not assumptions
   - Keep the subject line ≤ 72 characters
   - Use imperative mood: "fix", "add", "update" — not "fixed", "added"
   - Capitalize the first word; no trailing period

## Commit Template

```
<type>(<scope>): <Short summary>
```

With issue key:

```
<type>(<scope>): <Short summary> #<issue-key>
```

### Examples

```
fix(auth): Handle expired token refresh
```

```
feat(payments): Add retry logic for failed charges #PROJ-123
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
