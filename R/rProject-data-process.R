#' Process Data
#'
#' Execute R scripts in `data-process`.
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LibPaths
#' @param clean Logical.
#'   Remove all `.Rds` files in `data-process` before running.
#' @return Called for its side effects; the value is not meaningful.
#' @examples
#' \dontrun{
#' DataProcess(path = getwd())
#' }
#' @export
DataProcess <- function(path,
                        clean = FALSE) {
  data_process <- file.path(
    path,
    ".setup",
    "data-process"
  )
  if (clean) {
    x <- list.files(
      path = data_process,
      pattern = "\\.Rds$",
      full.names = TRUE,
      all.files = TRUE,
      recursive = TRUE
    )
    if (length(x = x) > 0) {
      unlink(x = x)
    }
  }
  x <- list.files(
    path = data_process,
    pattern = "\\.R$",
    full.names = TRUE,
    all.files = TRUE,
    recursive = TRUE
  )
  if (length(x = x) > 0) {
    invisible(
      x = lapply(
        X = x,
        FUN = source
      )
    )
  }
}
