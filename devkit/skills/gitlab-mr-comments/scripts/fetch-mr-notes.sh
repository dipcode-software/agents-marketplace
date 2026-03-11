#!/usr/bin/env bash
# Fetch and normalize merge request notes from GitLab.
# Usage: fetch-mr-notes.sh <project-id> <mr-iid> [--all]
#
# Outputs a normalized JSON array ready for formatting:
#   [{ discussion_id, author, date, body, file, line_start, line_end, line_type, base_sha, head_sha, resolved, type }]
#
# By default, filters out system-generated notes.
# Pass --all to include system notes.
#
# Requires: python-gitlab CLI, jq

set -euo pipefail

PROJECT_ID="${1:?Usage: fetch-mr-notes.sh <project-id> <mr-iid> [--all]}"
MR_IID="${2:?Usage: fetch-mr-notes.sh <project-id> <mr-iid> [--all]}"
INCLUDE_ALL="${3:-}"

RAW=$(gitlab -o json project-merge-request-note list \
  --project-id "$PROJECT_ID" \
  --mr-iid "$MR_IID" \
  --get-all)

FILTER='if .system then "system" elif .type == "DiffNote" then "diff" else "comment" end'

NORMALIZE='[.[] |
  # Determine which side of the diff the comment targets
  (if .position then
    (if .position.line_range then
      (if .position.line_range.start.type == "old" then "old" else "new" end)
    elif .position.new_line then "new"
    elif .position.old_line then "old"
    else null end)
  else null end) as $lt |
{
  discussion_id: (.discussion_id // null),
  author: .author.username,
  date: (.created_at | split("T")[0]),
  body: .body,
  file: (if .position then
    (if $lt == "old" then (.position.old_path // .position.new_path)
    else (.position.new_path // .position.old_path) end)
  else null end),
  line_start: (if .position then
    (if .position.line_range then
      (if $lt == "old" then .position.line_range.start.old_line
      else .position.line_range.start.new_line end)
    else
      (if $lt == "old" then .position.old_line else .position.new_line end)
    end)
  else null end),
  line_end: (if .position then
    (if .position.line_range then
      (if $lt == "old" then .position.line_range.end.old_line
      else .position.line_range.end.new_line end)
    else
      (if $lt == "old" then .position.old_line else .position.new_line end)
    end)
  else null end),
  line_type: $lt,
  base_sha: (if .position then .position.base_sha else null end),
  head_sha: (if .position then .position.head_sha else null end),
  resolved: .resolved,
  type: ('"$FILTER"')
}]'

if [ "$INCLUDE_ALL" = "--all" ]; then
  echo "$RAW" | jq "$NORMALIZE"
else
  echo "$RAW" | jq "[.[] | select(.system == false)]" | jq "$NORMALIZE"
fi
