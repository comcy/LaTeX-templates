LATEX_ENGINE = <<ENGINE>>
SOURCE = <<TYPE>>.tex
OUT = <<TYPE>>.pdf
BIB_DIR = bib
BIB_FILE = $(BIB_DIR)/sample.bib

all: $(OUT)

$(OUT): $(SOURCE) $(BIB_FILE)
	$(LATEX_ENGINE) $(SOURCE)
	biber <<TYPE>>
	$(LATEX_ENGINE) $(SOURCE)
	$(LATEX_ENGINE) $(SOURCE)

clean:
	rm -f *.aux *.log *.out *.pdf *.bcf *.run.xml *.bbl *.blg *.blx.bib *.lof *.lot *.toc
