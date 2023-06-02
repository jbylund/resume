BASENAME := joseph_bylund
OUTPUTNAME := $(BASENAME).$(DATE).pdf
OUTPUTNAME := $(BASENAME).pdf
TEXCOMMAND := $(shell type -a xelatex | xargs -n1 echo | grep '/' | head -n 1)
BIBCOMMAND := $(shell type -a bibtex | xargs -n1 echo | grep '/' | head -n 1)

all: joseph_bylund.pdf

view : $(OUTPUTNAME)
	@timeout 30 evince $(shell ls -t *.pdf|head -n 1) || true

DejaVuSans.sty:
	wget https://ctan.math.utah.edu/ctan/tex-archive/fonts/dejavu/tex/DejaVuSans.sty || \
		curl -O https://ctan.math.utah.edu/ctan/tex-archive/fonts/dejavu/tex/DejaVuSans.sty

/usr/share/texlive/texmf-dist/tex/latex/base/article.cls:
	ls /usr/share/texlive/texmf-dist/tex/latex/base/article.cls 2>/dev/null || \
		sudo -H apt-get install -y texlive-latex-base || true
	ls /usr/share/texlive/texmf-dist/tex/latex/base/article.cls

# map pathname to fullname... kind of gross...
$(TEXCOMMAND):
	xelatex --version || sudo -H apt-get install -y texlive-xetex

$(FDUPES):
	fdupes --version || apt-get install fdupes

$(OUTPUTNAME) : $(TEXCOMMAND) $(FDUPES) mycontents.tex resume_zero_start.tex makefile resume.bib DejaVuSans.sty
	@echo "Pass 1 of 3..."
	@true | $(TEXCOMMAND) -jobname $(BASENAME) resume_zero_start.tex > /dev/null
	@echo "Pass 2 of 3..."
	@$(BIBCOMMAND) $(BASENAME) > /dev/null || true
	@true | $(TEXCOMMAND) -jobname $(BASENAME) resume_zero_start.tex > /dev/null
	@echo "Pass 3 of 3..."
	@$(TEXCOMMAND) -jobname $(BASENAME) resume_zero_start.tex > /dev/null
	@/bin/rm -rf *.log *.aux *.bbl *.blg joseph_bylund.out

clean :
	@/bin/rm -f $(OUTPUTNAME)

.PHONY : clean view
