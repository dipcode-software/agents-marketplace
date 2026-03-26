# devkit

Dipcode developer toolkit — a plugin for Claude Code and Cursor that provides skills for git commit conventions, GitLab MR review, RT ticket triage, and dependency validation.

## Skills

| Skill | Description |
|-------|-------------|
| [git-create-commit](skills/commit/SKILL.md) | Create git commits using Conventional Commits format with branch protection |
| [gitlab-mr-comments](skills/gitlab-mr-comments/SKILL.md) | Fetch and display comments from GitLab merge requests |
| [rt-triage](skills/rt-triage/SKILL.md) | Triage RT queue tickets against a codebase to identify code-related issues |
| [validate-dependency](skills/validate-dependency/SKILL.md) | Evaluate third-party packages for trustworthiness and license compliance |

## Prerequisites

### git-create-commit

No additional setup required — uses the standard `git` CLI available in any repository.

### gitlab-mr-comments

Requires two CLI tools:

- **[python-gitlab](https://python-gitlab.readthedocs.io/)** — GitLab CLI (`gitlab` command):

  ```shell
  pip install python-gitlab
  ```

  Configure authentication via `~/.python-gitlab.cfg` or environment variables. See the [python-gitlab docs](https://python-gitlab.readthedocs.io/en/stable/cli-usage.html#configuration) for details.

- **[jq](https://jqlang.org/)** — JSON processor:

  ```shell
  # macOS
  brew install jq

  # Debian/Ubuntu
  apt install jq
  ```

### rt-triage

Requires the [RT MCP server](https://github.com/bestpractical/mcp-server-rt) to be configured in your environment.

### validate-dependency

No additional setup required — uses web search to query package registries (PyPI, npm, crates.io, etc.), CVE databases, and source repositories.