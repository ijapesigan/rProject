#' Compile Output of `LatexKnit`
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LatexCompile
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
