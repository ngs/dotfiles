---
name: self-review
description: Review the current branch's PR diff using a separate Claude Code agent and post inline comments via GitHub API. Optionally auto-fix findings.
---

# Self Code Review

Use a separate Claude Code agent (in a worktree) to review the current branch's PR diff, then post inline review comments to the PR via `gh api`. This serves as a Copilot-independent code review that respects project-specific CLAUDE.md rules.

## Arguments (Optional)

- `<pr-number>` - PR number (default: current branch's PR)
- `--fix` - After posting review comments, automatically implement fixes, commit, and push
- `--loop` - After fixing, re-review and repeat until zero actionable findings (max 5 iterations)

Examples:
- `/self-review` - Review current branch's PR and post comments
- `/self-review 42` - Review PR #42
- `/self-review --fix` - Review and auto-fix all findings
- `/self-review --fix --loop` - Review, fix, re-review until clean

## Instructions

### Step 1: Identify PR & Collect Context

```bash
git branch --show-current
gh pr view --json number,url,headRefName,baseRefName
gh repo view --json nameWithOwner -q .nameWithOwner
```

If no PR exists, inform the user and exit.

Get the full diff:

```bash
gh pr diff {pr_number}
```

Get the list of changed files:

```bash
gh pr diff {pr_number} --name-only
```

### Step 2: Launch Reviewer Agent

Spawn an **Agent** with `subagent_type: "general-purpose"` and `isolation: "worktree"` (read-only — the reviewer must NOT edit files).

The reviewer agent's prompt must include:

1. **The full PR diff** (from Step 1)
2. **The list of changed files**
3. **Instructions to read CLAUDE.md** from the repo root for project-specific rules
4. **The review checklist** (see below)
5. **Output format**: return a JSON array of findings

#### Review Checklist

Tell the reviewer agent to check for:

- **Correctness**: Logic errors, off-by-one, nil/null dereference, missing error handling
- **Security**: SQL injection, command injection, XSS, secrets in code, OWASP top 10
- **Error handling**: Swallowed errors, generic error messages that hide root cause, missing error propagation
- **Consistency**: Does new code follow existing patterns in the codebase? Naming conventions?
- **Tests**: Are new functions/branches covered by tests? Are tests meaningful (not just coverage padding)?
- **CLAUDE.md compliance**: Does the code follow all project-specific rules defined in CLAUDE.md?
- **Performance**: N+1 queries, unnecessary allocations, missing indexes
- **API design**: GraphQL schema consistency, breaking changes, missing fields

Tell the reviewer agent to NOT flag:

- Style-only issues that a linter would catch (formatting, import order)
- Missing comments/docs on code that is self-explanatory
- Hypothetical future requirements ("you might also want to...")
- Issues in unchanged code (review only the diff)

#### Expected Output Format

Tell the reviewer agent to return ONLY a JSON array (no markdown, no preamble):

```json
[
  {
    "path": "internal/service/foo.go",
    "line": 42,
    "severity": "error|warning|suggestion",
    "message": "Short description of the issue",
    "suggestion": "Optional: what the code should look like instead"
  }
]
```

If there are no findings, return an empty array: `[]`

The `line` must refer to a line number in the NEW version of the file (right side of the diff). The reviewer agent must read the actual file (not just the diff) to get accurate line numbers.

### Step 3: Parse Reviewer Output

Parse the JSON array from the reviewer agent's response. If the response is not valid JSON or is empty, report "No issues found" and exit.

Categorize findings by severity:
- **error**: Must fix — bugs, security issues, broken functionality
- **warning**: Should fix — error handling gaps, inconsistencies, performance
- **suggestion**: Nice to have — style improvements, minor refactors

Present the findings to the user:

```
## Self-Review Findings

### Errors (X)
1. [path:line] message

### Warnings (X)
1. [path:line] message

### Suggestions (X)
1. [path:line] message
```

### Step 4: Post Comments to PR

For each finding, post an inline review comment using the GitHub API.

First, get the HEAD commit SHA of the PR:

```bash
gh pr view {pr_number} --json headRefOid -q .headRefOid
```

Then post each comment:

```bash
gh api repos/{owner}/{repo}/pulls/{pr_number}/comments \
  -f body="$(cat <<'EOF'
**[{severity}]** {message}

{suggestion if present, formatted as a code suggestion block}
EOF
)" \
  -f commit_id="{head_commit_sha}" \
  -f path="{path}" \
  -F line={line} \
  -f side="RIGHT"
```

**Important**: The `line` parameter must be a line that appears in the diff. If a finding refers to a line outside the diff hunk, post it as a PR-level comment instead:

```bash
gh pr comment {pr_number} --body "**[{severity}]** \`{path}:{line}\` — {message}"
```

### Step 5: Auto-Fix (if `--fix` specified)

If `--fix` is specified, for each **error** and **warning** finding:

1. Read the relevant file
2. Implement the fix
3. Verify with build check (`make build-check` or equivalent)

Then commit and push:

```bash
git add <modified-files>
git diff --cached --stat
git commit -m "fix: address self-review findings

<bullet list of fixes>"
git push
```

After pushing, reply to each comment that was fixed:

```bash
COMMIT_SHA=$(git rev-parse HEAD)
COMMIT_SHORT=$(git rev-parse --short HEAD)
FILE_HASH=$(echo -n "{path}" | shasum -a 256 | cut -d' ' -f1)

gh api repos/{owner}/{repo}/pulls/{pr_number}/comments/{comment_id}/replies \
  -f body="Fixed in ${COMMIT_SHORT}.

→ [View diff](https://github.com/{owner}/{repo}/commit/${COMMIT_SHA}#diff-${FILE_HASH})"
```

### Step 6: Loop Mode (if `--loop` specified)

Requires `--fix`. After fixing and pushing:

1. Re-run the reviewer agent (Step 2) on the updated code
2. If new findings exist, fix them (Step 5)
3. Repeat until no error/warning findings remain, or max 5 iterations

Exit conditions:
- **Zero error/warning findings** — review is clean
- **5 iterations reached** — inform user, stop
- **A fix is too complex** — skip it, inform user

Display final summary:

```
## Self-Review Complete

**Iterations:** 2
**Total findings posted:** 8
**Findings fixed:** 6
**Remaining suggestions:** 2
**Files modified:** file1.go, file2.go
**PR:** <link>
```

### jq Caveats

**In zsh, `!=` gets escaped to `\!=`, causing jq parse errors.** Always use the `| not` pattern:

```bash
# BAD — breaks in zsh
jq 'select(.body != null)'

# GOOD — safe in zsh
jq 'select(.body | . == null | not)'
```

### Error Handling

- If `gh` is not authenticated, inform the user to run `gh auth login`
- If the PR diff is empty, inform the user and exit
- If the reviewer agent returns invalid JSON, show the raw output and ask the user what to do
- If posting a comment fails (e.g., line not in diff), fall back to a PR-level comment
- NEVER force-push
- Without `--fix`: NEVER commit or push

### Notes

- The reviewer agent runs in a **worktree** (isolated copy) and must NOT modify any files
- Review comments are posted under the current user's GitHub account (whoever `gh` is authenticated as)
- To distinguish self-review comments from human comments, all comments are prefixed with severity tags: `**[error]**`, `**[warning]**`, `**[suggestion]**`
- This skill is complementary to `/address-review` — use `/self-review` to find issues, then `/address-review` to handle external reviewer feedback
