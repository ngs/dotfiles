#!/usr/bin/env python3
"""Convert macOS Terminal theme (.terminal) to Prompt theme (.prompttheme)."""

import argparse
import plistlib
import sys
import uuid
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


def uid(n):
    """Create a CF$UID reference dict for XML plist format."""
    return {"CF$UID": n}


def convert(terminal_path, output_path=None):
    name, colors = extract_colors(terminal_path)

    bg = colors.get("BackgroundColor", (0.0, 0.0, 0.0))
    fg = colors.get("TextColor", (1.0, 1.0, 1.0))
    bold = colors.get("TextBoldColor", fg)
    sel = colors.get("SelectionColor", (0.3, 0.3, 0.3))
    cursor = colors.get("CursorColor", fg)

    ansi_defaults = {
        "ANSIBlackColor": (0.0, 0.0, 0.0),
        "ANSIRedColor": (1.0, 0.0, 0.0),
        "ANSIGreenColor": (0.0, 1.0, 0.0),
        "ANSIYellowColor": (1.0, 1.0, 0.0),
        "ANSIBlueColor": (0.0, 0.0, 1.0),
        "ANSICyanColor": (0.0, 1.0, 1.0),
        "ANSIMagentaColor": (1.0, 0.0, 1.0),
        "ANSIWhiteColor": (0.8, 0.8, 0.8),
        "ANSIBrightBlackColor": (0.5, 0.5, 0.5),
        "ANSIBrightRedColor": (1.0, 0.0, 0.0),
        "ANSIBrightGreenColor": (0.0, 1.0, 0.0),
        "ANSIBrightYellowColor": (1.0, 1.0, 0.0),
        "ANSIBrightBlueColor": (0.0, 0.0, 1.0),
        "ANSIBrightCyanColor": (0.0, 1.0, 1.0),
        "ANSIBrightMagentaColor": (1.0, 0.0, 1.0),
        "ANSIBrightWhiteColor": (1.0, 1.0, 1.0),
    }

    # Object index constants
    NSCOLOR_CLASS = 4
    NSCOLORSPACE_CLASS = 10
    SRGB_COLORSPACE = 9
    PMTTHEME_CLASS = 28

    def make_calibrated_color(r, g, b):
        """Create NSColor with NSColorSpace=1 (calibrated RGB)."""
        return {
            "$class": uid(NSCOLOR_CLASS),
            "NSColorSpace": 1,
            "NSRGB": f"{r} {g} {b}\x00".encode("ascii"),
        }

    def make_device_color(r, g, b):
        """Create NSColor with NSColorSpace=2 (device RGB, sRGB)."""
        return {
            "$class": uid(NSCOLOR_CLASS),
            "NSColorSpace": 2,
            "NSCustomColorSpace": uid(SRGB_COLORSPACE),
            "NSRGB": f"{r} {g} {b}\x00".encode("ascii"),
        }

    # ANSI color keys in object order (indices 11-26)
    ansi_order = [
        "ANSIBlackColor",
        "ANSIRedColor",
        "ANSIGreenColor",
        "ANSIBlueColor",
        "ANSICyanColor",
        "ANSIMagentaColor",
        "ANSIYellowColor",
        "ANSIWhiteColor",
        "ANSIBrightBlackColor",
        "ANSIBrightRedColor",
        "ANSIBrightGreenColor",
        "ANSIBrightBlueColor",
        "ANSIBrightCyanColor",
        "ANSIBrightMagentaColor",
        "ANSIBrightYellowColor",
        "ANSIBrightWhiteColor",
    ]

    # Build root dict
    root_dict = {
        "$class": uid(PMTTHEME_CLASS),
        "name": uid(2),
        "identifier": uid(27),
        "backgroundColor": uid(3),
        "backgroundColorDark": uid(0),
        "textColor": uid(5),
        "textColorDark": uid(0),
        "boldTextColor": uid(6),
        "boldTextColorDark": uid(0),
        "selectionColor": uid(7),
        "selectionColorDark": uid(0),
        "cursorColor": uid(8),
        "cursorColorDark": uid(0),
        "locked": False,
        "opacity": 1.0,
        "opacityDark": 1.0,
        "showTextGlow": False,
        "useBoldFonts": True,
        "useBoldFontsDark": True,
        "usesSeparateDarkTheme": False,
    }
    for i, key in enumerate(ansi_order):
        root_dict[key] = uid(11 + i)
        root_dict[key + "Dark"] = uid(0)

    identifier = str(uuid.uuid4()).upper()

    # Object graph layout:
    #  0: $null
    #  1: root PMTTheme dict
    #  2: name string
    #  3: backgroundColor  (NSColorSpace=1)
    #  4: NSColor class
    #  5: textColor         (NSColorSpace=1)
    #  6: boldTextColor     (NSColorSpace=1)
    #  7: selectionColor    (NSColorSpace=1)
    #  8: cursorColor       (NSColorSpace=1)
    #  9: sRGB color space  (NSID=4)
    # 10: NSColorSpace class
    # 11-26: ANSI colors    (NSColorSpace=2)
    # 27: identifier UUID
    # 28: PMTTheme class
    objects = [
        "$null",
        root_dict,
        name,
        make_calibrated_color(*bg),
        {"$classname": "NSColor", "$classes": ["NSColor", "NSObject"]},
        make_calibrated_color(*fg),
        make_calibrated_color(*bold),
        make_calibrated_color(*sel),
        make_calibrated_color(*cursor),
        {"$class": uid(NSCOLORSPACE_CLASS), "NSID": 4},
        {"$classname": "NSColorSpace", "$classes": ["NSColorSpace", "NSObject"]},
    ]

    for key in ansi_order:
        r, g, b = colors.get(key, ansi_defaults[key])
        objects.append(make_device_color(r, g, b))

    objects.append(identifier)
    objects.append({
        "$classname": "PMTTheme",
        "$classes": ["PMTTheme", "PMTThemeNotSynced", "SNKObject", "NSObject"],
    })

    theme = {
        "$archiver": "NSKeyedArchiver",
        "$version": 100000,
        "$top": {"root": uid(1)},
        "$objects": objects,
    }

    if output_path is None:
        output_path = Path(terminal_path).with_suffix(".prompttheme")

    with open(output_path, "wb") as f:
        plistlib.dump(theme, f, fmt=plistlib.FMT_XML)

    print(f"Created: {output_path}")
    print(f"  Name: {name}")


def main():
    parser = argparse.ArgumentParser(
        description="Convert macOS Terminal theme (.terminal) to Prompt theme (.prompttheme)",
    )
    parser.add_argument("input", help="Path to .terminal file")
    parser.add_argument(
        "-o",
        "--output",
        help="Output .prompttheme path (default: same basename with .prompttheme)",
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
            hex_color = "#{:02x}{:02x}{:02x}".format(
                int(r * 255), int(g * 255), int(b * 255),
            )
            print(f"  {key:30s} {hex_color}")
        sys.exit(0)

    convert(args.input, args.output)


if __name__ == "__main__":
    main()
