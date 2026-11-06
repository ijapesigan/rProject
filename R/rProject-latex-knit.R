#' Knit `.setup/latex/*.Rtex`
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LibPaths
#' @return Called for its side effects; the value is not meaningful.
#' @examples
#' \dontrun{
#' LatexKnit(path = getwd())
#' }
#' @export
LatexKnit <- function(path) {
  detritus <- Detritus(path = path)$tex_folder
  latex <- file.path(
    path,
    ".setup",
    "latex"
  )
  rtex_files <- list.files(
    path = latex,
    pattern = "\\.Rtex$",
    full.names = TRUE,
    all.files = TRUE
  )
  if (length(x = rtex_files) > 0) {
    lapply(
      X = rtex_files,
      FUN = function(i) {
        tex_file <- sub(
          pattern = "\\.Rtex$",
          replacement = "\\.tex",
          x = basename(path = i)
        )
        knitr::knit(
          input = i,
          output = file.path(
            detritus,
            tex_file
          ),
          envir = new.env()
        )
      }
    )
  }
  tex_files <- list.files(
    path = latex,
    pattern = "\\.tex$",
    full.names = TRUE,
    all.files = TRUE
  )
  if (length(x = tex_files) > 0) {
    file.copy(
      from = tex_files,
      to = detritus
    )
  }
}
