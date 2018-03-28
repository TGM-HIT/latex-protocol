# colors
eR = \e[0m
ecB = \e[0;30m
ecR = \e[0;31m
ecG = \e[0;32m
ecO = \e[0;33m
ecP = \e[0;35m
ecC = \e[0;36m
# constants
LOG = false
BUILD = .
ERRLINES = 1

default:
	@echo -e "$(ecG)Decide $(eR)on a target"
ifdef f
	$(MAKE) file
else
	@echo -e "$(ecG)Run $(ecC)all $(eR)on $(ecP). $(eR)by default"
	$(MAKE) all
endif


latex:
	@echo -e "$(ecG)Make $(ecC)latex$(eR) for $(ecP)$(f)$(eR)"
ifneq (.,$(BUILD))
	@mkdir -p $(BUILD)
endif
	@latex -shell-escape -file-line-error -interaction=batchmode -output-directory=$(BUILD) $(f) || echo -e "$(ecR)Error running $(ecC)pdflatex$(ecR)!$(eR)"
	@grep ".*:[0-9]*:.*" $(BUILD)/$(f).log -A$(ERRLINES) && { false; } || { echo -e "$(ecG)Everything OK!$(eR)"; }


pdf:
	@echo -e "$(ecG)Make $(ecC)pdf$(eR) for $(ecP)$(f)$(eR)"
ifneq (.,$(BUILD))
	@mkdir -p $(BUILD)
endif
	@pdflatex -shell-escape -file-line-error -interaction=batchmode -output-directory=$(BUILD) $(f) || echo -e "$(ecR)Error running $(ecC)pdflatex$(ecR)!$(eR)"
	@grep ".*:[0-9]*:.*" $(BUILD)/$(f).log -A$(ERRLINES) && { false; } || { echo -e "$(ecG)Everything OK!$(eR)"; }


glossaries:
	@echo -e "$(ecG)Make $(ecC)glossaries$(eR) for $(ecP)$(f)$(eR)"
ifndef f
	@echo -e "$(ecR)No file $(eCP)f $(eCR)defined. $(eR)Try adding $(ecP)f=filename!$(eR)"; false
endif
	@makeglossaries -d $(BUILD) $(f)


glo:
	@echo -e "$(ecG)Run $(eR)target $(ecC)glo $(eR)on $(ecP)$(f)$(eR)"
ifndef f
	@echo -e "$(ecR)No file $(eCP)f $(eCR)defined.$(eR) Try adding $(ecP)f=filename!$(eR)"; false
endif
ifeq (,find $(BUILD)/$(f).glo)
	@echo -e "$(ecO)Skip $(ecC)makeglossaries $(eR)due to missing glossary file"; false
endif
	@echo -e "$(ecC)First$(eR) run for simple compilation"
	@$(MAKE) pdf
	@$(MAKE) glossaries
	@echo -e "$(ecC)First$(eR) progressive run for $(ecC)makeglossaries$(eR)"
	@$(MAKE) pdf

	@$(MAKE) clean


bibtex:
	@echo -e "$(ecG)Run $(ecC)bibtex$(eR) on $(ecP)bib$(eR) file at $(ecP)$(BUILD)$(eR)"
ifndef f
	@echo -e "$(ecR)No file $(eCP)f $(eCR)defined. $(eR)Try adding $(ecP)f=filename!$(eR)"; false
endif
ifneq (.,$(BUILD))
	@cp *.bib $(BUILD) || { echo -e "$(ecR)No bib file in directory$(eR)"; false; }
endif
	@-cd $(BUILD); bibtex $(f)


bib:
	@echo -e "$(ecG)Run $(eR)target $(ecC)bib $(eR)on $(ecP)$(f)$(eR)"
ifndef f
	@echo -e "$(ecR)No file $(eCP)f $(eCR)defined. $(eR)Try adding $(ecP)f=filename!$(eR)"; false
endif
ifeq (,find *.bib)
	@echo -e "$(ecO)Skip $(ecC)bibtex $(eR)due to missing bib file"; false
endif
	@echo -e "$(ecC)First$(eR) run for simple compilation"
	@$(MAKE) pdf
	$(MAKE) bibtex
	@echo -e "$(ecC)First$(eR) progressive run for $(ecC)bibtex$(eR)"
	@$(MAKE) pdf
	@echo -e "$(ecC)Second$(eR) progressive run for $(ecC)bibtex$(eR)"
	@$(MAKE) pdf

	@$(MAKE) clean


file:
	@echo -e "$(ecG)Run $(eR)target $(ecC)file $(eR)on $(ecP)$(f)$(eR)"
ifndef f
	@echo -e "$(ecR)No file $(eCP)f $(eCR)defined. $(eR)Try adding $(ecP)f=filename!$(eR)"
	@false
endif
	@echo -e "$(ecG)Build $(ecP)$(f) $(eR)into $(ecP)$(BUILD)$(eR)"
	@echo -e "$(ecC)First$(eR) run for simple compilation"
	@$(MAKE) pdf
ifneq (,find *.bib)
	$(MAKE) bibtex
	@echo -e "$(ecC)First$(eR) progressive run for $(ecC)bibtex$(eR)"
	$(MAKE) pdf
	@echo -e "$(ecC)Second$(eR) progressive run for $(ecC)bibtex$(eR)"
	$(MAKE) pdf
endif
ifneq (,find $(BUILD)/$(f).glo)
	@$(MAKE) glossaries
	@echo -e "$(ecC)First$(eR) progressive run for $(ecC)makeglossaries$(eR)"
	@$(MAKE) pdf
endif
	@$(MAKE) clean


pygments:
	@pygmentize -V && echo "Pygments is already installed!"; return false;
	@echo "$(ecO)WARNING:$(ecO) This target will check for a python runtime and pip install Pygments. \
		If you are using a unix-like system you might want to query your package manager first!"
	@python --version || echo "Minted requires the Python runtime. Go get it from https://www.python.org/downloads/"; return false;
	@echo "$(ecG)Installing $(ecC)Pygments$(eR) using pip"
	@pip install Pygments


FILES = $(filter-out $(wildcard lst*.tex glo*.tex _*.tex), $(wildcard *.tex))
all:
	@echo -e "$(ecG)Run $(eR)target $(ecC)all $(eR)on $(ecP).$(eR)"
	@echo -e "$(ecG)Found $(ecP)$(FILES)$(eR)" && $(foreach x, $(FILES), $(MAKE) file f="$(notdir $(basename $(x)))";)


.PHONY: clean
clean:
	@echo -e "$(ecG)Clean$(eR) up directory"
ifneq (.,$(BUILD))
	@echo -e "$(ecG)Get $(ecC)pdf $(eR)from $(ecP)$(BUILD)$(eR)"
	@cp $(BUILD)/$(f).pdf $(f).pdf || echo -e "$(ecR)Missing $(ecP)$(f).pdf$(eR)"
	rm -rf $(BUILD)
endif
	rm -rf *.acn *.acr *.alg *.aux *.bbl *.blg *-blx.bib *.bcf *.dvi *.glg *.glo *.gls *.glsdefs *.ist *.out *.run.xml *.synctex.gz *.toc *.xdy *.lot *.lof *.lol
	cd chapters; rm -f *.acn *.acr *.alg *.aux *.bbl *.blg *-blx.bib *.bcf *.dvi *.glg *.glo *.gls *.glsdefs *.ist *.log *.out *.run.xml *.synctex.gz *.toc *.xdy *.lot *.lof *.lol
ifneq (true, $(MINTED))
	rm -rf _minted*
endif
ifneq (true, $(LOG))
	rm -rf *.log
endif