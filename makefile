BASENAME := joseph_bylund
#DATE := $(shell date +%s)
OUTPUTNAME := $(BASENAME).$(DATE).pdf
OUTPUTNAME := $(BASENAME).pdf
TEXCOMMAND := xelatex
BIBCOMMAND := bibtex

all: joseph_bylund.pdf

view : $(OUTPUTNAME)
	@timeout 30 evince $(shell ls -t *.pdf|head -n 1) || true

DejaVuSans.sty:
	wget http://mirrors.ctan.org/fonts/dejavu/tex/DejaVuSans.sty


apt-get-update:
	sudo -H apt-get update

/usr/share/texlive/texmf-dist/tex/latex/base/article.cls: apt-get-update
	ls /usr/share/texlive/texmf-dist/tex/latex/base/article.cls || sudo -H apt-get install -y texlive-latex-base || true
	ls /usr/share/texlive/texmf-dist/tex/latex/base/article.cls

xelatex: apt-get-update
	xelatex --version || sudo -H apt-get install -y texlive-xetex

fdupes: apt-get-update
	fdupes --version || apt-get install fdupes

$(OUTPUTNAME) : $(TEXCOMMAND) fdupes mycontents.tex resume_zero_start.tex makefile resume.bib DejaVuSans.sty /usr/share/texlive/texmf-dist/tex/latex/base/article.cls
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

#/var/www/html/joseph_bylund.pdf: $(OUTPUTNAME)
#	cp $(OUTPUTNAME) /var/www/html/joseph_bylund.pdf

clean :
	@/bin/rm -f $(OUTPUTNAME)

.PHONY : clean view


