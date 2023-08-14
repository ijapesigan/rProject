#' Consolidate .bib files into a Single File
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LibPaths
#' @export
Bib <- function(path) {
  latex_bib_dir <- file.path(
    path,
    ".setup",
    "latex",
    "bib"
  )
  if (dir.exists(latex_bib_dir)) {
  # lib
  wd <- getwd()
  on.exit(
    expr = setwd(wd),
    add = TRUE
  )
  setwd(latex_bib_dir)
  libs <- c(
	"lib-2020-2029-book",
	"lib-2020-2029-manual",
	"lib-2020-2029-article",
	"lib-2010-2019-manual",
	"lib-2010-2019-book",
	"lib-2010-2019-article",
	"lib-2000-2009-book",
	"lib-2000-2009-article",
	"lib-1990-1999-article",
	"lib-1990-1999-book",
	"lib-1980-1989-article",
	"lib-1980-1989-book",
	"lib-1970-1979-article",
	"lib-1960-1969-article",
	"lib-1950-1959-article",
	"lib-1940-1949-article",
	"lib-1930-1939-article"
  )
  clean <- function(libs, path) {
    lapply(
      X = libs,
      FUN = function(lib, path) {
        unlink(
          file.path(
            path,
            ".setup",
            "latex",
            "bib",
            lib
          ),
          recursive = TRUE
        )
      },
      path = path
    )
  }
  clean(libs = libs, path = path)
  on.exit(
    expr = clean(libs = libs, path = path),
    add = TRUE
  )
  for (i in seq_along(libs)) {
    system(
      paste0(
        "git clone https://github.com/ijapesigan/",
        libs[i],
        ".git"
      )
    )
  }
  }
  # bib
  unlink(
    x = c(
      list.files(
        path = path,
        pattern = "^bib\\.bib$",
        full.names = TRUE,
        recursive = TRUE
      ),
      list.files(
        path = path,
        pattern = "^quarto\\.bib$",
        full.names = TRUE,
        recursive = TRUE
      ),
      list.files(
        path = path,
        pattern = "^vignettes\\.bib$",
        full.names = TRUE,
        recursive = TRUE
      )
    )
  )
  quarto <- vignettes <- FALSE
  latex_bib_dir <- file.path(
    path,
    ".setup",
    "latex",
    "bib"
  )
  latex_bib <- file.path(
    latex_bib_dir,
    "bib.bib"
  )
  if (dir.exists(latex_bib_dir)) {
    bib_src <- list.files(
      path = latex_bib_dir,
      pattern = ".*\\.bib$",
      all.files = TRUE,
      full.names = TRUE,
      recursive = TRUE,
      include.dirs = TRUE
    )
    length_bib_src <- length(bib_src)
    if (length_bib_src > 0) {
      run <- TRUE
    } else {
      message(
        "No \".bib\" files found."
      )
      return(NULL)
    }
  } else {
    message(
      "No \".bib\" files found."
    )
    return(NULL)
  }
  if (run) {
    if (length_bib_src == 1) {
      bib <- RefManageR::ReadBib(bib_src)
      RefManageR::WriteBib(
        bib = bib,
        file = bib_src,
        biblatex = TRUE,
        append = FALSE,
        verbose = FALSE
      )
    } else {
      bib <- lapply(
        X = bib_src,
        FUN = RefManageR::ReadBib
      )
      mapply(
        FUN = RefManageR::WriteBib,
        bib = bib,
        file = bib_src,
        biblatex = TRUE,
        append = FALSE,
        verbose = FALSE
      )
      bib <- Reduce(
        f = `+`,
        x = bib
      )
    }
    RefManageR::WriteBib(
      bib = bib,
      file = latex_bib,
      biblatex = TRUE,
      append = FALSE,
      verbose = FALSE
    )
    # quarto and vignettes
    quarto_dir <- file.path(
      path,
      ".setup",
      "quarto"
    )
    vignettes_dir <- file.path(
      path,
      "vignettes"
    )
    if (dir.exists(quarto_dir)) {
      quarto <- TRUE
    }
    if (dir.exists(vignettes_dir)) {
      vignettes <- TRUE
    }
    mapply(
      FUN = function(test,
                     output_dir,
                     output_name) {
        if (test) {
          dir.create(
            path = output_dir,
            showWarnings = FALSE,
            recursive = TRUE
          )
          file.copy(
            from = latex_bib,
            to = output_dir
          )
          file.rename(
            from = file.path(
              output_dir,
              "bib.bib"
            ),
            to = file.path(
              output_dir,
              output_name
            )
          )
        }
      },
      test = c(
        quarto,
        vignettes
      ),
      output_dir = c(
        file.path(
          quarto_dir,
          "bib"
        ),
        vignettes_dir
      ),
      output_name = c(
        "quarto.bib",
        "vignettes.bib"
      )
    )
  }
}
