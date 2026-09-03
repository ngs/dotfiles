---
name: organize-scans
description: Rename scanned PDFs (Image*.pdf and similar) based on their content, fix per-page rotation, and move them into a dated archive folder. Use when the user asks to organize, rename, rotate, or file away scanner output.
---

# Organizing scanned PDFs

Takes the sequentially named PDFs a scanner produces (`Image 190803 0001.pdf` and
the like), **reads each one to derive a content-based filename**, **fixes the
orientation page by page**, and moves the result into a target folder.

## Required tools

| Purpose | Command | Package |
|---|---|---|
| Render pages | `pdftoppm` / `pdfinfo` | poppler |
| Detect orientation | `tesseract` + `osd.traineddata` | tesseract (`--psm 0`) |
| Rewrite PDFs | `python3` + `pypdf` | applying rotation |
| Image handling | `python3` + `PIL` | contact sheets |

Install what is missing with `brew install poppler tesseract` /
`pip install pypdf pillow`.

## Procedure

### 1. Enumerate the input

```bash
find ~ -maxdepth 4 -iname "Image*.pdf" -not -path "*/Library/*"
```

Read each file's page count and build an index of `number|path|pages`. Refer to
files by that index number from here on, so shell loops never have to carry
Japanese filenames with spaces.

### 2. Read the content and choose a filename

Render page 1 (and page 2 when it helps) as a **JPEG about 700px wide** and read
it. Higher resolution just burns context for no gain at this stage.

```bash
pdftoppm -jpeg -jpegopt quality=55 -scale-to 700 -f 1 -l 2 "$f" "$W/$idx"
```

> **Gotcha**: `pdftoppm` zero-pads its output index to the page count
> (`-1.jpg` vs `-01.jpg` vs `-001.jpg`). Normalize the suffixes after rendering.

Naming pattern:

```
YYYYMMDD_issuer_document.pdf   # anything with a date on it
issuer_product_doctype.pdf     # manuals, catalogs, undated material
meishi_company_person.pdf      # business cards
```

- Use the date **printed on the document** (issue date, billing date, expiry
  date), not the scan date. Convert Japanese era years to the Gregorian calendar.
- For anything over ~10 pages, **also look at a middle page**. Feeding a stack
  through a sheet feeder routinely merges several unrelated leaflets into one
  PDF. When that happens, name it so the bundling is obvious, e.g.
  `<representative item>_and_others_bundle.pdf`.

### 3. Rename and move

Build a mapping table of `index<TAB>new filename` first, then apply it in one
pass with `mv -n`. Check for duplicates within the table and for pre-existing
files at the destination before moving anything.

### 4. Detect orientation per page

**Judge per page, not per document.** In a bundled scan it is entirely normal
for only page 1 to be sideways, or for just the reverse sides to be upside down.

Run `scripts/osd-page.sh` across every page in parallel:

```bash
python3 scripts/make-jobs.py index.txt jobs.bin
xargs -0 -n3 -P 8 scripts/osd-page.sh < jobs.bin > result.txt
```

- **Render at 300dpi.** 150dpi produces wrong answers on Japanese documents
  (verified: a page needing 270 came back as 0 at 150dpi, correct at 200+).
- Pass the job list **NUL-separated**. Filenames contain spaces, and piping a
  tab-separated list through `tr '\t' '\0'` leaves the newlines intact, so
  `xargs -0` merges each record's last field with the next record's first one.
  Write the list from Python with `'\0'.join(...)` instead.

### 5. Verify the detection by eye (required)

OSD misfires on Japanese material. Build a contact sheet with
`scripts/contact-sheet.py` showing every candidate page **already rotated as
proposed**, then review them together.

Typical false positives:

- **Photo-only pages** — no textual cue, so the answer is a coin flip
- **Vertically set Japanese text** (business cards, formal notices) — already
  upright, but reported as needing 90°
- **Blank reverse sides with show-through** — mirrored text gets "corrected"
- **Cover images** — large photo, low confidence, confident-looking suggestion

Confidence is only a hint: 0.1 is sometimes right and 20 is sometimes wrong.
**Decide from the image every time.** For borderline pages, render the original
alongside each candidate rotation and pick from that. When it still cannot be
decided, leave the page alone — no rotation is the safe default.

### 6. Apply the rotation

```python
page.rotate(deg)   # pypdf: clockwise, added to the existing /Rotate
```

The `Rotate:` value from OSD is already "degrees clockwise to make it upright",
so it can be passed straight through. Write to a temp file and swap it in with
`os.replace()`.

### 7. Re-verify

Build one more contact sheet of just the rotated pages and confirm the result.

## Rescuing a scan whose edge detection failed

When the scanner's auto-crop misses, it emits a long thin page with the original
sitting in one corner. Render the page, measure the bounding box of the content,
and replace the `mediabox` — the pixel data stays in the file, so the crop can be
redone later.

```python
p.mediabox.lower_left  = (left, bottom)
p.mediabox.upper_right = (right, top)
p.cropbox = p.mediabox
```

Convert px to pt with `px * 72 / dpi`, and flip Y because PDF coordinates start
at the bottom left. If the original ran off the edge of the page, **the clipped
part cannot be recovered** — say so and suggest a rescan.

## Practical notes

- Expect roughly 100 files and 1000 pages. Even at 8-way parallelism the OSD
  pass takes tens of minutes, so run it in the background.
- **Do not move files while a background pass is running against them.** The
  paths disappear and every remaining job fails.
- Never quietly discard something that could not be identified (blank pages,
  unreadable scans). Give it a name that says so and report it to the user.
