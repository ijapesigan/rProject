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
#'   build `bib.bib` from the public `lib-*` GitHub repositories
#'   (`make bib` does so in rProject, `make bibrproject` anywhere).
#'   If none can be cloned, the previous `bib.bib` is kept.
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
  latex_bib <- file.path(
    latex_bib_dir,
    "bib.bib"
  )
  if (bib_lib) {
    # kept in case the lib-* repositories cannot be cloned (e.g., offline)
    previous <- NULL
    if (file.exists(latex_bib)) {
      previous <- readLines(con = latex_bib, warn = FALSE)
    }
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
    cloned <- list.files(
      path = latex_bib_dir,
      pattern = "^lib-.*\\.bib$"
    )
    if (length(cloned) == 0L && !is.null(previous)) {
      writeLines(
        text = previous,
        con = latex_bib
      )
      warning(
        paste0(
          "\n\nThe lib-* repositories could not be cloned;",
          " keeping the previous bib.bib.\n\n"
        ),
        call. = FALSE
      )
    }
  }
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
