#' Consolidate .bib files into a Single File
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LibPaths
#' @export
Bib <- function(path) {
  unlink(
    x = list.files(
      path = path,
      pattern = "^bib\\.bib$",
      full.names = TRUE,
      recursive = TRUE
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
      full.names = TRUE
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
    } else {
      bib <- lapply(
        X = bib_src,
        FUN = RefManageR::ReadBib
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
      verbose = TRUE
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
