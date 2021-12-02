BASENAME := joseph_bylund
#DATE := $(shell date +%s)
OUTPUTNAME := $(BASENAME).$(DATE).pdf
OUTPUTNAME := $(BASENAME).pdf
TEXCOMMAND := $(shell type -a xelatex | xargs -n1 echo | grep '/' | head -n 1)
BIBCOMMAND := $(shell type -a bibtex | xargs -n1 echo | grep '/' | head -n 1)
FDUPES := $(shell type -a fdupes | xargs -n1 echo | grep '/' | head -n 1)

all: joseph_bylund.pdf

view : $(OUTPUTNAME)
	@timeout 30 evince $(shell ls -t *.pdf|head -n 1) || true

DejaVuSans.sty:
	wget http://mirrors.ctan.org/fonts/dejavu/tex/DejaVuSans.sty

/usr/share/texlive/texmf-dist/tex/latex/base/article.cls:
	ls /usr/share/texlive/texmf-dist/tex/latex/base/article.cls || sudo -H apt-get install -y texlive-latex-base || true
	ls /usr/share/texlive/texmf-dist/tex/latex/base/article.cls

# map pathname to fullname... kind of gross...
$(TEXCOMMAND):
	xelatex --version || sudo -H apt-get install -y texlive-xetex

$(FDUPES):
	fdupes --version || apt-get install fdupes

$(OUTPUTNAME) : $(TEXCOMMAND) $(FDUPES) mycontents.tex resume_zero_start.tex makefile resume.bib DejaVuSans.sty /usr/share/texlive/texmf-dist/tex/latex/base/article.cls
	true | $(TEXCOMMAND) -jobname $(BASENAME) resume_zero_start.tex
	$(BIBCOMMAND) $(BASENAME) || true
	true | $(TEXCOMMAND) -jobname $(BASENAME) resume_zero_start.tex
	$(TEXCOMMAND) -jobname $(BASENAME) resume_zero_start.tex
	/bin/rm -rf *.log *.aux *.bbl *.blg joseph_bylund.out
#	perl -pi -e "s/.*?ModDate.*/\/ModDate (D:20130418152511-04'00')/" $(BASENAME).pdf
#	perl -pi -e "s/.*?CreationDate.*/\/CreationDate (D:20130418152541-04'00')/" $(BASENAME).pdf
#	perl -pi -e "s/.*?\/ID.*/\/ID [<0535B734E397B655F1D0DD37FD8A8CF9> <0535B734E397B655F1D0DD37FD8A8CF9>]/" $(BASENAME).pdf
#	cp -f $(BASENAME).pdf $(OUTPUTNAME)
	$(FDUPES) . -q -d -N

#/var/www/html/joseph_bylund.pdf: $(OUTPUTNAME)
#	cp $(OUTPUTNAME) /var/www/html/joseph_bylund.pdf

clean :
	@/bin/rm -f $(OUTPUTNAME)

.PHONY : clean view


