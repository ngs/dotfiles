#!/bin/bash
#
# setup.d/ubuntu/*.sh を実行する。001-apt.sh で依存パッケージを入れてから、
# 残り (002〜 の *env 系・gcloud.sh) は互いに独立なので並列実行する。
# 出力の interleave を避けるため各スクリプトのログはファイルに分離し、
# 失敗時は末尾を表示する。setup.sh から呼ばれるほか、CI から単体でも実行できる。
set -eu

DOTFILES=$(cd "$(dirname "$0")/.." && pwd)
TS=${TS:-$(date +'%Y%m%d%H%M%S')}
logdir="${DOTFILES_SETUP_LOGDIR:-${TMPDIR:-/tmp}/dotfiles-setup-$TS}"

mkdir -p "$logdir"

/bin/sh "$DOTFILES/setup.d/ubuntu/001-apt.sh"

jobs=""
for f in "$DOTFILES"/setup.d/ubuntu/*.sh ; do
  name=$(basename "$f" .sh)
  if [ "$name" != '001-apt' ]; then
    echo "==> $name: started (log: $logdir/$name.log)"
    /bin/sh "$f" > "$logdir/$name.log" 2>&1 &
    jobs="$jobs $!:$name"
  fi
done

# どれか 1 つでも失敗したら非ゼロで exit する (全 PID を wait 済みなのでハングはしない)
status=0
for job in $jobs; do
  pid=${job%%:*}
  name=${job#*:}
  if wait "$pid"; then
    echo "==> $name: OK"
  else
    status=1
    echo "==> $name: FAILED (log: $logdir/$name.log)" >&2
    tail -n 30 "$logdir/$name.log" >&2
  fi
done
exit $status
