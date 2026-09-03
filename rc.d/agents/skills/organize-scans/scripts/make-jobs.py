#!/usr/bin/env python3
"""Build a NUL-separated job list from an index file.

Each index line is  number|pdf path|page count

NUL separation is required because filenames contain spaces. Converting a
tab-separated list with `tr` leaves the newlines in place, so `xargs -0`
merges each record's last field with the next record's first one.

  usage: make-jobs.py index.txt jobs.bin
  then : xargs -0 -n3 -P 8 osd-page.sh < jobs.bin > result.txt
"""
import sys

index_path, out_path = sys.argv[1], sys.argv[2]
args = []
for line in open(index_path, encoding="utf-8").read().splitlines():
    idx, path, pages = line.split("|")
    for page in range(1, int(pages) + 1):
        args += [path, str(page), idx]
open(out_path, "wb").write(("\0".join(args) + "\0").encode("utf-8"))
print(f"{len(args) // 3} jobs -> {out_path}")
