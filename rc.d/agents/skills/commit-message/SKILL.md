---
name: commit-message
description: Generate commit message in English from git diff.
---

# Commit Message Generator

**OUTPUT FORMAT CONSTRAINT (MUST FOLLOW):**
Your entire response must be ONLY the commit message text itself.
- NO preamble ("Based on...", "Here's...", "I'll generate...")
- NO markdown code blocks or backticks
- NO explanation before or after
- Start your response directly with the commit type (feat:, fix:, etc.)

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

---

**FINAL REMINDER: Your response = raw commit message only. No other text.**
