#!/usr/bin/env python3
"""Find the \\scalepct values at which the resume fits in the page limit.

Why this exists
---------------
\\scalepct in resume_zero_start.tex scales every font size, and the page count
is a step function of it: nothing changes over a range of values, then the
document drops a page. Its comment block records those thresholds by hand, and
they go stale whenever content is added or sections are reordered. This builds
the document at each value and prints the pages and how full the last page is,
so the threshold can be re-measured in one command after an edit.

It works on a copy of the tree in a temporary directory, so the worktree, the
committed PDFs and the .bak files are not touched.

Usage
-----
    python3 tools/sweep-scalepct.py                    # 98 down to 88, boston
    python3 tools/sweep-scalepct.py 96 94 92           # chosen values
    python3 tools/sweep-scalepct.py --variant dublin
    python3 tools/sweep-scalepct.py --max-pages 3      # default: the CI limit

Needs make, xelatex and poppler (pdfinfo, pdftotext), as the normal build does.
Exit status is 0 if the value currently set in resume_zero_start.tex fits in
--max-pages, else 1, so it can also be used as a check.
"""

import argparse
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SOURCE = "resume_zero_start.tex"
SCALE_RE = re.compile(r"(\\newcommand\{\\scalepct\}\{)(\d+)(\})")
# the CI workflow's limit; read from it so the two cannot drift apart
WORKFLOW = ROOT / ".github/workflows/build-resume.yml"


def ci_max_pages() -> int:
    m = re.search(r"MAX_PAGES=(\d+)", WORKFLOW.read_text()) if WORKFLOW.exists() else None
    return int(m[1]) if m else 3


def current_scale() -> int:
    m = SCALE_RE.search((ROOT / SOURCE).read_text())
    if m is None:
        sys.exit(f"no \\newcommand{{\\scalepct}} found in {SOURCE}")
    return int(m[2])


def copy_tree(dest: Path) -> None:
    shutil.copytree(
        ROOT, dest, dirs_exist_ok=True,
        ignore=shutil.ignore_patterns(".git", "build", "*.pdf", "*.bak", ".DS_Store", ".claude"),
    )  # fmt: skip


def build(tree: Path, scale: int, variant: str) -> tuple[int, int]:
    """Build one variant at one scale. Returns (pages, text lines on the last page)."""
    src = tree / SOURCE
    src.write_text(SCALE_RE.sub(rf"\g<1>{scale}\g<3>", src.read_text()))
    pdf = tree / f"joseph_bylund.{variant}.pdf"
    pdf.unlink(missing_ok=True)
    r = subprocess.run(["make", pdf.name], cwd=tree, capture_output=True, text=True)
    if not pdf.exists():
        sys.exit(f"build failed at scalepct={scale}:\n{r.stdout[-1500:]}{r.stderr[-1500:]}")
    info = subprocess.run(["pdfinfo", str(pdf)], capture_output=True, text=True, check=True).stdout
    pages = int(re.search(r"Pages:\s+(\d+)", info)[1])
    text = subprocess.run(
        ["pdftotext", "-f", str(pages), "-l", str(pages), "-layout", str(pdf), "-"],
        capture_output=True, text=True, check=True,
    ).stdout  # fmt: skip
    return pages, sum(1 for line in text.splitlines() if line.strip())


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    ap.add_argument("values", nargs="*", type=int, help="\\scalepct values (default: 98 down to 88)")
    ap.add_argument("--variant", default="boston", help="header variant to build (default: boston)")
    ap.add_argument("--max-pages", type=int, default=ci_max_pages(), help="page limit (default: CI's)")
    a = ap.parse_args()

    now = current_scale()
    values = sorted(set(a.values or range(88, 99)) | {now}, reverse=True)
    print(f"variant {a.variant}, limit {a.max_pages} pages, set in {SOURCE}: {now}")
    print(f"{'scalepct':>8}  {'pages':>5}  {'last-page lines':>15}")

    fits = []
    with tempfile.TemporaryDirectory(prefix="sweep-scalepct-") as tmp:
        tree = Path(tmp)
        copy_tree(tree)
        for v in values:
            pages, last = build(tree, v, a.variant)
            ok = pages <= a.max_pages
            if ok:
                fits.append(v)
            marks = ("  <- set" if v == now else "") + ("" if ok else "  over limit")
            print(f"{v:>8}  {pages:>5}  {last:>15}{marks}")

    if fits:
        print(f"\nlargest value that fits: {max(fits)}")
    else:
        print("\nnothing in this range fits: prune content or widen the range")
    return 0 if now in fits else 1


if __name__ == "__main__":
    sys.exit(main())
