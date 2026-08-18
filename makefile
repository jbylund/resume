BASENAME := joseph_bylund
OUTPUTNAME := $(BASENAME).$(DATE).pdf
OUTPUTNAME := $(BASENAME).pdf
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

.PHONY: $(OUTPUTNAME)

all: $(OUTPUTNAME)

view : $(OUTPUTNAME)
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

$(OUTPUTNAME) : $(TEXCOMMAND) $(FDUPES) mycontents.tex $(SECTIONS) resume_zero_start.tex makefile $(VENDORED) $(LATO_STAMP)
	@mv -f $(OUTPUTNAME) $(OUTPUTNAME).bak 2>/dev/null || true
	@echo "Pass 1 of 2..."
	true | $(TEXCOMMAND) -vv -jobname $(BASENAME) resume_zero_start.tex
	@echo "Pass 2 of 2..."
	$(TEXCOMMAND) -jobname $(BASENAME) resume_zero_start.tex > /dev/null
	@/bin/rm -rf *.log *.aux *.out
	ls $(OUTPUTNAME)

clean :
	@/bin/rm -f $(OUTPUTNAME)
	@/bin/rm -rf build

.PHONY : clean view
