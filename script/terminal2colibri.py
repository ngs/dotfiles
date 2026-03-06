#!/usr/bin/env python3
"""Convert macOS Terminal theme (.terminal) to Colibri theme (.colibriTheme)."""

import argparse
import colorsys
import plistlib
import sys
from pathlib import Path


def extract_rgb(color_blob):
    """Extract (R, G, B) tuple from NSKeyedArchiver color data."""
    inner = plistlib.loads(color_blob)
    for obj in inner["$objects"]:
        if isinstance(obj, dict) and "NSRGB" in obj:
            rgb = obj["NSRGB"]
            if isinstance(rgb, bytes):
                rgb = rgb.decode("ascii")
            return tuple(float(x) for x in rgb.strip().strip("\x00").split()[:3])
    raise ValueError("Could not extract RGB from color data")


def make_color_blob(r, g, b):
    """Create NSKeyedArchiver binary plist for an NSColor."""
    rgb_bytes = f"{r} {g} {b}\x00".encode("ascii")
    return plistlib.dumps(
        {
            "$archiver": "NSKeyedArchiver",
            "$version": 100000,
            "$top": {"root": plistlib.UID(1)},
            "$objects": [
                "$null",
                {
                    "NSRGB": rgb_bytes,
                    "NSColorSpace": 1,
                    "$class": plistlib.UID(2),
                },
                {
                    "$classname": "NSColor",
                    "$classes": ["NSColor", "NSObject"],
                },
            ],
        },
        fmt=plistlib.FMT_BINARY,
    )


def perceived_brightness(r, g, b):
    """Compute perceived brightness (ITU-R BT.601)."""
    return 0.299 * r + 0.587 * g + 0.114 * b


def select_accent(colors):
    """Select the most saturated ANSI color as the accent.

    Returns the key name and RGB tuple.
    """
    ansi_keys = [
        "ANSIRedColor",
        "ANSIGreenColor",
        "ANSIYellowColor",
        "ANSIBlueColor",
        "ANSIMagentaColor",
        "ANSICyanColor",
        "ANSIBrightRedColor",
        "ANSIBrightGreenColor",
        "ANSIBrightYellowColor",
        "ANSIBrightBlueColor",
        "ANSIBrightMagentaColor",
        "ANSIBrightCyanColor",
    ]
    best_key = None
    best_sat = -1.0
    for key in ansi_keys:
        if key in colors:
            r, g, b = colors[key]
            _, s, _ = colorsys.rgb_to_hsv(r, g, b)
            if s > best_sat:
                best_sat = s
                best_key = key
    if best_key is None:
        return None, (1.0, 0.5, 0.0)
    return best_key, colors[best_key]


def extract_colors(terminal_path):
    """Read a .terminal file and return a dict of color name -> (R, G, B)."""
    with open(terminal_path, "rb") as f:
        terminal = plistlib.load(f)
    colors = {}
    for key, val in terminal.items():
        if isinstance(val, bytes):
            try:
                colors[key] = extract_rgb(val)
            except (ValueError, KeyError):
                pass
    name = terminal.get("name", Path(terminal_path).stem)
    return name, colors


def clamp(v, lo=0.0, hi=1.0):
    return max(lo, min(hi, v))


def offset_color(rgb, delta):
    """Shift each channel by delta, clamped to [0, 1]."""
    return tuple(clamp(c + delta) for c in rgb)


def dim_color(rgb, factor=0.6):
    """Dim a color by a multiplicative factor."""
    return tuple(c * factor for c in rgb)


def lerp_color(a, b, t):
    """Linearly interpolate between two RGB colors."""
    return tuple(a[i] + (b[i] - a[i]) * t for i in range(3))


