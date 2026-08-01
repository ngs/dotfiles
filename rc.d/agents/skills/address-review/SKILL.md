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

If there are NO actionable comments:
- **In `--loop` mode:** reply to non-actionable comments with acknowledgment automatically and proceed.
- **Otherwise:** ask the user if they want to reply to non-actionable comments. If the user confirms, go to Step 7 (reply only). If not, exit.

If there ARE actionable comments:
- **In `--loop` mode:** proceed with implementation immediately without asking for confirmation.
- **Otherwise:** ask the user for confirmation before proceeding with implementation.

### Step 5: Implement Fixes

For each actionable comment:

1. Read the relevant file and understand the context around the commented line(s)
2. Understand the suggestion from the review comment
3. Implement the fix
4. Verify the fix doesn't break surrounding code

After implementing all fixes, present a summary of changes to the user.

### Step 6: Commit & Push

Stage only the files that were modified to address reviews and show the diff:

```bash
git add <modified-files>
git diff --cached --stat
```

**In `--loop` mode:** Auto-commit and auto-push without asking. Always show the diff summary before committing so the user can see what changed.

**Otherwise (no `--loop`):** Commit and push are separate confirmations. Both require explicit user permission.

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

### Step 6.5: Check CI Status After Push

After every push, verify that CI passes on the pushed commit. Wait for checks to complete:

```bash
gh pr checks {pr_number} --watch --interval 30
```

If `--watch` is unavailable or hangs, poll instead:

```bash
gh pr checks {pr_number}
```

and repeat every 30 seconds until no check is `pending`.

**If any check fails:**

1. Identify the failing run and fetch only the failed logs:
   ```bash
   gh run list --branch $(git branch --show-current) --limit 5
   gh run view {run_id} --log-failed
   ```
2. Determine whether the failure was caused by the review fixes just pushed.
   - **Caused by our changes:** implement a fix, then go back to Step 6 (commit & push). In `--loop` mode, do this automatically; otherwise ask the user first.
   - **Pre-existing / unrelated failure** (also failing on the base branch or before our changes): do NOT attempt to fix it automatically. Report it to the user and continue.
3. Never mark the run complete while CI is red due to our own changes.

**If all checks pass:** proceed to Step 7.

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
4. CI status of the pushed commit (from Step 6.5)
5. Link to the PR

### Step 9: Loop Mode (`--loop`)

If `--loop` is specified, after completing Step 7 (reply) and Step 8 (summary), continue with the following loop:

#### 9a. Run CI check and Copilot re-review in PARALLEL

**Do NOT wait for CI before dealing with the re-review — run both in parallel.** Start the CI watch (Step 6.5) as a background task immediately after pushing, and handle the Copilot re-review concurrently.

**Copilot may auto-review after a push (repos with Copilot auto-assignment re-review each new commit).** So first check whether a review on the pushed commit already exists or is pending, and only request one if not:

```bash
# Has Copilot already reviewed the pushed commit?
HEAD_SHA=$(git rev-parse HEAD)
gh api repos/{owner}/{repo}/pulls/{pr_number}/reviews --paginate | \
  jq --arg sha "$HEAD_SHA" \
  '[.[] | select(.user.login | test("copilot|Copilot")) | select(.commit_id == $sha)] | length'

# Is a Copilot re-review already pending (requested but not yet submitted)?
gh pr view {pr_number} --json reviewRequests -q '.reviewRequests'
```

- If a Copilot review for HEAD already exists → skip the re-request and go straight to 9b/9c with that review.
- If a review request is pending → skip the re-request and poll (9b).
- Otherwise, explicitly request a re-review:

```bash
gh api repos/{owner}/{repo}/pulls/{pr_number}/requested_reviewers \
  -X POST -f 'reviewers[]=copilot-pull-request-reviewer[bot]'
```

If the above fails (some repos use team-based Copilot assignment), try:
```bash
gh pr edit {pr_number} --add-reviewer '@copilot-pull-request-reviewer[bot]' 2>/dev/null || true
```

**CI still gates the loop, not the review request:** before treating an iteration as done (9d condition 1), the background CI watch must have finished green. If CI fails because of our changes, fix → commit → push → re-check CI, all automatically. New comments found while CI is still running can be addressed in the meantime.

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
- New comments from Copilot are detected (proceed to 9c)
- Copilot submits a **new** review (review count increases) whose body contains `generated no comments` — this means Copilot is satisfied and the loop is complete.

**IMPORTANT: Do NOT exit polling based on elapsed time alone. Keep polling until Copilot posts a new review. Never assume Copilot is satisfied just because time has passed — always wait for an actual new review to appear.**

To detect the termination condition, check the latest review body:
```bash
gh api repos/{owner}/{repo}/pulls/{pr_number}/reviews --paginate | \
  jq '[.[] | select(.user.login | endswith("[bot]") or . == "Copilot" or . == "copilot-pull-request-reviewer[bot]")] | sort_by(.submitted_at) | last | .body' | \
  grep -q "generated no comments"
```

#### 9c. Process new comments

Go back to **Step 3** (Filter Bot Comments) with the newly fetched comments. Only process comments that are:
- New (not previously replied to)
- From the current push (commit_id matches HEAD)

#### 9d. Loop termination

The loop terminates when any of these conditions are met:
1. **No new actionable comments AND CI is green** (excluding pre-existing failures unrelated to our changes) — Copilot is satisfied
2. **Maximum 10 iterations reached** — inform the user and stop
3. **A fix is too complex** — inform the user and stop (don't auto-loop on risky changes)
4. **CI keeps failing after 3 consecutive fix attempts for the same check** — inform the user and stop

#### 9e. Loop summary

When the loop completes, display a final summary:

```
## Loop Complete

**Iterations:** 3
**Total comments addressed:** 7
**Total comments acknowledged:** 2
**Files modified:** file1.go, file2.go, file3_test.go
**CI status:** ✅ All checks passing
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
- **In `--loop` mode:** auto-commit and auto-push on ALL iterations (no user confirmation needed). Show diff summary before each commit.
- **Without `--loop`:** NEVER commit or push without explicit user permission.
- When implementing fixes, prefer minimal changes that directly address the review feedback
- If a review suggestion conflicts with existing code patterns in the project, flag this to the user
- If multiple comments relate to the same file/area, batch the changes together
