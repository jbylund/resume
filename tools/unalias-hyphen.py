#!/usr/bin/env python3
"""Drop the U+00AD and U+2010 cmap entries from a font, so that PDF text
extraction yields an ASCII hyphen.

Why this exists
---------------
XeTeX embeds subset fonts with Identity-H encoding, so the PDF text layer is a
sequence of raw glyph IDs rather than characters. Every extractor therefore has
to map glyphs back to Unicode through the font's ToUnicode CMap, which
xdvipdfmx builds by inverting the font's cmap table.

Lato maps three codepoints -- U+002D HYPHEN-MINUS, U+00AD SOFT HYPHEN and
U+2010 HYPHEN -- onto a single `hyphen` glyph. Inverting that is ambiguous, and
xdvipdfmx resolves it to the highest codepoint, U+2010. The result is a PDF that
looks perfect and whose text layer contains no ASCII hyphens at all: a literal
search for a phone number or for `multi-tenant` finds nothing, and neither does
`\\d{3}-\\d{3}-\\d{4}`.

Removing the two aliases leaves U+002D as the only codepoint reaching the glyph,
so the inversion is unambiguous. Rendering is untouched -- the glyph itself and
all its metrics are unchanged, and this document never types either alias, so
nothing loses a mapping it needed.

Note that `\\XeTeXgenerateactualtext=1` is not a substitute. It fixes
poppler/pdftotext, which honours /ActualText, but pdfminer and pypdf ignore
/ActualText and read ToUnicode -- so the keywords still miss in exactly the
libraries an ATS is most likely to use.

Run at build time rather than committing the patched fonts: Lato is licensed
under the OFL with Reserved Font Name "Lato", so a modified copy could not be
redistributed under that name. Embedding a subset in a PDF is expressly allowed.
"""

import sys
from pathlib import Path

from fontTools.ttLib import TTFont

# U+00AD SOFT HYPHEN, U+2010 HYPHEN -- both alias the U+002D glyph in Lato
ALIASES = (0x00AD, 0x2010)


def unalias(src: Path, dst: Path) -> None:
    font = TTFont(src)
    hyphen = font.getBestCmap().get(0x2D)
    if hyphen is None:
        sys.exit(f"{src.name}: no glyph for U+002D, refusing to guess")

    removed = set()
    for table in font["cmap"].tables:
        for codepoint in ALIASES:
            # only drop an alias that really does share the U+002D glyph, so this
            # stays a no-op on a font that maps them to distinct glyphs
            if table.cmap.get(codepoint) == hyphen:
                del table.cmap[codepoint]
                removed.add(codepoint)

    dst.parent.mkdir(parents=True, exist_ok=True)
    font.save(dst)
    detail = ", ".join(f"U+{c:04X}" for c in sorted(removed)) or "nothing to remove"
    print(f"  {src.name}: {detail}")


def main() -> None:
    if len(sys.argv) != 3:
        sys.exit(f"usage: {sys.argv[0]} <src-dir> <dst-dir>")
    src_dir, dst_dir = Path(sys.argv[1]), Path(sys.argv[2])
    fonts = sorted(src_dir.glob("*.ttf"))
    if not fonts:
        sys.exit(f"no .ttf files in {src_dir}")
    for font in fonts:
        unalias(font, dst_dir / font.name)


if __name__ == "__main__":
    main()
