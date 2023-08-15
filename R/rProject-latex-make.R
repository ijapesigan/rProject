#' Compile Output of `LatexKnit`
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LatexCompile
#' @inheritParams Bib
#' @export
LatexMake <- function(path,
                      clean = FALSE,
                      bib_lib = TRUE) {
  latex <- file.path(
    path,
    ".setup",
    "latex"
  )
  if (
    file.exists(
      latex
    )
  ) {
    bib <- file.path(
      latex,
      "bib",
      "bib.bib"
    )
    Bib(path = path, bib_lib = bib_lib)
    try(
      LatexKnit(
        path = path
      )
    )
    try(
      LatexCompile(
        path = path,
        clean = clean
      )
    )
  } else {
    message(
      paste(
        latex,
        "does not exist."
      )
    )
  }
}
