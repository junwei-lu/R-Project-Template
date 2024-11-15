# Makefile for data analysis pipeline

# Variables
REPO_NAME = your-repo-name
GITHUB_USER = your-github-username
BRANCH = main
SETUP_RENV =true
# set to false to skip renv setup


# Declare phony targets
.PHONY: all init sync push renv_init renv_update data_analysis clean_data analysis make_figures report help

# Default target
all: data_analysis push

# Initialize a local Git repository and push to GitHub
init:
	git init
	git add .
	git commit -m "Initial commit"
	@if [ "$(SETUP_RENV)" = "true" ]; then \
		make renv_init; \
	fi
	make init_repo

init_repo:
	gh repo create $(GITHUB_USER)/$(REPO_NAME) --private --source=. --remote=origin
	git push -u origin $(BRANCH)

# Sync with Github
sync:
	git pull origin $(BRANCH)
	@if [ "$(SETUP_RENV)" = "true" ]; then \
		Rscript -e "renv::restore()"; \
	fi

# Push to GitHub
push:
	git pull origin $(BRANCH)
	@if [ "$(SETUP_RENV)" = "true" ]; then \
		Rscript -e "renv::snapshot()"; \
	fi
	git add .
	git commit -m "Update analysis and data"
	git push origin $(BRANCH)

# R environment setup with renv
renv_init:
	Rscript -e "if (!requireNamespace('renv', quietly = TRUE)) { options(repos = c(CRAN = 'https://cloud.r-project.org')); install.packages('renv') }"
	Rscript -e "renv::init()"
	Rscript -e "renv::install(c('backports', 'callr', 'cli', 'cpp11', 'crayon', 'data.table', 'digest', 'farver', 'fs', 'ggplot2', 'glue', 'gtable', 'jsonlite', 'lifecycle', 'magrittr', 'pillar', 'pkgconfig', 'purrr', 'R6', 'rlang', 'stringr', 'tibble', 'vctrs', 'withr', 'xml2'))"
	git add .
	git commit -m "Initialize R environment with renv"

renv_update:
	Rscript -e "renv::snapshot()"
	git add .
	git commit -m "Update renv snapshot"

# Data analysis workflow
data_analysis: clean_data analysis make_figures report

clean_data:
	Rscript src/R/00_clean_data.R

analysis: 
	Rscript src/R/01_analysis.R

make_figures: 
	Rscript src/R/02_make_figures.R

report: 
	Rscript src/R/03_report.Rmd

# Help target
help:
	@echo "Available targets:"
	@echo "  all          - Run the complete workflow"
	@echo "  init         - Initialize Git repository and push to GitHub"
	@echo "  sync         - Sync local changes with GitHub and restore R environment"
	@echo "  push         - Snapshot R environment and push changes to GitHub"
	@echo "  renv_init    - Initialize R environment with renv"
	@echo "  renv_update  - Update renv snapshot"
	@echo "  data_analysis- Run the complete data analysis workflow"
	@echo "  clean_data   - Run data cleaning script"
	@echo "  analysis     - Run analysis script (requires clean data)"
	@echo "  make_figures - Generate figures (requires analysis)"
	@echo "  report       - Generate final report (requires analysis and figures)"
	@echo "  help         - Show this help message"
