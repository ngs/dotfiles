# AGENTS.md

このリポジトリで作業する AI エージェント向けのガイド。リポジトリ固有のハマりどころを集約する。

## シェル / 実行環境

- **デフォルトシェルは zsh**（エージェントの Bash ツールも zsh で動く）。スクリプト内で
  `status` を変数名に使わないこと — zsh では `status` は読み取り専用で `read-only variable`
  エラーになる。`st` などに置き換える。
- `jq` のフィルタで `!=` を使うと zsh が `\!=` にエスケープしてパースエラーになる。
  `select(.x | . == null | not)` のように `| not` パターンで書く。

## シェルスクリプトの構文チェック / lint

- `env.sh` と `env.d/**/*.sh` は **shebang を持たない**。シェル起動時に source される断片で、
  bash/zsh 構文（関数定義・`[[ ]]` 等）を含む。したがって `sh -n`（dash）では誤検知する。
  これらは `bash -n` で検査する。
- CI（`.github/workflows/ci.yml` の lint ジョブ）は追跡対象の全 `*.sh` を `git ls-files` で
  列挙し、shebang で判定する: `*bash*` → `bash -n`、`#!...sh` → `sh -n`、**shebang なし →
  `bash -n`**（上記の source 断片のため）。

## *env（言語ランタイム）

- バージョンのピン留めは `setup.d/ubuntu/00X-*.sh` の `VERSION=` に一元化されている
  （nodenv=002 / rbenv=003 / pyenv=004 / goenv=005）。変更はこのファイルだけを書き換える。
- CI はインストール結果がこのピン留め値と一致するかをアサートする（不一致で fail）。期待値は
  各 setup スクリプトの `VERSION=` から抽出するのでハードコードしない。
- **バージョン検証時は shims を PATH 先頭に置くこと。** `rbenv init -` / `goenv init -` は
  shims を PATH 先頭に入れない実装があり、ランナー同梱の system ruby/go が優先されてしまう。
  `export PATH="$HOME/.rbenv/shims:$HOME/.goenv/shims:...:$PATH"` のように明示する
  （nodenv/pyenv は `init -` だけで効く）。
- リポジトリ更新は `git clone` 以外（パッケージ・手動展開・symlink）で配置された場合に備え、
  `[ -d ~/.Xenv/.git ]` ガードで囲み `git pull --ff-only`（意図しない merge を作らない）。

## GnuPG

- `~/.gnupg` は `rc.d/gnupg` への symlink。`gpg-agent.conf` は **生成物で gitignore 対象**。
  ソースは `rc.d/gnupg/gpg-agent.conf.linux` / `.darwin` で、`setup.d/dotfiles.sh` が
  プラットフォーム別にコピー生成する。設定変更は生成物ではなく `.linux` / `.darwin` を編集する。
  キャッシュ TTL は 1 年（一度 unlock すれば保持）。
- コミットは GPG 署名される（鍵 `036459B1`）。エージェントの非 tty シェルでは対話的 pinentry が
  動かずコミットがハングする。**セッション開始時に一度ユーザーが**
  `echo | gpg --clearsign -u 036459B1 -o /dev/null` を実行してパスフレーズを agent に
  キャッシュさせてから、コミット系の作業を進める。

## dotfiles の symlink 規約

- プラットフォーム固有ファイルは `*.darwin` / `*.linux` サフィックスで管理し、
  `setup.d/dotfiles.sh` の `resolve_os_name` が OS に応じて実体名へ解決する。
- push は必ず `git push origin <current-branch>`（bare push 禁止）。

## このファイルと CLAUDE.md

- `CLAUDE.md` はこの `AGENTS.md` への symlink。内容は AGENTS.md 側を編集する。
