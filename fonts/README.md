# Vendored fonts

Lato, the resume's only typeface, as it ships from upstream. `\setmainfont` loads it
by path rather than by system font name, which fixes two things at once.

## Why it is vendored

**The text layer used to depend on the build machine.** `\setmainfont{Lato}` resolved
through fontconfig, so the PDF's embedded font — and therefore its extractable text —
was whatever Lato the machine happened to have. CI apt-got `fonts-lato`; a local build
picked up a Homebrew cask or failed outright. Pinning the files here makes the build
reproducible and removes the `fonts-lato` dependency from the workflow.

**Local builds work on a bare TeX Live.** No font install step.

## Provenance

Downloaded from [google/fonts](https://github.com/google/fonts/tree/main/ofl/lato),
`ofl/lato`, which is the canonical distribution point. All four faces report
`Version 2.015; 2015-08-06; http://www.latofonts.com/`.

| file | sha256 |
| --- | --- |
| `Lato-Regular.ttf` | `d636e4683231f931eda222d588e944d082bfd3bdba02f928bee461c0f185b251` |
| `Lato-Bold.ttf` | `8a0aace75d33794eece4b28187bfc1df0bbd2888b5d8a56e01788c8d65d16be1` |
| `Lato-Italic.ttf` | `e399c44efe1387100531d26c7e4800c5d12251b890d6654a3098c7c679cb1786` |
| `Lato-BoldItalic.ttf` | `62c1b7f0d2e74b45960154c3520efc337b553db0961bfdc950d5618334596cc8` |

Note that CTAN's `lato` package ships the same *version* as different *builds* — the
files are not byte-identical to these. Either works; the checksums above are what is
committed.

The document never sets bold and italic together, so `Lato-BoldItalic.ttf` is
currently unused. It is vendored anyway, so that adding a bold-italic run later gets
the real face instead of a synthesised slant.

## These files are not what gets embedded

`make` does not hand these to XeTeX. It runs
[`tools/unalias-hyphen.py`](../tools/unalias-hyphen.py) over them into `build/fonts/`
first, stripping two `cmap` entries so that PDF text extraction yields an ASCII
hyphen rather than U+2010. Without that step the resume's text layer contains no
ASCII hyphens at all and an ATS matches neither the phone number nor `multi-tenant`.
That script's docstring explains the mechanism; the workflow's *Check text layer*
step guards the result, because the failure is invisible on the page.

The patch happens at build time, and `build/` is git-ignored, on purpose: Lato is
licensed under the OFL **with Reserved Font Name "Lato"**, so a modified copy could
not be redistributed under that name. Embedding a subset into a PDF is expressly
permitted, which is all the build does.

## Licence

SIL Open Font License 1.1 — see [`lato/OFL.txt`](lato/OFL.txt).
Copyright (c) 2010-2014 by tyPoland Lukasz Dziedzic.

See [`texmf/README.md`](../texmf/README.md) for the vendored TeX macro files, which
are a separate matter.
