#!/bin/bash
#
# Run setup.d/ubuntu/*.sh. First 001-apt.sh installs dependency packages, then
# the rest (the 002+ *env scripts and gcloud.sh) are independent of each other
# and run in parallel. To avoid interleaved output, each script's log is written
# to a separate file, and its tail is shown on failure. Called from setup.sh, and
# can also be run standalone from CI.
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

# Exit non-zero if any one of them failed (we wait on every PID, so no hang)
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
