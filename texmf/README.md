# Vendored TeX files

These are unmodified files from TeX Live, copied here so the resume builds against a
minimal TeX Live install. Each one is a few KB but otherwise only ships inside a very
large Debian package:

| file | TeX Live package | Debian package | avoided in CI? |
| --- | --- | --- | --- |
| `pzdr.tfm` | `zapfding` | `texlive-fonts-recommended` (61 MB) | yes |
| `ulem.sty` | `ulem` | `texlive-plain-generic` (24 MB) | yes |
| `enumitem.sty` | `enumitem` | `texlive-latex-extra` | no |
| `datetime.sty`, `datetime-defaults.sty` | `datetime` | `texlive-latex-extra` | no |
| `fmtcount.sty`, `fcnumparser.sty`, `fcprefix.sty`, `fc-english.def` | `fmtcount` | `texlive-latex-extra` | no |

Note the last three rows. `texlive-xetex` *depends* on `texlive-latex-extra`, so
those files arrive in CI whether or not they are vendored here -- an earlier version
of this file claimed the whole set replaced 202 MB of downloads, which was wrong. The
mistake came from asking which package the files live in (`dpkg -L`) rather than
whether that package would be installed anyway.

They are kept regardless, because they make the document build on a minimal TeX Live
such as TinyTeX, where `texlive-latex-extra` has no equivalent, and because vendoring
pins the versions. The two files that genuinely keep a package out of CI are
`pzdr.tfm` and `ulem.sty`.

The typeface itself is *not* vendored: Lato's four faces are 2.7 MB, which is a
different proposition from a 50 KB style file, so CI installs the 3 MB `fonts-lato`
package instead. A local build needs Lato present on the system
(`brew install --cask font-lato` on macOS); without it `fontspec` stops with a clear
"font not found" rather than silently substituting.

`ulem.sty` provides `\uline`, used to underline links in a way that survives a line
break (plain `\underline` does not). It is Donald Arseneau's, freely redistributable
with its copyright notice intact, rather than LPPL like the rest.

`pzdr.tfm` is wanted by hyperref's xetex driver for link annotations; the `fmtcount`
files are a dependency of `datetime`, which supplies the `\monthname` in the
"Last updated" line.

The makefile puts this directory on `TEXINPUTS` and `TFMFONTS`, so a local `xelatex`
finds these before consulting the system tree.

Copied from Debian `texlive-latex-extra` / `texlive-fonts-recommended` version
`2023.20240207-1` (TeX Live 2023). All are LPPL-licensed and redistributable
unmodified. To refresh, re-copy from a machine with the full packages installed:

```sh
for f in $(ls *.sty *.def *.tfm); do cp "$(kpsewhich "$f")" .; done
```

The exact set was derived by building with the full packages installed and
intersecting `xelatex -recorder` output (`.fls`) with `dpkg -L`, so it is the precise
closure this document touches — adding a package to the preamble may require adding
files here.
