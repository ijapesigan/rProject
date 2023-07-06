#' Precompile Vignettes
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LibPaths
#' @export
VignettesPrecompile <- function(path) {
  if (
    file.exists(
      file.path(
        path,
        "DESCRIPTION"
      )
    )
  ) {
    lib <- LibPaths(path = path)
    installed <- utils::installed.packages()
    pkg_installed <- installed[, "Package"]
    if (!("knitr" %in% pkg_installed)) {
      utils::install.packages(
        "knitr",
        repos = c(REPO_NAME = PkgRepo(path = path)),
        lib = lib,
        quiet = TRUE
      )
    }
    vignettes_folder <- file.path(
      path,
      "vignettes"
    )
    vignettes_source <- file.path(
      path,
      ".setup",
      "vignettes"
    )
    orig <- list.files(
      path = vignettes_source,
      pattern = "\\.orig$",
      full.names = FALSE,
      all.files = TRUE,
      recursive = FALSE
    )
    target <- gsub(
      pattern = "\\.orig$",
      replacement = "",
      x = orig
    )
    if (length(orig) > 0) {
      dir.create(
        path = file.path(
          path,
          "vignettes"
        ),
        showWarnings = FALSE
      )
      for (i in seq_along(orig)) {
        if (
          !(
            file.exists(
              file.path(
                vignettes_folder,
                target[i]
              )
            )
          )
        ) {
          file.copy(
            from = file.path(vignettes_source, orig[i]),
            to = vignettes_folder,
            overwrite = TRUE
          )
          knitr::knit(
            file.path(vignettes_folder, orig[i]),
            file.path(vignettes_folder, target[i])
          )
        }
      }
    }
    figs <- list.files(
      path = path,
      pattern = "^fig-vignettes-.",
      full.names = TRUE,
      all.files = TRUE,
      recursive = FALSE
    )
    if (length(figs) > 0) {
      file.copy(
        from = figs,
        to = vignettes_folder,
        overwrite = TRUE
      )
      on.exit(unlink(figs))
    }
  } else {
    message(
      paste(
        path,
        "is not an R package."
      )
    )
  }
}
