#!/bin/bash
set -eux
###
UNAME=$(uname -s)
TS=$(date +'%Y%m%d%H%M%S')
DOTFILES=$(cd $(dirname $0) && pwd)

sudo mkdir -p /usr/local/bin

# 001-apt.sh で依存パッケージを入れてから、残り (002〜 の *env 系・gcloud.sh) は
# 互いに独立なので並列実行する。出力の interleave を避けるため各スクリプトの
# ログは $logdir/<name>.log に分離し、失敗時は末尾を表示する。
# どれか 1 つでも失敗したら非ゼロで return し、set -e により setup.sh 全体を
# 失敗させる (全 PID を wait 済みなのでハングはしない)。
run_ubuntu_setup() {
  local logdir="${TMPDIR:-/tmp}/dotfiles-setup-$TS"
  local jobs="" job pid name f status=0
  mkdir -p "$logdir"
  /bin/sh "$DOTFILES/setup.d/ubuntu/001-apt.sh"
  for f in "$DOTFILES"/setup.d/ubuntu/*.sh ; do
    name=$(basename "$f" .sh)
    if [ "$name" != '001-apt' ]; then
      echo "==> $name: started (log: $logdir/$name.log)"
      /bin/sh "$f" > "$logdir/$name.log" 2>&1 &
      jobs="$jobs $!:$name"
    fi
  done
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
  return $status
}

cd $DOTFILES
git submodule init
git submodule update
cd -

set +u
if [ $WSL_DISTRO_NAME == 'Ubuntu' ]; then
  run_ubuntu_setup
fi

if [ $CODESPACES ]; then
  run_ubuntu_setup
fi
set -u

if [ $UNAME == 'Linux' ] && [ -f /boot/config.txt ]; then
  /bin/sh $DOTFILES/setup.d/raspberrypi/apt.sh
fi

if [ $UNAME == 'Darwin' ]; then
  /bin/sh $DOTFILES/setup.d/darwin/homebrew.sh
  for f in $DOTFILES/setup.d/darwin/*.sh ; do
    /bin/sh $f
  done
fi

for f in $DOTFILES/setup.d/*.sh ; do
  /bin/sh $f
done
