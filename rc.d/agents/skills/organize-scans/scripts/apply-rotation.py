#!/usr/bin/env python3
"""Apply confirmed rotations to PDFs.

Reads lines of  pdf path<TAB>page<TAB>rotation  from stdin and rewrites each
file once. pypdf's rotate() turns clockwise and adds to the existing /Rotate,
so the value OSD reports can be passed through unchanged.

  usage: ... | apply-rotation.py
"""
import collections
import os
import sys

from pypdf import PdfReader, PdfWriter

plan = collections.defaultdict(dict)
for line in sys.stdin.read().splitlines():
    if not line.strip():
        continue
    path, page, rot = line.split("\t")
    plan[path][int(page)] = int(rot)

for path, pages in plan.items():
    reader, writer = PdfReader(path), PdfWriter()
    for n, page in enumerate(reader.pages, 1):
        if n in pages:
            page.rotate(pages[n])
        writer.add_page(page)
    tmp = path + ".tmp"
    with open(tmp, "wb") as fh:
        writer.write(fh)
    os.replace(tmp, path)
    print(f"{os.path.basename(path)}: {len(pages)} pages")
