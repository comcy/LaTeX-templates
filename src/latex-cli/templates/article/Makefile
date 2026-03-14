LATEX_ENGINE = <<ENGINE>>
SOURCE = <<TYPE>>.tex
OUT = <<TYPE>>.pdf

all: $(OUT)

$(OUT): $(SOURCE) sample.bib
	$(LATEX_ENGINE) $(SOURCE)
	biber <<TYPE>>
	$(LATEX_ENGINE) $(SOURCE)
	$(LATEX_ENGINE) $(SOURCE)

clean:
	rm -f *.aux *.log *.out *.pdf *.bcf *.run.xml *.bbl *.blg
