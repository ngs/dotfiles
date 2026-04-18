---
name: address-review
description: Address code review comments from Copilot and other bots on the current branch's PR. Implements fixes if needed, commits, pushes, and replies to each comment.
---

# Address Bot Code Review Comments

Review code review comments from Copilot and other automated reviewers on the current branch's PR. Implement fixes if needed, then reply to each comment.

## Arguments (Optional)

- `<pr-number>` - PR number (default: current branch's PR)
- `--all` - Address all review comments, not just bot comments
- `--loop` - After addressing comments and pushing, automatically request Copilot re-review, wait for new comments, and repeat until zero actionable comments remain (max 10 iterations)

Examples:
- `/address-review` - Address bot review comments on current branch's PR
- `/address-review 42` - Address bot review comments on PR #42
- `/address-review --all` - Address all review comments including human ones
- `/address-review --loop` - Address comments and loop until Copilot is satisfied

## Instructions

### Step 1: Parse Arguments & Identify PR

```bash
git branch --show-current
```

If a PR number was provided, use it. Otherwise detect the PR for the current branch:

```bash
gh pr view --json number,url,headRefName,baseRefName
```

If no PR exists, inform the user and exit.

### Step 2: Fetch Review Comments

Fetch all review comments on the PR. There are two types to check:

**Inline review comments (pull request review comments):**
```bash
gh api repos/{owner}/{repo}/pulls/{pr_number}/comments --paginate
```

**PR-level review bodies (from `gh pr view`):**
```bash
gh api repos/{owner}/{repo}/pulls/{pr_number}/reviews --paginate
```

Get the repo owner/name:
```bash
gh repo view --json nameWithOwner -q .nameWithOwner
```

### jq caveats

**In zsh, `!=` gets escaped to `\!=`, causing jq parse errors.** Always use the `| not` pattern instead of `!=`:

```bash
# ❌ BAD — breaks in zsh
jq 'select(.body != null and .body != "")'

# ✅ GOOD — safe in zsh
jq 'select(.body | (. == null or . == "") | not)'
```

### Unreplied comment detection

**Never hardcode or cache the replied-ID list.** Every time you need to determine which comments are unreplied, re-fetch all comments at that point and dynamically build the replied-ID list. Reusing a stale list from a previous fetch will miss comments added in the meantime.

Concrete steps:
```bash
# ✅ Always run these two steps together to get unreplied comments
REPLIED=$(gh api repos/{owner}/{repo}/pulls/{pr_number}/comments --paginate | \
  jq '[.[] | select(.in_reply_to_id | . == null | not) | .in_reply_to_id] | unique')

gh api repos/{owner}/{repo}/pulls/{pr_number}/comments --paginate | \
  jq --argjson replied "$REPLIED" \
  '[.[] | select(.in_reply_to_id == null) | select(.id as $id | $replied | index($id) | . == null) | ...]'
```

- Re-fetch at Step 3 (filtering) and again before Step 7 (replying)
- Especially after a push, bots may post additional review comments — always re-fetch

### Step 3: Filter Bot Comments

Unless `--all` is specified, filter comments to only those from automated reviewers:
- `copilot[bot]`
- `github-actions[bot]`
- `coderabbitai[bot]`
- `github-advanced-security[bot]`
- Any user whose login ends with `[bot]`

Exclude comments that:
- Have already been resolved
- Are replies to other comments (unless they contain actionable suggestions)
- Are purely informational with no actionable suggestion

### Step 4: Categorize Each Comment

For each filtered comment, categorize it:

1. **Actionable** — The comment suggests a concrete code change (bug fix, improvement, security issue, style fix, etc.)
2. **Non-actionable** — The comment is informational, a question, praise, or not applicable

Present the categorized list to the user in this format:

```
## Review Comments Found

### Actionable (requires changes)
1. [file:line] <summary of suggestion> — by <reviewer>
2. [file:line] <summary of suggestion> — by <reviewer>

### Non-actionable (informational / no changes needed)
1. [file:line] <summary> — by <reviewer>
```

If there are NO actionable comments, inform the user and ask if they want to reply to non-actionable comments with an acknowledgment. If the user confirms, go to Step 7 (reply only). If not, exit.

If there ARE actionable comments, ask the user for confirmation before proceeding with implementation.

### Step 5: Implement Fixes

For each actionable comment:

1. Read the relevant file and understand the context around the commented line(s)
2. Understand the suggestion from the review comment
3. Implement the fix
4. Verify the fix doesn't break surrounding code

After implementing all fixes, present a summary of changes to the user.

### Step 6: Commit & Push

**First iteration: Commit and push are separate confirmations. Both require explicit user permission.**

First, stage only the files that were modified to address reviews and show the diff:

```bash
git add <modified-files>
git diff --cached --stat
```

Ask the user for permission to **commit**. Only after approval:

```bash
git commit -m "$(cat <<'EOF'
fix: address code review feedback

<bullet list of changes made>
EOF
)"
```

Then, ask the user for permission to **push**. Only after approval:

```bash
git push
```

**In `--loop` mode (iteration 2+):** After the user approved commit & push in the first iteration, subsequent iterations auto-commit and auto-push without re-asking. Always show the diff summary before committing so the user can see what changed.

### Step 7: Reply to Review Comments

For each comment that was addressed, reply with a message that includes:

1. A permalink to the **commit diff** showing the specific fix (not to the blob)
2. A brief description of what was changed

**For actionable comments that were fixed:**

Get the commit SHA of the fix commit:
```bash
git rev-parse HEAD
```

Build a permalink to the commit diff for the specific file. Use the commit page URL with a file anchor so the reviewer can see exactly what changed:

`https://github.com/{owner}/{repo}/commit/{commit_sha}#diff-{sha256_of_file_path}`

To compute the file anchor, use the SHA-256 hash of the file path (this is how GitHub generates diff anchors):
```bash
echo -n "{file_path}" | shasum -a 256 | cut -d' ' -f1
```

The resulting permalink format is:
`https://github.com/{owner}/{repo}/commit/{commit_sha}#diff-{file_path_sha256}`

Reply to the inline comment:
```bash
gh api repos/{owner}/{repo}/pulls/{pr_number}/comments/{comment_id}/replies \
  -f body="$(cat <<'EOF'
Fixed in {commit_sha_short}.

<brief description of the change>

→ [View diff](<permalink_to_commit_diff>)
EOF
)"
```

**For non-actionable comments (if user approved):**

```bash
gh api repos/{owner}/{repo}/pulls/{pr_number}/comments/{comment_id}/replies \
  -f body="Acknowledged — no changes needed."
```

### Step 8: Output

Display a summary:
1. Number of comments addressed
2. Number of comments acknowledged (non-actionable)
3. List of files modified
4. Link to the PR

### Step 9: Loop Mode (`--loop`)

If `--loop` is specified, after completing Step 7 (reply) and Step 8 (summary), continue with the following loop:

#### 9a. Request Copilot re-review

Copilot does **not** automatically re-review after a push. You must explicitly request a re-review using the GitHub API:

```bash
# Request re-review from Copilot
gh api repos/{owner}/{repo}/pulls/{pr_number}/requested_reviewers \
  -X POST -f 'reviewers[]=copilot-pull-request-reviewer[bot]' 2>/dev/null || true
```

If the above fails (some repos use team-based Copilot assignment), try:
```bash
gh pr edit {pr_number} --add-reviewer '@copilot-pull-request-reviewer[bot]' 2>/dev/null || true
```

After requesting re-review, wait for Copilot to complete its review.

#### 9b. Poll for new review comments

Poll every 30 seconds for up to 5 minutes, checking if Copilot has posted new review since the re-request:

```bash
# Record the timestamp before requesting re-review (ISO 8601)
REREQUEST_TIME=$(date -u +%Y-%m-%dT%H:%M:%SZ)
```

Then poll:
```bash
# Check for new reviews submitted after the re-request
gh api repos/{owner}/{repo}/pulls/{pr_number}/reviews --paginate | \
  jq --arg since "$REREQUEST_TIME" \
  '[.[] | select(.user.login == "copilot-pull-request-reviewer[bot]" or .user.login == "Copilot") | select(.submitted_at > $since)] | sort_by(.submitted_at) | last'
```

Once a new review is detected, fetch new unreplied comments:
```bash
REPLIED=$(gh api repos/{owner}/{repo}/pulls/{pr_number}/comments --paginate | \
  jq '[.[] | select(.in_reply_to_id | . == null | not) | .in_reply_to_id] | unique')

gh api repos/{owner}/{repo}/pulls/{pr_number}/comments --paginate | \
  jq --argjson replied "$REPLIED" \
  '[.[] | select(.in_reply_to_id == null) | select(.id as $id | $replied | index($id) | . == null) | select(.user.login == "Copilot" or (.user.login | endswith("[bot]")))]'
```

**Exit polling when:**
- A new Copilot review is detected with inline comments (proceed to 9c)
- A new Copilot review is detected with no new unreplied inline comments (loop complete — Copilot is satisfied)
- 5 minutes elapsed with no new review activity (assume Copilot is satisfied, exit loop)

#### 9c. Process new comments

Go back to **Step 3** (Filter Bot Comments) with the newly fetched comments. Only process comments that are:
- New (not previously replied to)
- From the current push (commit_id matches HEAD)

#### 9d. Loop termination

The loop terminates when any of these conditions are met:
1. **No new actionable comments** — Copilot is satisfied
2. **Maximum 10 iterations reached** — inform the user and stop
3. **A fix is too complex** — inform the user and stop (don't auto-loop on risky changes)

#### 9e. Loop summary

When the loop completes, display a final summary:

```
## Loop Complete

**Iterations:** 3
**Total comments addressed:** 7
**Total comments acknowledged:** 2
**Files modified:** file1.go, file2.go, file3_test.go
**Final status:** ✅ No remaining actionable comments
**PR:** <link>
```

### Error Handling

- If `gh` is not authenticated, inform the user to run `gh auth login`
- If the PR has no review comments, inform the user and exit
- If a fix would be too complex or risky, skip it and inform the user, then still reply to the comment explaining why it was skipped
- If push fails, show the error and suggest the user resolve it manually

### Notes

- NEVER force-push
- NEVER commit without explicit user permission (first iteration only; `--loop` auto-commits on iteration 2+)
- NEVER push without explicit user permission (first iteration only; `--loop` auto-pushes on iteration 2+)
- When implementing fixes, prefer minimal changes that directly address the review feedback
- If a review suggestion conflicts with existing code patterns in the project, flag this to the user
- If multiple comments relate to the same file/area, batch the changes together
