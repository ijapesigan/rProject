#' Consolidate .bib files into a Single File
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @param bib_lib Logical.
#'   If `bib_lib = TRUE`,
#'   build `bib.bib` from `lib-*` GitHub repositories.
#' @inheritParams LibPaths
#' @export
Bib <- function(path,
                bib_lib = TRUE) {
  latex_bib_dir <- file.path(
    path,
    ".setup",
    "latex",
    "bib"
  )
  if (bib_lib) {
    BibLib(path = path)
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
    # rewrite bib files
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
    }
    # reread bib files
    bib_src <- list.files(
      path = latex_bib_dir,
      pattern = ".*\\.bib$",
      all.files = TRUE,
      full.names = TRUE,
      recursive = TRUE,
      include.dirs = TRUE
    )
    length_bib_src <- length(bib_src)
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
    # write the consolidated bib.bib
    RefManageR::WriteBib(
      bib = bib,
      file = latex_bib,
      biblatex = TRUE,
      append = FALSE,
      verbose = FALSE
    )
    # quarto, pkgdown and vignettes
    quarto_dir <- file.path(
      path,
      ".setup",
      "quarto"
    )
    pkgdown_dir <- file.path(
      path,
      ".setup",
      "pkgdown"
    )
    vignettes_dir <- file.path(
      path,
      "vignettes"
    )
    if (dir.exists(quarto_dir)) {
      quarto <- TRUE
    }
    if (dir.exists(pkgdown_dir)) {
      pkgdown <- TRUE
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
        pkgdown,
        vignettes
      ),
      output_dir = c(
        file.path(
          quarto_dir,
          "bib"
        ),
        pkgdown,
        vignettes_dir
      ),
      output_name = c(
        "quarto.bib",
        "vignettes.bib",
        "vignettes.bib"
      )
    )
  }
}
