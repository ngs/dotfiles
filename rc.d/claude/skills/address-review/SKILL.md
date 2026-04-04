---
name: address-review
description: Address code review comments from Copilot and other bots on the current branch's PR. Implements fixes if needed, commits, pushes, and replies to each comment.
---

# Address Bot Code Review Comments

Review code review comments from Copilot and other automated reviewers on the current branch's PR. Implement fixes if needed, then reply to each comment.

## Arguments (Optional)

- `<pr-number>` - PR number (default: current branch's PR)
- `--all` - Address all review comments, not just bot comments

Examples:
- `/address-review` - Address bot review comments on current branch's PR
- `/address-review 42` - Address bot review comments on PR #42
- `/address-review --all` - Address all review comments including human ones

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

**Commit and push are separate confirmations. Both require explicit user permission.**

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

### Error Handling

- If `gh` is not authenticated, inform the user to run `gh auth login`
- If the PR has no review comments, inform the user and exit
- If a fix would be too complex or risky, skip it and inform the user, then still reply to the comment explaining why it was skipped
- If push fails, show the error and suggest the user resolve it manually

### Notes

- NEVER force-push
- NEVER commit without explicit user permission
- NEVER push without explicit user permission
- When implementing fixes, prefer minimal changes that directly address the review feedback
- If a review suggestion conflicts with existing code patterns in the project, flag this to the user
- If multiple comments relate to the same file/area, batch the changes together
