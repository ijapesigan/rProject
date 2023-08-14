#' Render Quarto Project
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LibPaths
#' @inheritParams Bib
#'
#' @export
Quarto <- function(path,
                   lib_bib = FALSE) {
  qmd_files <- list.files(
    file.path(
      path,
      ".setup",
      "quarto"
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
      ".setup",
      "quarto",
      "r-script",
      "prerender.R"
    )
    if (file.exists(prerender)) {
      source(prerender)
    } else {
      message(
        paste(
          prerender,
          "not found."
        )
      )
    }
    quarto <- file.path(
      path,
      ".setup",
      "quarto",
      "_quarto.yml"
    )
    if (file.exists(quarto)) {
      bib <- file.path(
        path,
        ".setup",
        "quarto",
        "bib",
        "quarto.bib"
      )
      Bib(path = path, lib_bib = lib_bib)
      file.copy(
        from = quarto,
        to = path
      )
      quarto::quarto_render(
        input = path
      )
      on.exit(
        expr = unlink(
          file.path(
            path,
            "_quarto.yml"
          )
        ),
        add = TRUE
      )
    } else {
      message(
        paste(
          quarto,
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
        file.path(
          path,
          ".setup",
          "quarto"
        ),
        "."
      )
    )
  }
}
