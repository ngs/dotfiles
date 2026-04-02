---
name: bundle-dependabot
description: Bundle dependabot PRs into a single PR and create a PR to master.
---

# Bundle Dependabot Updates

Create a PR that combines multiple open dependabot PRs into a single PR targeting master.

## Arguments (Optional)

- `<target-branch>` - Branch to create PR against (default: `master`)

Examples:
- `/bundle-dependabot` - Combine dependabot PRs targeting master
- `/bundle-dependabot main` - Use main as target branch

## Instructions

### Step 1: Setup - Checkout and Pull Target Branch

```bash
git checkout master
git pull origin master
```

### Step 2: Identify Open Dependabot PRs

Find all open PRs from dependabot:

```bash
gh pr list --author "dependabot[bot]" --state open --json number,title,headRefName
```

If no open PRs are found, inform the user and exit.

List the PRs found and confirm with the user before proceeding.

### Step 3: Create Feature Branch

Generate a branch name with today's date:

```bash
git checkout -b chore/dependabot-updates-$(date +%Y%m%d)
```

### Step 4: Fetch and Merge Each PR

For each dependabot PR, fetch and merge with the original commit message:

```bash
# Fetch all dependabot branches
git fetch origin <branch-name-1> <branch-name-2> ...

# Merge each with --no-ff and proper commit message
git merge --no-ff origin/<branch-name> -m "<original PR title>"
```

**Handling package-lock.json conflicts:**

If a merge conflict occurs in `package-lock.json`:

```bash
git checkout --theirs package-lock.json
npm install
git add package-lock.json package.json
git commit -m "<original PR title>"
```

### Step 5: Bump to Latest Available Versions

After merging all dependabot PRs, check each updated package against the registry and bump to the **latest available version** if it is newer than what dependabot proposed.

For npm packages:
```bash
npm view <package-name> version
```

For Go modules:
```bash
go list -m -versions <module> | awk '{print $NF}'
```

If a newer version is found, apply the update:

For npm packages:
```bash
npm install <package-name>@<latest-version>
git add package.json package-lock.json
git commit -m "chore(deps): bump <package> from <dependabot-version> to <latest-version>"
```

For Go modules:
```bash
go get <module>@<latest-version>
go mod tidy
git add go.mod go.sum
git commit -m "chore(deps): bump <module> from <dependabot-version> to <latest-version>"
```

If the update to the latest version fails (e.g., breaking changes), keep the dependabot-proposed version and note this in the PR description.

### Step 6: Push and Create PR

```bash
git push -u origin HEAD
```

Create the PR in English:

```bash
gh pr create \
  --base master \
  --title "chore(deps): bundle dependabot updates" \
  --body "$(cat <<'EOF'
## Summary
Bundle multiple dependabot dependency updates into a single PR.

## Changes
<list of dependency updates from merged PRs>

## Notes
Use "Squash and merge" to combine into a single commit.
EOF
)"
```

### Step 7: Output

Display:
1. List of dependabot PRs that were merged
2. The new branch name
3. Link to the created PR

### Error Handling

- If no open dependabot PRs are found, inform the user and exit
- If merge conflicts occur (other than package-lock.json), pause and ask the user how to proceed
- If PR creation fails, show the error and the manual command to create it

### Notes

- Do NOT squash commits locally - GitHub's "Squash and merge" will handle that
- Use the original dependabot PR title as the merge commit message
- Always use `--no-ff` to create merge commits
