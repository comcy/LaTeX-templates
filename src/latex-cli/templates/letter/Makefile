LATEX_ENGINE = <<ENGINE>>
SOURCE = <<TYPE>>.tex
OUT = <<TYPE>>.pdf

all: $(OUT)

$(OUT): $(SOURCE)
	$(LATEX_ENGINE) $(SOURCE)

clean:
	rm -f *.aux *.log *.out *.pdf
