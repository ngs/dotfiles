---
name: commit-message
description: Generate commit message in English from git diff.
---

# Commit Message Generator

Generate a commit message in English from the current uncommitted git changes.

## Instructions

1. Run `git status` to see all modified and untracked files
2. Run `git diff` to see unstaged changes
3. Run `git diff --cached` to see staged changes
4. Run `git log --oneline -5` to understand the commit message style of this repository

Based on the changes, generate a commit message following these guidelines:

### Commit Message Format

```
<type>: <subject>

<body>
```

### Types

- `feat`: A new feature
- `fix`: A bug fix
- `docs`: Documentation only changes
- `style`: Changes that do not affect the meaning of the code (formatting, etc.)
- `refactor`: A code change that neither fixes a bug nor adds a feature
- `perf`: A code change that improves performance
- `test`: Adding missing tests or correcting existing tests
- `chore`: Changes to the build process or auxiliary tools

### Rules

- Subject line should be 50 characters or less
- Use imperative mood ("Add feature" not "Added feature")
- Do not end the subject line with a period
- Body should explain what and why, not how
- Wrap body at 72 characters

### Output

CRITICAL RULES:
- Output ONLY the raw commit message text
- NO preamble like "Based on my analysis..." or "Here's the commit message:"
- NO markdown code blocks or backticks
- NO explanation before or after
- Start directly with the type (feat, fix, etc.)
- The output will be passed directly to `git commit -m` command
