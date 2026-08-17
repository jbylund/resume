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

$(OUTPUTNAME) : $(TEXCOMMAND) $(FDUPES) mycontents.tex resume_zero_start.tex publications.tex makefile $(VENDORED)
	@mv -f $(OUTPUTNAME) $(OUTPUTNAME).bak 2>/dev/null || true
	@echo "Pass 1 of 2..."
	true | $(TEXCOMMAND) -vv -jobname $(BASENAME) resume_zero_start.tex
	@echo "Pass 2 of 2..."
	$(TEXCOMMAND) -jobname $(BASENAME) resume_zero_start.tex > /dev/null
	@/bin/rm -rf *.log *.aux *.out
	ls $(OUTPUTNAME)

clean :
	@/bin/rm -f $(OUTPUTNAME)

.PHONY : clean view
