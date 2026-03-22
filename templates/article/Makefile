LATEX_ENGINE = <<ENGINE>>
SOURCE = <<TYPE>>.tex
OUT = <<TYPE>>.pdf
BIB_DIR = bib
BIB_FILE = $(BIB_DIR)/sample.bib

all: $(OUT)

$(OUT): $(SOURCE) $(BIB_FILE)
	@if ! command -v biber > /dev/null; then \
		echo "Error: biber not found. Please install biber."; \
		exit 1; \
	fi
	@if ! kpsewhich biblatex.sty > /dev/null; then \
		echo "Error: biblatex.sty not found. Please install biblatex (texlive-bibtexextra on Arch)."; \
		exit 1; \
	fi
	$(LATEX_ENGINE) $(SOURCE)
	biber <<TYPE>>
	$(LATEX_ENGINE) $(SOURCE)
	$(LATEX_ENGINE) $(SOURCE)

clean:
	rm -f *.aux *.log *.out *.pdf *.bcf *.run.xml *.bbl *.blg *.blx.bib *.lof *.lot *.toc
