#!/usr/bin/env python3
"""Build contact sheets of candidate pages for visual review.

Each page is shown with its proposed rotation already applied, so the sheet
can be judged directly. Reads lines of

    pdf path<TAB>page<TAB>rotation<TAB>label

from stdin and writes out_prefix1.jpg, out_prefix2.jpg, ...

  usage: ... | contact-sheet.py /tmp/sheet [cols] [rows] [tile_px]
"""
import glob
import os
import subprocess
import sys
import tempfile

from PIL import Image, ImageDraw

prefix = sys.argv[1]
cols = int(sys.argv[2]) if len(sys.argv) > 2 else 6
rows = int(sys.argv[3]) if len(sys.argv) > 3 else 4
size = int(sys.argv[4]) if len(sys.argv) > 4 else 300

tmp = tempfile.mkdtemp()
tiles = []
for line in sys.stdin.read().splitlines():
    if not line.strip():
        continue
    path, page, rot, label = line.split("\t")
    subprocess.run(
        ["pdftoppm", "-jpeg", "-jpegopt", "quality=55", "-scale-to", str(size - 20),
         "-f", page, "-l", page, path, f"{tmp}/t"],
        capture_output=True,
    )
    found = glob.glob(f"{tmp}/t*.jpg")
    if not found:
        continue
    im = Image.open(found[0]).convert("RGB")
    im = im.rotate(-int(rot), expand=True)   # OSD reports clockwise degrees
    im.thumbnail((size, size - 16))
    tile = Image.new("RGB", (size, size), "white")
    tile.paste(im, ((size - im.width) // 2, 16 + (size - 16 - im.height) // 2))
    ImageDraw.Draw(tile).text((4, 3), label, fill="red")
    tiles.append(tile)
    for f in found:
        os.remove(f)

per = cols * rows
for n in range(0, len(tiles), per):
    chunk = tiles[n:n + per]
    height = ((len(chunk) + cols - 1) // cols) * size
    sheet = Image.new("RGB", (cols * size, height), "white")
    for k, tile in enumerate(chunk):
        sheet.paste(tile, ((k % cols) * size, (k // cols) * size))
    sheet.save(f"{prefix}{n // per + 1}.jpg", quality=72)
print(f"{len(tiles)} tiles -> {prefix}*.jpg")
