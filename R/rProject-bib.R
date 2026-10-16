#' Consolidate .bib Files into a Single File
#'
#' Joins the `.bib` files in `.setup/latex/bib` into `bib.bib`,
#' verbatim and in file-name order,
#' and copies it to `.setup/quarto/bib/quarto.bib`
#' and `vignettes/vignettes.bib` when those folders exist.
#' Without sources (a clone of the repository, which has only `bib.bib`),
#' the existing `bib.bib` is copied.
#' The source files are never rewritten:
#' in `lib-*` projects they are the entries themselves
#' (one entry per file, ASCII with LaTeX accents).
#' [LibCheck()] validates them with biber.
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @param bib_lib Logical.
#'   If `bib_lib = TRUE`,
#'   build `bib.bib` from `lib-*` GitHub repositories.
#' @inheritParams LibPaths
#' @export
Bib <- function(path,
                bib_lib = FALSE) {
  latex_bib_dir <- file.path(
    path,
    ".setup",
    "latex",
    "bib"
  )
  if (bib_lib) {
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
    BibLib(path = path)
  }
  latex_bib <- file.path(
    latex_bib_dir,
    "bib.bib"
  )
  bib_src <- list.files(
    path = latex_bib_dir,
    pattern = ".*\\.bib$",
    all.files = TRUE,
    full.names = TRUE,
    recursive = TRUE
  )
  # the outputs are not sources
  bib_src <- bib_src[
    !(basename(bib_src) %in% c("bib.bib", "quarto.bib", "vignettes.bib"))
  ]
  out <- NULL
  if (length(bib_src) > 0L) {
    # verbatim, one blank line between files
    bib <- unlist(
      lapply(
        X = sort(bib_src),
        FUN = function(file) {
          c(readLines(con = file, warn = FALSE), "")
        }
      )
    )
    writeLines(
      text = bib,
      con = latex_bib
    )
  }
  if (!file.exists(latex_bib)) {
    message(
      "No \".bib\" files found."
    )
  } else {
    # without sources, the existing bib.bib (e.g., a clone)
    out <- latex_bib
    # quarto and vignettes
    copies <- c(
      file.path(path, ".setup", "quarto", "bib", "quarto.bib"),
      file.path(path, "vignettes", "vignettes.bib")
    )
    keep <- dir.exists(
      c(
        file.path(path, ".setup", "quarto"),
        file.path(path, "vignettes")
      )
    )
    for (copy in copies[keep]) {
      dir.create(
        path = dirname(copy),
        showWarnings = FALSE,
        recursive = TRUE
      )
      file.copy(
        from = latex_bib,
        to = copy,
        overwrite = TRUE
      )
    }
  }
  if (bib_lib) {
    unlink(
      list.files(
        path = file.path(
          path,
          ".setup",
          "latex",
          "bib"
        ),
        pattern = "^lib-.*\\.bib$",
        full.names = TRUE,
        recursive = TRUE
      )
    )
  }
  invisible(out)
}
