#!/bin/zsh
# Detect the orientation of a single PDF page with tesseract OSD.
# usage: osd-page.sh <pdf> <page> <index>
# output: index|page|rotate|confidence|pdf
#   rotate = degrees clockwise needed to make the page upright (0/90/180/270)
# 300dpi is required; 150dpi misjudges Japanese documents.
f="$1"; p="$2"; idx="$3"
t=$(mktemp -d)
pdftoppm -gray -png -r 300 -f "$p" -l "$p" "$f" "$t/p" 2>/dev/null
img=$(ls "$t"/p*.png 2>/dev/null | head -1)
if [ -n "$img" ]; then
  out=$(tesseract "$img" - --psm 0 2>/dev/null)
  rot=$(print -r -- "$out" | awk -F': ' '/^Rotate/{print $2}')
  conf=$(print -r -- "$out" | awk -F': ' '/^Orientation confidence/{print $2}')
  print -r -- "$idx|$p|${rot:-NA}|${conf:-NA}|$f"
else
  print -r -- "$idx|$p|ERR|0|$f"
fi
rm -rf "$t"
