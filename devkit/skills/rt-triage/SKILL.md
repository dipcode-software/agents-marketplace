---
name: rt-triage
version: 0.1.0
description: >
  This skill should be used when the user asks to "triage RT tickets", "triage
  the queue", "RT triage", "check RT queue", "find actionable tickets", "what
  tickets need attention", "which tickets are code-related", "review the support
  queue", "what tickets are waiting on us", "triage my tickets", "triage tickets
  owned by X", or mentions triaging, reviewing, or analyzing tickets from a
  Request Tracker (RT) queue against a codebase.
---

# RT Ticket Triage

Analyze tickets from a Request Tracker (RT) queue to identify which open/new tickets — where the last reply is from the client — are directly related to the current codebase and could be resolved through code changes or inspection.

## Arguments

`$ARGUMENTS` is parsed as positional and named parts:

- **Queue name** (required, first positional token) — the RT queue to triage. If missing, report that no queue was specified and stop.
- **`owner=<name>`** (optional) — restrict results to tickets owned by a specific user. When set to `me`, resolve to the current user via `rt_get_current_user`. When omitted, no owner filter is applied. Natural language like "my tickets" or "triage my queue" should be interpreted as `owner=me`.

Examples: `General`, `General owner=john`, `General owner=me`.

## Prerequisites

- The RT MCP server must be configured (tools prefixed with `rt_`). The server's instructions provide the RT web UI base URL (`{rt_web_url}`) used to build ticket links in the report.
- Run this skill from the working directory of the repository to triage against.

## Workflow

### Step 1: Fetch open/new tickets

Parse `$ARGUMENTS` to extract the queue name and the optional `owner=<name>` parameter.

Call `rt_get_current_user` to obtain the current username — needed to identify staff correspondence in Step 2.

- If `owner=me` was specified, this call must complete **before** the search so the resolved username can be included in the query. Do not parallelize in this case.
- Otherwise, run `rt_get_current_user` in parallel with `rt_search_tickets`.

Search for actionable tickets using `rt_search_tickets`:

```
Queue = '{queue}' AND (Status = 'new' OR Status = 'open')
```

If an owner was specified, append `AND Owner = '{owner}'` to the query (with `me` already resolved to the actual username).

Request `fields=Subject,Status,Queue,Owner,Requestor,Priority,LastUpdated,Due` and `subfields={"Queue":"Name","Owner":"Name"}`.

If no tickets are returned and the queue is known to have active tickets, the RT instance may use a custom lifecycle with different status names. In that case, broaden the query to `Status != 'resolved' AND Status != 'rejected'` and retry.

If still no tickets are returned, report that there are no actionable tickets in queue `{queue}` and stop. If an owner filter was applied, mention it in the message so the user knows the filter may be narrowing results to zero.

### Step 2: Filter to tickets awaiting action

For each ticket, retrieve correspondence history with `rt_get_ticket_history`. **Always include `fields=Type,Creator,Created`** to get transaction metadata in a single call — omitting fields forces a wasteful second round-trip.

Issue all history calls in parallel.

A ticket **needs action** when:
- It has **no correspondence transactions** (newly created, no replies yet) — the initial request is from the client.
- The **most recent "Correspond" transaction** was sent by the client (requestor or external party), not by staff.

Determine this by:

1. Inspecting the transaction history for the ticket.
2. If no "Correspond" transactions exist, treat the ticket as needing action.
3. Otherwise, find the last "Correspond" transaction and compare its creator against the ticket's Requestor.
4. Skip tickets where the last correspondence is from staff — those await client response.

Collect only the filtered tickets that need action. Do not begin fetching transaction content yet — Step 3 applies an additional filter first.

### Step 3: Pre-classify by subject; fetch content for remaining tickets

Before fetching full ticket content, classify tickets by subject line alone. Tickets that are obviously **Not Code-Related** from the subject (access requests, GitLab/VPN accounts, infrastructure, documentation updates) should be classified immediately without fetching transaction content or searching the codebase. This avoids wasting tokens on irrelevant tickets.

Since subject classification requires no tool calls, execute both tasks in a single turn: classify subjects locally, then immediately issue `rt_get_transaction` calls (creation transaction + last correspondence) for tickets that pass the filter. Issue all calls in parallel.

