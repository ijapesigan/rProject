#' Copy .bib Files from lib-* GitHUb Repositories
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LibPaths
#' @export
BibLib <- function(path) {
  latex_bib_dir <- file.path(
    path,
    ".setup",
    "latex",
    "bib"
  )
  if (dir.exists(latex_bib_dir)) {
    # lib
    wd <- getwd()
    on.exit(
      expr = setwd(wd),
      add = TRUE
    )
    setwd(latex_bib_dir)
    libs <- c(
      "lib-2020-2029-book",
      "lib-2020-2029-manual",
      "lib-2020-2029-article",
      "lib-2010-2019-manual",
      "lib-2010-2019-book",
      "lib-2010-2019-article",
      "lib-2000-2009-book",
      "lib-2000-2009-article",
      "lib-1990-1999-article",
      "lib-1990-1999-book",
      "lib-1980-1989-article",
      "lib-1980-1989-book",
      "lib-1970-1979-article",
      "lib-1960-1969-article",
      "lib-1950-1959-article",
      "lib-1940-1949-article",
      "lib-1930-1939-article"
    )
    clean <- function(libs, path) {
      lapply(
        X = libs,
        FUN = function(lib, path) {
          unlink(
            file.path(
              path,
              ".setup",
              "latex",
              "bib",
              lib
            ),
            recursive = TRUE
          )
        },
        path = path
      )
    }
    clean(libs = libs, path = path)
    on.exit(
      expr = clean(libs = libs, path = path),
      add = TRUE
    )
    for (i in seq_along(libs)) {
      system(
        paste0(
          "git clone https://github.com/ijapesigan/",
          libs[i],
          ".git"
        )
      )
    }
    bib_src <- list.files(
      path = latex_bib_dir,
      pattern = ".*\\.bib$",
      all.files = TRUE,
      full.names = TRUE,
      recursive = TRUE,
      include.dirs = TRUE
    )
    file.copy(
      from = bib_src,
      to = latex_bib_dir
    )
  }
}
