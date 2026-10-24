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
  dir.create(
    latex_bib_dir,
    showWarnings = FALSE,
    recursive = TRUE
  )
  libs <- c(
    "lib-2020-2029-book",
    "lib-2020-2029-manual",
    "lib-2020-2029-article",
    "lib-2010-2019-manual",
    "lib-2010-2019-book",
    "lib-2000-2009-manual",
    "lib-2010-2019-article",
    "lib-2000-2009-book",
    "lib-2000-2009-article",
    "lib-1990-1999-article",
    "lib-1990-1999-book",
    "lib-1990-1999-manual",
    "lib-1980-1989-article",
    "lib-1980-1989-book",
    "lib-1970-1979-article",
    "lib-1970-1979-book",
    "lib-1960-1969-article",
    "lib-1950-1959-article",
    "lib-1940-1949-article",
    "lib-1930-1939-article",
    "lib-1920-1929-article",
    "lib-1910-1919-article"
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
  # clone into the bib folder, without changing the working directory;
  # without the user's git config (it may rewrite https to ssh, which
  # waits for a key or a prompt), and never prompt
  status <- integer(length(libs))
  for (i in seq_along(libs)) {
    status[i] <- system2(
      command = "git",
      env = c(
        "GIT_CONFIG_GLOBAL=/dev/null",
        "GIT_TERMINAL_PROMPT=0"
      ),
      args = c(
        "clone",
        "--depth",
        "1",
        "--quiet",
        paste0(
          "https://github.com/ijapesigan/",
          libs[i],
          ".git"
        ),
        .ShellQuote(
          x = file.path(
            latex_bib_dir,
            libs[i]
          )
        )
      )
    )
  }
  # all or nothing: a bib.bib without some lib-* would look complete.
  # When none can be cloned (offline), Bib() keeps the previous bib.bib
  failed <- libs[status != 0L]
  if (length(failed) > 0L && length(failed) < length(libs)) {
    stop(
      paste0(
        "\n\nCould not clone ",
        paste(failed, collapse = ", "),
        "; bib.bib not built.\n\n"
      ),
      call. = FALSE
    )
  }
  # the entries only (a clone also holds its own bib.bib and quarto.bib)
  bib_src <- list.files(
    path = latex_bib_dir,
    pattern = "^lib-.*\\.bib$",
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
