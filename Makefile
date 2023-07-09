.PHONY: all build local localforce dotfiles project pkg tinytex clean cleanpkg cleantinytex cleanall coverage lint quarto clone

all: build latex quarto

build: pkg clean
	@echo \n\nTinyTex...\n\n
	@Rscript -e "rProject::TinyTex(\"${PWD}\", force = FALSE)"
	@echo \n\nStyling...\n\n
	@Rscript -e "rProject::Style(\"${PWD}\")"
	@echo \n\nLinting...\n\n
	@Rscript -e "rProject::Lint(\"${PWD}\")"
	@echo \n\nBuilding dependencies...\n\n
	@Rscript -e "rProject::DataProcess(\"${PWD}\")"
	@Rscript -e "rProject::DataAnalysis(\"${PWD}\")"
	@Rscript -e "rProject::Dependencies(\"${PWD}\")"
	@echo \n\nInitial build...\n\n
	@Rscript -e "rProject::Build(\"${PWD}\")"
	@echo \n\nPrecompiling vignettes...\n\n
	@Rscript -e "rProject::VignettesPrecompile(\"${PWD}\")"
	@echo \n\nBuilding project...\n\n
	@Rscript -e "rProject::Build(\"${PWD}\")"
	@echo \n\nBuilding README.md...\n\n
	@Rscript -e "rProject::ReadMe(\"${PWD}\")"
	@echo \n\nBuilding website...\n\n
	@Rscript -e "rProject::Site(\"${PWD}\")"
	@echo \n\nBuilding manual...\n\n
	@Rscript -e "rProject::Manual(\"${PWD}\", project = Sys.getenv(\"PROJECT\"))"
	@echo \n\nBuilding CITATION.cff...\n\n
	@Rscript -e "rProject::CFF(\"${PWD}\")"

cleanall: clean cleanpkg cleantinytex

dotfiles:
	@echo \n\nBuilding dotfiles...\n\n
	@Rscript -e "source('.setup/scripts/project.R') ; rProject::ConfigFiles(git_user)"

project:
	@echo \n\nBuilding project...\n\n
	@Rscript .setup/scripts/make-project.R ${PWD}

pkg: project dotfiles
	@echo \n\nInstalling packages...\n\n
	@Rscript .setup/scripts/make-packages.R ${PWD}

tinytex:
	@echo \n\nInstalling TinyTex...\n\n
	@Rscript -e "rProject::TinyTex(\"${PWD}\", force = TRUE)"

local: project
	@echo \n\nInstalling local applications...\n\n
	@Rscript -e "rProject::InstallLocal(all = TRUE)"
	@Rscript .setup/scripts/make-config.R ${PWD}

localforce: project
	@echo \n\nInstalling local applications...\n\n
	@Rscript -e "rProject::InstallLocal(all = TRUE, force = TRUE)"
	@Rscript .setup/scripts/make-config.R ${PWD}

clean:
	@echo \n\nCleaning...\n\n
	@Rscript -e "rProject::Clean(\"${PWD}\")"
	@rm -rf "${PWD}/TEMPDIR.*"

cleanpkg:
	@echo \n\nCleaning packages...\n\n
	@Rscript -e "rProject::CleanPkg(\"${PWD}\")"

cleanproj:
	@echo \n\nCleaning project...\n\n
	@Rscript -e "rProject::CleanProj(\"${PWD}\")"

cleantinytex:
	@echo \n\nCleaning TinyTex...\n\n
	@Rscript -e "rProject::CleanTinyTex(\"${PWD}\")"

coverage:
	@echo \n\nCode coverage...\n\n
	@Rscript -e "rProject::Coverage(\"${PWD}\")"

lint:
	@echo \n\nStyling...\n\n
	@Rscript -e "rProject::Style(\"${PWD}\")"
	@echo Linting...
	@Rscript -e "rProject::Lint(\"${PWD}\")"

latex:
	@echo \n\nCompiling latex...\n\n
	@Rscript -e "rProject::LatexMake(\"${PWD}\")"

quarto:
	@echo \n\nRendering quarto...\n\n
	@Rscript -e "rProject::Quarto(\"${PWD}\")"

clone:
	@bash .setup/scripts/clone.sh
