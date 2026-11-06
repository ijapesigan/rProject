#' Lint Project
#'
#' Runs `lintr` on the R code, then the house checks of the style guides,
#' and prints one table of findings: file, line, rule, message, and level.
#' The R and C++ checks are warnings until a project sets
#' `lint_error <- TRUE` in `.setup/scripts/project.R`: then they stop
#' `make lint`. The LaTeX and Markdown checks are always warnings. Talks
#' (project type `talk`) run the rules kept in talks only.
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LibPaths
#' @return Returns the `lints` object of `lintr`, invisibly with the house
#'   findings as the data frame in its `house` attribute.
#'
#' @examples
#' \dontrun{
#' Lint(path = getwd())
#' }
#'
#' @return Called for its side effects; the value is not meaningful.
#' @examples
#' \dontrun{
#' Lint(path = getwd())
#' }
#' @export
Lint <- function(path) {
  lib <- LibPaths(path = path)
  installed <- utils::installed.packages()
  pkg_installed <- installed[, "Package"]
  if (!("lintr" %in% pkg_installed)) {
    utils::install.packages(
      pkgs = "lintr",
      repos = c(REPO_NAME = PkgRepo(path = path)),
      lib = lib,
      quiet = TRUE
    )
  }
  linters <- lintr::linters_with_defaults(
    lintr::object_name_linter(
      styles = c(
        "CamelCase",
        "snake_case",
        "symbols"
      )
    )
  )
  # the files to skip, as full paths: lintr (3.4.0) fails on an excluded
  # folder that holds no R files
  exclusions <- c(
    unlist(
      x = lapply(
        X = file.path(path, c("renv", "packrat", ".library", ".verify")),
        FUN = list.files,
        pattern = "\\.(r|rmd|qmd|rnw|rhtml|rrst|rtex|rtxt)$",
        ignore.case = TRUE,
        all.files = TRUE,
        recursive = TRUE,
        full.names = TRUE
      )
    ),
    file.path(path, "R", "RcppExports.R")
  )
  exclusions <- exclusions[file.exists(exclusions)]
  # .Rtex chunk options (`% #| label = ...`): lintr (3.4.0) counts the `%`
  # as indentation; every other linter still checks the .Rtex files
  rtex <- list.files(
    path = path,
    pattern = "\\.Rtex$",
    recursive = TRUE,
    full.names = TRUE
  )
  exclusions <- c(
    as.list(x = exclusions),
    stats::setNames(
      object = rep(
        x = list(list(indentation_linter = Inf)),
        times = length(x = rtex)
      ),
      nm = rtex
    )
  )
  # no try(): an error in lintr stops make lint
  if (length(x = exclusions) == 0L) {
    lints <- lintr::lint_dir(
      path = path,
      linters = linters
    )
  } else {
    lints <- lintr::lint_dir(
      path = path,
      linters = linters,
      exclusions = exclusions
    )
  }
  # lib-* projects: check the entries too (reported, not an error)
  project <- .VerifyProject(path = path)
  if (grepl(pattern = "^lib-[0-9]{4}-[0-9]{4}-[a-z]+$", x = project)) {
    print(x = LibCheck(path = path))
  }
  house <- .LintHouse(path = path, type = .TemplateType(path = path))
  .LintReport(rows = house)
  attr(x = lints, which = "house") <- house
  errors <- sum(house$level == "error")
  if (errors > 0L) {
    print(x = lints)
    stop(errors, " house checks failed (see the table above).", call. = FALSE)
  }
  lints
}
