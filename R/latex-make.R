#' Compile Output of `LatexKnit`
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LatexCompile
#' @export
LatexMake <- function(path,
                      clean = FALSE) {
  if (
    file.exists(
      file.path(
        path,
        "latexsrc"
      )
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
        file.path(
          path,
          "latexsrc"
        ),
        "does not exist."
      )
    )
  }
}