def convert(terminal_path, output_path=None, accent_key=None):
    name, colors = extract_colors(terminal_path)

    bg = colors.get("BackgroundColor", (0.0, 0.0, 0.0))
    fg = colors.get("TextColor", (1.0, 1.0, 1.0))
    sel = colors.get("SelectionColor", (0.3, 0.3, 0.3))

    # Comment / dimmed text: 45% from bg toward fg
    comment = lerp_color(bg, fg, 0.45)

    # Accent color
    if accent_key and accent_key in colors:
        accent = colors[accent_key]
    else:
        accent_key, accent = select_accent(colors)

    accent_dim = dim_color(accent)

    # Current-line highlight: slightly offset from background
    is_dark = perceived_brightness(*bg) < 0.5
    curline = offset_color(bg, 0.05 if is_dark else -0.05)

    # Cover style
    cover = "dark" if is_dark else "light"

    # Colibri color mapping (object indices 4–20)
    color_map = {
        4: bg,          # colorBackgroundTop
        5: bg,          # colorBackgroundBottom
        6: fg,          # colorTitleBar
        7: fg,          # colorSongTitle
        8: comment,     # colorArtistName
        9: comment,     # colorAlbumName
        10: accent,     # colorButtonTint
        11: accent_dim, # colorVolumeBar
        12: fg,         # colorSeekBar
        13: fg,         # colorPlaylistText
        14: sel,        # colorPlaylistCursor
        15: accent,     # colorPlaylistHighlight
        16: bg,         # colorPlaylistBackground
        17: comment,    # colorStatusBarText
        18: curline,    # colorPlaylistHeadBackgroundTop
        19: bg,         # colorPlaylistHeadBackgroundBottom
        20: accent,     # colorPlaylistHeadText
    }

    # Build NSKeyedArchiver object graph
    objects = [
        "$null",
        {
            "$class": plistlib.UID(21),
            "colorAlbumName": plistlib.UID(9),
            "colorArtistName": plistlib.UID(8),
            "colorBackgroundBottom": plistlib.UID(5),
            "colorBackgroundTop": plistlib.UID(4),
            "colorButtonTint": plistlib.UID(10),
            "colorPlaylistBackground": plistlib.UID(16),
            "colorPlaylistCursor": plistlib.UID(14),
            "colorPlaylistHeadBackgroundBottom": plistlib.UID(19),
            "colorPlaylistHeadBackgroundTop": plistlib.UID(18),
            "colorPlaylistHeadText": plistlib.UID(20),
            "colorPlaylistHighlight": plistlib.UID(15),
            "colorPlaylistText": plistlib.UID(13),
            "colorSeekBar": plistlib.UID(12),
            "colorSongTitle": plistlib.UID(7),
            "colorStatusBarText": plistlib.UID(17),
            "colorTitleBar": plistlib.UID(6),
            "colorVolumeBar": plistlib.UID(11),
            "cover": plistlib.UID(3),
            "name": plistlib.UID(2),
        },
        name,
        cover,
    ]
    for i in range(4, 21):
        r, g, b = color_map[i]
        objects.append(make_color_blob(r, g, b))
    objects.append(
        {
            "$classname": "Colibri.Theme",
            "$classes": ["Colibri.Theme", "NSObject"],
        }
    )

    theme = {
        "$archiver": "NSKeyedArchiver",
        "$version": 100000,
        "$top": {"root": plistlib.UID(1)},
        "$objects": objects,
    }

    if output_path is None:
        output_path = Path(terminal_path).with_suffix(".colibriTheme")

    with open(output_path, "wb") as f:
        plistlib.dump(theme, f, fmt=plistlib.FMT_BINARY)

    print(f"Created: {output_path}")
    print(f"  Name:   {name}")
    print(f"  Cover:  {cover}")
    if accent_key:
        print(f"  Accent: {accent_key} -> rgb({accent[0]:.3f}, {accent[1]:.3f}, {accent[2]:.3f})")


def main():
    parser = argparse.ArgumentParser(
        description="Convert macOS Terminal theme (.terminal) to Colibri theme (.colibriTheme)"
    )
    parser.add_argument("input", help="Path to .terminal file")
    parser.add_argument(
        "-o",
        "--output",
        help="Output .colibriTheme path (default: same basename with .colibriTheme)",
    )
    parser.add_argument(
        "--accent",
        metavar="COLOR_KEY",
        help="ANSI color key to use as accent (e.g. ANSIYellowColor). "
        "Default: auto-select most saturated ANSI color",
    )
    parser.add_argument(
        "--list-colors",
        action="store_true",
        help="List available colors in the terminal theme and exit",
    )
    args = parser.parse_args()

    if args.list_colors:
        name, colors = extract_colors(args.input)
        print(f"Theme: {name}")
        for key in sorted(colors):
            r, g, b = colors[key]
            _, s, _ = colorsys.rgb_to_hsv(r, g, b)
            hex_color = "#{:02x}{:02x}{:02x}".format(
                int(r * 255), int(g * 255), int(b * 255)
            )
            print(f"  {key:30s} {hex_color}  sat={s:.3f}")
        sys.exit(0)

    convert(args.input, args.output, args.accent)


if __name__ == "__main__":
    main()
