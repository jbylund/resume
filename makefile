BASENAME := joseph_bylund
#DATE := $(shell date +%s)
OUTPUTNAME := $(BASENAME).$(DATE).pdf
OUTPUTNAME := $(BASENAME).pdf
TEXCOMMAND := xelatex
BIBCOMMAND := bibtex

all: /var/www/html/joseph_bylund.pdf

view : $(OUTPUTNAME)
	@timeout 30 evince $(shell ls -t *.pdf|head -n 1) || true

DejaVuSans.sty:
	wget http://ctan.mackichan.com/fonts/dejavu/tex/DejaVuSans.sty

$(OUTPUTNAME) : mycontents.tex resume_zero_start.tex makefile resume.bib DejaVuSans.sty /usr/share/texlive/texmf-dist/tex/latex/base/article.cls
	$(TEXCOMMAND) -jobname $(BASENAME) resume_zero_start.tex
	-$(BIBCOMMAND) $(BASENAME)
	$(TEXCOMMAND) -jobname $(BASENAME) resume_zero_start.tex
	$(TEXCOMMAND) -jobname $(BASENAME) resume_zero_start.tex
	/bin/rm -rf *.log *.aux *.bbl *.blg *~
#	perl -pi -e "s/.*?ModDate.*/\/ModDate (D:20130418152511-04'00')/" $(BASENAME).pdf
#	perl -pi -e "s/.*?CreationDate.*/\/CreationDate (D:20130418152541-04'00')/" $(BASENAME).pdf
#	perl -pi -e "s/.*?\/ID.*/\/ID [<0535B734E397B655F1D0DD37FD8A8CF9> <0535B734E397B655F1D0DD37FD8A8CF9>]/" $(BASENAME).pdf
#	cp -f $(BASENAME).pdf $(OUTPUTNAME)
	fdupes . -q -d -N

/var/www/html/joseph_bylund.pdf: $(OUTPUTNAME)
	cp $(OUTPUTNAME) /var/www/html/joseph_bylund.pdf

clean :
	@/bin/rm -f $(OUTPUTNAME)

.PHONY : clean view


