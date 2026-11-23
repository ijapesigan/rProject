#' Build Website
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LibPaths
#' @inheritParams Bib
#' @return Called for its side effects; the value is not meaningful.
#' @examples
#' \dontrun{
#' Site(path = getwd())
#' }
#' @export
Site <- function(path) {
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
    if (!("devtools" %in% pkg_installed)) {
      pak::pkg_install(
        pkg = "r-lib/devtools",
        lib = lib,
        upgrade = FALSE
      )
    }
    if (!("pkgdown" %in% pkg_installed)) {
      utils::install.packages(
        pkgs = "pkgdown",
        repos = c(REPO_NAME = PkgRepo(path = path)),
        lib = lib,
        quiet = TRUE
      )
    }
    pkgdown <- file.path(
      path,
      ".setup",
      "pkgdown",
      "_pkgdown.yml"
    )
    if (
      file.exists(
        pkgdown
      )
    ) {
      bib <- file.path(
        path,
        "vignettes",
        "vignettes.bib"
      )
      if (!file.exists(bib)) {
        Bib(
          path = path,
          bib_lib = FALSE
        )
      }
      file.copy(
        from = pkgdown,
        to = path
      )
      url <- .SiteUrl(path = path)
      # pkgdown renders every top-level .md and those in .github/ (it
      # ignores .Rbuildignore): move the private ones aside, and back on
      # exit; the folder aside is in the project, since a move to another
      # filesystem (/tmp) fails without an error
      private <- c(
        "AGENTS.md",
        "CLAUDE.md",
        "CLAUDE.local.md",
        file.path(".github", "copilot-instructions.md")
      )
      private <- private[file.exists(file.path(path, private))]
      aside <- tempfile(pattern = ".site-private-", tmpdir = path)
      dir.create(path = aside)
      keys <- gsub(pattern = "/", replacement = "--", x = private)
      moved <- file.rename(
        from = file.path(path, private),
        to = file.path(aside, keys)
      )
      on.exit(
        expr = {
          back <- file.exists(file.path(aside, keys))
          file.rename(
            from = file.path(aside, keys)[back],
            to = file.path(path, private)[back]
          )
          unlink(x = aside, recursive = TRUE)
        },
        add = TRUE
      )
      if (!all(moved)) {
        stop(
          paste0(
            "\n\nSite(): could not move aside ",
            paste(private[!moved], collapse = ", "),
            "; the site would publish them.\n\n"
          ),
          call. = FALSE
        )
      }
      pkgdown::build_site(
        pkg = path,
        preview = FALSE,
        override = if (is.null(x = url)) {
          list()
        } else {
          list(url = url)
        }
      )
      on.exit(
        expr = unlink(
          x = file.path(
            path,
            "_pkgdown.yml"
          )
        ),
        add = TRUE
      )
      # pages a site built before this fix may still hold, as HTML and as
      # pkgdown's Markdown copies
      unlink(
        x = file.path(
          path,
          "pkgdown",
          outer(
            X = c("AGENTS", "CLAUDE", "CLAUDE.local", "copilot-instructions"),
            Y = c(".html", ".md"),
            FUN = paste0
          )
        )
      )
    } else {
      message(
        paste(
          pkgdown,
          "does not exist."
        )
      )
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
