BASENAME := joseph_bylund
# One PDF per header variant; the body is shared. Adding a variant means adding a word here
# and a sections/header_<name>.tex to match.
VARIANTS := boston dublin
PDFS := $(foreach v,$(VARIANTS),$(BASENAME).$(v).pdf)
# command -v rather than type -a: portable to /bin/sh (dash) on CI runners
TEXCOMMAND := $(shell command -v xelatex)

# texmf/ vendors the small distribution files this document needs that otherwise
# only arrive with enormous texlive packages -- 172KB here in place of 834MB of
# downloads. See texmf/README.md for provenance.
export TEXINPUTS := $(CURDIR)/texmf//:
export TFMFONTS := $(CURDIR)/texmf//:
VENDORED := $(wildcard texmf/*.sty texmf/*.def texmf/*.tfm)
# mycontents.tex is a manifest of \input lines; the prose lives in sections/
SECTIONS := $(wildcard sections/*.tex)

# fonts/lato/ holds Lato as it ships from upstream; the build copies in
# build/fonts/ have two cmap aliases stripped so the PDF text layer extracts
# ASCII hyphens instead of U+2010. See tools/unalias-hyphen.py for why, and
# fonts/README.md for provenance. Patched at build time rather than committed
# because Lato's OFL reserves the name.
LATO_SRC := $(wildcard fonts/lato/*.ttf)
# a stamp file, not the .ttf list: one invocation patches every face, and
# grouped targets (`&:`) need GNU Make 4.3 while macOS still ships 3.81
LATO_STAMP := build/fonts/.patched

all: $(PDFS)

view : $(PDFS)
	@timeout 30 evince $(shell ls -t *.pdf|head -n 1) || true

/usr/share/texlive/texmf-dist/tex/latex/base/article.cls:
	ls /usr/share/texlive/texmf-dist/tex/latex/base/article.cls 2>/dev/null || \
		sudo -H apt-get install -y texlive-latex-base || true
	ls /usr/share/texlive/texmf-dist/tex/latex/base/article.cls

# map pathname to fullname... kind of gross...
$(TEXCOMMAND):
	xelatex --version || sudo -H apt-get install -y texlive-xetex

$(FDUPES):
	fdupes --version || apt-get install fdupes

$(LATO_STAMP) : $(LATO_SRC) tools/unalias-hyphen.py
	@echo "Patching font cmaps..."
	python3 tools/unalias-hyphen.py fonts/lato build/fonts
	@touch $@

# $* is the variant name, so one rule builds them all. \headerfile is set on the command
# line rather than in the source, which keeps the variant out of the committed .tex files.
$(BASENAME).%.pdf : FORCE $(TEXCOMMAND) $(FDUPES) mycontents.tex $(SECTIONS) resume_zero_start.tex makefile $(VENDORED) $(LATO_STAMP)
	@mv -f $@ $@.bak 2>/dev/null || true
	@echo "Building $* -- pass 1 of 2..."
	true | $(TEXCOMMAND) -jobname $(BASENAME).$* '\def\headerfile{sections/header_$*}\input{resume_zero_start.tex}'
	@echo "Building $* -- pass 2 of 2..."
	$(TEXCOMMAND) -jobname $(BASENAME).$* '\def\headerfile{sections/header_$*}\input{resume_zero_start.tex}' > /dev/null
	@/bin/rm -rf *.log *.aux *.out
	ls $@

clean :
	@/bin/rm -f $(PDFS)
	@/bin/rm -rf build

.PHONY : clean view FORCE

# Always rebuild, via a FORCE prerequisite rather than .PHONY: make skips implicit-rule search
# for phony targets, so marking the PDFs phony silently stops the pattern rule above from ever
# firing -- you get a stale PDF and no error. This matters in CI, where the tracked PDFs are
# checked out with the same mtime as the sources.
#
# Defined last on purpose: the first target in a makefile becomes the default goal, and a FORCE
# with no recipe sitting at the top makes `make` quietly do nothing.
FORCE:
