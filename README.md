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

**Public marketplace** — if published to [cursor.com/marketplace/publish](https://cursor.com/marketplace/publish), users can install plugins directly from Cursor's built-in marketplace UI.

**Private/team use** — clone the repo and symlink the plugin into your project:

```bash
git clone git@git.eurotux.com:dipops/tools/agents-marketplace.git
ln -s /absolute/path/to/agents-marketplace/devkit /your/project/.cursor/plugins/devkit
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
