---
name: update-pr
description: Update current branch's PR with appropriate title, description, and labels.
---

# Update Pull Request

Analyze the current branch's pull request and update it with appropriate title, description, and labels.

## Instructions

### Step 1: Gather Information

Run these commands to understand the PR context:

1. `git branch --show-current` - Get current branch name
2. `gh pr view --json number,title,body,labels,baseRefName` - Get current PR details
3. `git log $(git merge-base HEAD origin/main)..HEAD --oneline` - Get commits in this PR
4. `git diff origin/main...HEAD --stat` - Get changed files summary
5. `git diff origin/main...HEAD` - Get actual code changes

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

```bash
gh pr edit --title "<new title>" --body "<new body>"
gh pr edit --add-label "<label1>,<label2>"
```

### Output

After updating, display:
1. The new PR title
2. The new PR description
3. The labels that were added
4. A link to the PR

If the PR update fails (e.g., no PR exists for current branch), inform the user and suggest creating a PR first with `gh pr create`.
