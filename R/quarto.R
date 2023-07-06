#' Render Quarto Project
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LibPaths
#'
#' @export
Quarto <- function(path) {
  qmd_files <- list.files(
    file.path(
      path,
      "qmd"
    ),
    pattern = "\\.qmd$",
    full.names = TRUE,
    all.files = TRUE
  )
  qmd_files <- c(
    qmd_files,
    list.files(
      file.path(
        path
      ),
      pattern = "\\.qmd$",
      full.names = TRUE,
      all.files = TRUE
    )
  )
  if (length(qmd_files) > 0) {
    prerender <- file.path(
      path,
      "qmd",
      "r-script",
      "prerender.R"
    )
    if (file.exists(prerender)) {
      source(prerender)
    } else {
      message(
        paste0(
          prerender,
          " ",
          "not found."
        )
      )
    }
    quarto_yml <- file.path(
      path,
      "_quarto.yml"
    )
    if (file.exists(quarto_yml)) {
      quarto::quarto_render(
        input = path
      )
    } else {
      message(
        paste0(
          quarto_yml,
          " ",
          "not found."
        )
      )
    }
  } else {
    message(
      paste0(
        "No \'qmd\' files found in",
        " ",
        path,
        " ",
        "or",
        " ",
        file.path(path, "qmd"),
        "."
      )
    )
  }
}
