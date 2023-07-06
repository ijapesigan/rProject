#' Knit `latexsrc/*.Rtex`
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LibPaths
#' @export
LatexKnit <- function(path) {
  detritus <- Detritus(path = path)$tex_folder
  rtex_files <- list.files(
    file.path(
      path,
      "latexsrc"
    ),
    pattern = "\\.Rtex$",
    full.names = TRUE,
    all.files = TRUE
  )
  if (length(rtex_files) > 0) {
    lapply(
      X = rtex_files,
      FUN = function(i) {
        tex_file <- sub(
          pattern = "\\.Rtex$",
          replacement = "\\.tex",
          x = basename(i)
        )
        knitr::knit(
          input = i,
          output = file.path(
            detritus,
            tex_file
          )
        )
      }
    )
  }
  tex_files <- list.files(
    file.path(
      path,
      "latexsrc"
    ),
    pattern = "\\.tex$",
    full.names = TRUE,
    all.files = TRUE
  )
  if (length(tex_files) > 0) {
    file.copy(
      from = tex_files,
      to = detritus
    )
  }
}
