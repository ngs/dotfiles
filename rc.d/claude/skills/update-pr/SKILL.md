---
name: update-pr
description: Update current branch's PR with appropriate title, description, and labels.
---

# Update Pull Request

Analyze a pull request and update it with appropriate title, description, and labels.

## Arguments (Optional)

- `<owner/repo>` - Repository in owner/repo format (e.g., `lifeistech/dtp-career-journey-backend`)
- `<pr-number>` - PR number (e.g., `87`)

Examples:
- `/update-pr` - Update current branch's PR
- `/update-pr 87` - Update PR #87 in current repo
- `/update-pr lifeistech/dtp-career-journey-backend 87` - Update PR #87 in specified repo

## Instructions

### Step 0: Parse Arguments

Check if arguments were provided:
- If no arguments: use current branch's PR
- If one numeric argument: use that PR number in the current repo
- If two arguments: first is `owner/repo`, second is PR number

Set variables:
- `REPO_FLAG`: empty or `-R <owner/repo>`
- `PR_NUMBER`: empty (for current branch) or the specified number

### Step 1: Gather Information

Run these commands to understand the PR context:

**If using current branch (no PR number specified):**
```bash
git branch --show-current
gh pr view --json number,title,body,labels,baseRefName,headRefName
```

**If PR number is specified:**
```bash
gh pr view <PR_NUMBER> $REPO_FLAG --json number,title,body,labels,baseRefName,headRefName
```

Then get the diff:
```bash
gh pr diff <PR_NUMBER> $REPO_FLAG
```

### Step 2: Analyze Changes

Based on the gathered information:

- Understand the purpose and scope of the changes
- Identify the type of changes (feature, bugfix, refactor, docs, etc.)
- Note any breaking changes or important considerations
- Determine appropriate labels based on the changes

### Step 3: Generate PR Content

#### Title Format

```
<type>: <concise description>
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style/formatting changes
- `refactor`: Code refactoring
- `perf`: Performance improvements
- `test`: Test additions or modifications
- `chore`: Build/tooling changes

Rules for title:
- Keep it under 72 characters
- Use imperative mood ("Add feature" not "Added feature")
- Be specific but concise

#### Description Format

```markdown
## Summary
<Brief 1-2 sentence overview of what this PR does>

## Changes
- <Bullet points of key changes>
- <Be specific about what was modified/added/removed>

## Test Plan
- <How to verify these changes work>
- <Any manual testing steps if applicable>
```

#### Labels

Select appropriate labels based on the changes. Common labels:
- `enhancement` - New features or improvements
- `bug` - Bug fixes
- `documentation` - Documentation updates
- `refactor` - Code refactoring
- `breaking-change` - Breaking changes
- `dependencies` - Dependency updates

### Step 4: Update the PR

Use the `gh` CLI to update the PR:

**If using current branch:**
```bash
gh pr edit --title "<new title>" --body "<new body>"
gh pr edit --add-label "<label1>,<label2>"
```

**If PR number is specified:**
```bash
gh pr edit <PR_NUMBER> $REPO_FLAG --title "<new title>" --body "<new body>"
gh pr edit <PR_NUMBER> $REPO_FLAG --add-label "<label1>,<label2>"
```

### Output

After updating, display:
1. The new PR title
2. The new PR description
3. The labels that were added
4. A link to the PR

If the PR update fails (e.g., no PR exists for current branch), inform the user and suggest creating a PR first with `gh pr create`.
