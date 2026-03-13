# Agents Marketplace

A marketplace of plugins for AI-powered coding assistants — compatible with **Cursor** and **Claude Code**.

Each folder in this repository is a self-contained plugin that can be installed into your editor to extend its capabilities with custom skills, hooks, agents, and commands.

## Available Plugins

| Plugin | Description |
|--------|-------------|
| [devkit](devkit/) | Dipcode developer toolkit — git commit conventions and GitLab MR comment utilities |

## Installation

### Claude Code

Add and install from the marketplace:

```shell
# Add the marketplace
/plugin marketplace add git@git.eurotux.com:dipops/tools/agents-marketplace.git

# Install a plugin
/plugin install devkit@dipcode-marketplace
```

To auto-suggest the marketplace for your team, add to `.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "dipcode-marketplace": {
      "source": {
        "source": "url",
        "url": "git@git.eurotux.com:dipops/tools/agents-marketplace.git"
      }
    }
  }
}
```

### Cursor

To add this as a team marketplace:

1. Navigate to **Dashboard → Settings → Plugins**
2. In the **Team Marketplaces** section, select **Import**
3. Enter the repository URL and proceed
4. Review the parsed plugins and optionally configure Team Access groups
5. Enter the marketplace name and description, then save

Once imported, plugins can be installed directly from the marketplace panel, scoped to individual projects or system-wide.

## Plugin Prerequisites

### devkit — gitlab-mr-comments

The `gitlab-mr-comments` skill requires the following tools to be installed and available in your `PATH`:

- **[python-gitlab](https://python-gitlab.readthedocs.io/)** — GitLab CLI (`gitlab` command):

  ```shell
  pip install python-gitlab
  ```

  Configure it via `~/.python-gitlab.cfg` or environment variables. See the [python-gitlab authentication docs](https://python-gitlab.readthedocs.io/en/stable/gl_objects/users.html) for details.

- **[jq](https://jqlang.org/)** — JSON processor used to normalize the API output:

  ```shell
  # macOS
  brew install jq

  # Debian/Ubuntu
  apt install jq
  ```

## Contributing

To add a new plugin, create a folder at the repository root containing:

- `.claude-plugin/plugin.json` — Plugin manifest for Claude Code
- `.cursor-plugin/plugin.json` — Plugin manifest for Cursor (optional)
- `skills/` — Skill definitions (markdown files with YAML frontmatter)
- `hooks/` — Event-driven hooks (optional)
- `agents/` — Autonomous agents (optional)
- `commands/` — Slash commands (optional)

Then register it in both marketplace files:

`.claude-plugin/marketplace.json`:
```json
{
  "name": "my-plugin",
  "source": "./my-plugin",
  "description": "What the plugin does"
}
```

`.cursor-plugin/marketplace.json`:
```json
{
  "name": "my-plugin",
  "source": "my-plugin",
  "description": "What the plugin does"
}
```

Note: Claude Code uses `./` prefixed relative paths, Cursor uses bare directory names.

Each plugin should be independent and self-contained. Plugins cannot reference files outside their own directory.