**Handle large attachments**: When an MCP tool result exceeds the context window, the framework writes it to a temporary file and returns the file path instead. RT tickets often trigger this due to inline screenshots encoded as base64 images. To extract only the text content from an overflow file, use Bash:
```bash
# .[0].text is a JSON-encoded string containing the full transaction object;
# the second jq parses that string to extract only the HTML attachment content.
jq -r '.[0].text' <overflow_file> | jq -r '.Attachments[] | select(.ContentType == "text/html") | .Content'
```
If the HTML itself is still too large (embedded base64 images), pipe through `sed 's/<img[^>]*>//g'` to strip image tags before reading.

### Step 4: Analyze tickets against the codebase using subagents

Spawn one **Explore** subagent per ticket to search the codebase in parallel. This keeps search results out of the main context and allows each ticket's analysis to proceed independently with multiple search rounds.

**When to use subagents:** Always use subagents when 3 or more tickets need codebase analysis. For 1-2 tickets, use direct Grep/Glob calls instead.

**Subagent prompt template** — provide each agent with:

```
Analyze RT ticket #{id} ("{subject}") against this codebase to classify it.

Ticket content:
{conversation_summary — stripped of base64/images}

Classification categories:
- Code Fix: bug or error likely fixable by modifying code in this repository
- Code Investigation: requires inspecting code to diagnose or understand behavior
- Not Code-Related: infrastructure, access, documentation, third-party services
- Unclear: not enough information to determine relevance

Search strategy:
- Extract key terms: error messages, feature names, module names, URLs, API endpoints, model/class names, function names.
- Use Grep and Glob to search the working directory.
- Look for references to specific files, views, templates, or configuration mentioned in the ticket.
- Cast a wide net first, then narrow down. Try multiple search strategies if the first yields no results.
- When uncertain between Code Fix and Code Investigation, prefer Code Investigation.

Return EXACTLY this format:
Category: {category}
Summary: {one-line summary referencing specific files/modules found}
Relevant files: {comma-separated list of key files, or "none"}
```

Launch all subagents in a **single message** so they run concurrently. Set thoroughness to "medium" (controls how many search rounds each subagent attempts before returning).

### Step 5: Produce the triage report

Collect subagent results and combine with any tickets pre-classified in Step 3. Present results in this format (ticket IDs must link to the RT web UI):

```
RT Triage Report — Queue: `{queue_name}`
Owner filter: {owner_name or "all"}
Repository: {current working directory}
Date: {YYYY-MM-DD}
Tickets analyzed: {count} | Actionable (code-related): {count}

## Code Fix
- [#{id}]({rt_web_url}/Ticket/Display.html?id={id}): {subject} — {one-line summary referencing specific files/modules found}

## Code Investigation
- [#{id}]({rt_web_url}/Ticket/Display.html?id={id}): {subject} — {one-line summary of what to investigate and where}

## Not Code-Related
- [#{id}]({rt_web_url}/Ticket/Display.html?id={id}): {subject} — {brief reason}

## Unclear
- [#{id}]({rt_web_url}/Ticket/Display.html?id={id}): {subject} — {what information is missing}
```

Omit empty categories from the report.

## Efficiency Guidelines

- **Maximize parallelism**: All independent tool calls (history fetches, transaction reads, subagent launches) must be issued in the same response. Never serialize calls that have no data dependency.
- **Minimize round-trips**: The target is 3-4 human turns total: fetch+filter → pre-classify+fetch content → spawn subagents → assemble report. Each turn should pack as many parallel calls as possible.
- **Avoid re-fetching**: Never call `get_ticket_history` without `fields=Type,Creator,Created`. Never call `get_transaction` for tickets already classified as Not Code-Related.
- **Delegate codebase exploration**: Use Explore subagents (one per ticket) for codebase analysis. This keeps search results out of the main context and enables true parallel multi-round exploration. For 1-2 tickets, direct Grep/Glob in the main context is acceptable.

## Example Output

For a complete sample report, see **`examples/sample-report.md`**.

## Constraints

- **Read-only**: Do not modify any tickets in RT. Do not create comments or replies.
- **No code changes**: Only analyze and report. Do not edit any files.
- **Conservative classification**: When in doubt, prefer less assertive categories.
