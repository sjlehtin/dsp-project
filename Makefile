all: project_report.pdf

# you need to run the matlab/octave scripts to generate the images
# before building the document.
project_report.pdf: main.tex q1_spectrogram.png Makefile q1.tex q2.tex project_bibliography.bib q1.m q2.m
	pdflatex main
	bibtex main
	pdflatex main
	pdflatex main
	@cp main.pdf $@

clean:
	@rm *.aux *.log *.bbl *.blg *.out
	@rm project_report.pdf

.PHONY: clean
