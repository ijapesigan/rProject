#' Compile Output of `LatexKnit`
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LatexCompile
#' @inheritParams Bib
#' @return Called for its side effects; the value is not meaningful.
#' @examples
#' \dontrun{
#' LatexMake(path = getwd())
#' }
#' @export
LatexMake <- function(path,
                      clean = FALSE) {
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
    if (!file.exists(bib)) {
      Bib(
        path = path,
        bib_lib = FALSE
      )
    }
    try(
      expr = LatexKnit(
        path = path
      )
    )
    try(
      expr = LatexTikzCompile(
        path = path,
        clean = clean
      )
    )
    # not in try(): a failed PDF must stop make latex in CI
    LatexCompile(
      path = path,
      clean = clean
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
