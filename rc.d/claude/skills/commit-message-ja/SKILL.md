---
name: commit-message-ja
description: Generate commit message in Japanese from git diff.
---

# Commit Message Generator (日本語)

**出力形式の制約（必ず守ること）:**
レスポンス全体がコミットメッセージのテキストのみであること。
- 前置き禁止（「分析した結果...」「以下がコミットメッセージです...」など）
- マークダウンのコードブロックやバッククォート禁止
- 説明文禁止（前後とも）
- レスポンスはコミットタイプ（feat:, fix: など）から直接開始すること

## Instructions

1. Run `git status` to see all modified and untracked files
2. Run `git diff` to see unstaged changes
3. Run `git diff --cached` to see staged changes
4. Run `git log --oneline -5` to understand the commit message style of this repository

Based on the changes, generate a commit message following these guidelines:

### Commit Message Format

```
<type>: <subject in Japanese>

<body in Japanese>
```

### Types

- `feat`: 新機能
- `fix`: バグ修正
- `docs`: ドキュメントのみの変更
- `style`: コードの意味に影響しない変更（フォーマットなど）
- `refactor`: バグ修正でも機能追加でもないコード変更
- `perf`: パフォーマンス改善
- `test`: テストの追加・修正
- `chore`: ビルドプロセスや補助ツールの変更

### Rules

- 件名は50文字以内
- 件名の末尾に句点を付けない
- 本文は「何を」「なぜ」を説明（「どのように」は不要）
- 本文は72文字で折り返し

---

**最終確認: レスポンス = 生のコミットメッセージのみ。他のテキストは一切不要。**
