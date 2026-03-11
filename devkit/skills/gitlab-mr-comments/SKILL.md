---
name: gitlab-mr-comments
description: This skill should be used when the user asks to "show MR comments", "fetch merge request comments", "list MR notes", "get GitLab MR review comments", "show merge request feedback", "display MR discussions", "what did reviewers say on my MR", "read MR review notes", "summarize MR comments", or mentions viewing, reading, or summarizing comments on a GitLab merge request.
version: 0.1.0
---

# GitLab MR Comments

Fetch and display comments (notes) from a GitLab merge request using the `python-gitlab` CLI (`gitlab` command).

## Prerequisites

- The `gitlab` CLI from the `python-gitlab` package must be installed and configured (via `~/.python-gitlab.cfg` or environment variables).

## Workflow

### Step 1: Identify the Project and MR

Determine the GitLab project ID and merge request IID from one of these sources (in priority order):

1. **Command argument** — the skill may be invoked with a MR URL directly (e.g., `/gitlab-mr-comments https://gitlab.example.com/group/project/-/merge_requests/123`). Parse the URL to extract the project path and MR IID.
2. **User-provided URL or IDs** — if not passed as an argument, check the conversation for a URL or IDs.
3. **Git repository context** — if working within a git repository, derive the project from the remote URL and prompt for the MR IID.

Prompt for input only if none of the above sources provide the necessary information.

To get the remote URL from a local repo:

```bash
git remote get-url origin
```

A GitLab remote URL like `git@gitlab.example.com:group/project.git` or `https://gitlab.example.com/group/project` maps to the project path `group/project`. Use the path with slashes (e.g., `group/project`) as the `--project-id` value, or use the numeric project ID if known.

> **Note:** Use slash-separated paths (e.g., `group/subgroup/project`), **not** URL-encoded paths (e.g., `group%2Fsubgroup%2Fproject`). The `python-gitlab` CLI handles the encoding internally.

If the user provides a full MR URL, extract the project path and MR IID from it. GitLab MR URLs follow this pattern:

```
https://<host>/<group>[/<subgroup>...]/<project>/-/merge_requests/<iid>
```

For example, from `https://gitlab.example.com/team/backend/api-server/-/merge_requests/42`:
- Project path: `team/backend/api-server`
- MR IID: `42`

If the MR IID is not provided, list open MRs:

```bash
gitlab -o json -f iid,title,author project-merge-request list --project-id <project-id> --state opened
```

### Step 2: Fetch and Normalize MR Notes

Run the bundled script. It fetches notes, filters out system notes, and normalizes the output into a clean JSON structure:

```bash
bash "skills/gitlab-mr-comments/scripts/fetch-mr-notes.sh" <project-id> <mr-iid>
```

To include system notes, pass `--all`:

```bash
bash "skills/gitlab-mr-comments/scripts/fetch-mr-notes.sh" <project-id> <mr-iid> --all
```

The script outputs a normalized JSON array:

```json
[
  {
    "discussion_id": "abcdef1234567890",
    "author": "jdoe",
    "date": "2024-03-10",
    "body": "Comment text here",
    "file": "src/auth/token.py",
    "line_start": 42,
    "line_end": 44,
    "line_type": "new",
    "base_sha": "abc123",
    "head_sha": "def456",
    "resolved": false,
    "type": "diff"
  }
]
```

| Field           | Description                                                    |
|----------------|----------------------------------------------------------------|
| `discussion_id`| Unique ID grouping notes in the same discussion thread (null for standalone notes) |
| `author`       | GitLab username                                                |
| `date`         | Date in `YYYY-MM-DD` format                                   |
| `body`         | Comment text (may contain markdown)                            |
| `file`         | File path — uses `new_path` for new/context lines, `old_path` for deleted lines (null for general comments) |
| `line_start`   | Start line of the comment (null for general comments)          |
| `line_end`     | End line of the comment — differs from `line_start` for multiline selections (null for general comments) |
| `line_type`    | Which side of the diff the line numbers refer to: `"new"` (line exists in the current version), `"old"` (line only existed before the MR changes), or `null` (general/file-level comment) |
| `base_sha`     | Commit SHA of the base (pre-MR) version the diff was computed against (null for non-diff comments) |
| `head_sha`     | Commit SHA of the head (MR branch) version the diff was computed against (null for non-diff comments) |
| `resolved`     | Whether the comment has been resolved (null if not resolvable) |
| `type`         | `"comment"` for general, `"diff"` for inline code, `"system"` (only with `--all`) |

#### Understanding diff positions

Review comments are left on a diff view, so `line_start`/`line_end` refer to line numbers in a specific version of the file:

- **`line_type: "new"`** — the comment targets an added or unchanged line. The line numbers refer to the current (head) version of the file and can be read directly.
- **`line_type: "old"`** — the comment targets a deleted line that no longer exists in the current version. The line numbers refer to the base (pre-MR) version.

To inspect the exact diff context a reviewer was commenting on:

```bash
git diff <base_sha>..<head_sha> -- <file>
```

This shows both old and new versions of the code, making it possible to locate the precise position of any comment regardless of `line_type`. Use this to understand the full context around a review comment — what was changed, what was removed, and what was added.

### Step 3: Format Output

Output ONLY the formatted comments with no additional explanatory text.

Format as:

```
## MR Comments

- @author (2024-01-15):
  > Comment text here

  - @replier (2024-01-15):
    > Reply text here

- @reviewer (2024-01-16) `file.py#L42-L44`:
  > Code review comment text

- @reviewer (2024-01-16) `file.py#L18` [resolved]:
  > Resolved code review comment

- @reviewer (2024-01-17) `old_file.py#L15-L20 (old)`:
  > Comment on deleted lines
```

**Formatting rules:**
- Group threaded discussions together using `discussion_id` — notes sharing the same `discussion_id` belong to the same thread. The first note is the parent; subsequent notes are replies.
- Show the file path when available for code review comments
- Indent replies under their parent
- Include the date in short format
- Use blockquote (`>`) for comment body text
- Mark resolved comments with `[resolved]` after the file/line reference (e.g., `@reviewer file.py#L18 [resolved]:`)
- When `line_type` is `"old"`, append `(old)` to the line reference (e.g., `` `file.py#L15-L20 (old)` ``) to indicate the lines refer to deleted code that no longer exists in the current version
- For very long comments (automated reviews, large descriptions, etc.), summarize the key points instead of reproducing the full text verbatim. Keep the summary concise and structured (e.g., bullet points for findings).
- If no comments exist, return "No comments found."

## Examples

For a concrete input/output example, see:
- **`examples/sample-notes.json`** — Representative normalized JSON output from `fetch-mr-notes.sh` (includes discussion threads, resolved notes, and old/new line types)
- **`examples/expected-output.md`** — The formatted markdown output expected from the sample input

