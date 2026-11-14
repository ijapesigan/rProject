# Shared test helpers (testthat sources helper-*.R before the tests).

# A small fake project in a temporary folder. A `pattern` with a space tests
# paths with spaces.
.TestProject <- function(name = "testProject",
                         description = TRUE,
                         pattern = "project") {
  root <- file.path(tempfile(pattern = pattern), name)
  dir.create(
    path = file.path(root, ".setup", "scripts"),
    recursive = TRUE
  )
  dir.create(path = file.path(root, "R"))
  if (description) {
    writeLines(
      text = c(
        paste("Package:", name),
        "Title: Test",
        "Version: 0.0.1",
        "Description: Test.",
        "License: MIT + file LICENSE",
        "Encoding: UTF-8"
      ),
      con = file.path(root, "DESCRIPTION")
    )
  }
  writeLines(
    text = paste0("project <- \"", name, "\""),
    con = file.path(root, ".setup", "scripts", "project.R")
  )
  root
}

# Save and restore session state that functions change:
# library paths and environment variables.
.TestState <- function(vars = NULL) {
  if (is.null(x = vars)) {
    vars <- c(
      "HOME",
      "PROJECT",
      "R_LIBS_USER",
      "R_PROFILE_USER",
      "R_HISTFILE"
    )
  }
  list(
    lib = .libPaths(),
    # names = TRUE: Sys.getenv() drops the name for a single variable
    env = Sys.getenv(x = vars, unset = NA, names = TRUE)
  )
}

.TestRestore <- function(state) {
  .libPaths(new = state$lib)
  set <- state$env[!is.na(x = state$env)]
  unset <- names(x = state$env)[is.na(x = state$env)]
  if (length(x = set) > 0L) {
    do.call(what = Sys.setenv, args = as.list(x = set))
  }
  if (length(x = unset) > 0L) {
    Sys.unsetenv(x = unset)
  }
  invisible(x = NULL)
}

# Functions that call LibPaths() see only .library, the site library, and
# base R (the container layout). Skip when a package they need is elsewhere,
# as on the plain GitHub runners (user library).
.SkipUnlessSiteLibrary <- function(pkgs) {
  found <- nzchar(
    x = vapply(
      X = pkgs,
      FUN = function(pkg) {
        system.file(package = pkg, lib.loc = c(.Library.site, .Library))
      },
      FUN.VALUE = character(length = 1)
    )
  )
  testthat::skip_if_not(
    condition = all(found),
    message = paste(
      "not in the site library:",
      paste(pkgs[!found], collapse = ", ")
    )
  )
}

# Slow tests: run on CI and on request, skipped in local builds and on CRAN.
.SkipSlow <- function() {
  testthat::skip_on_cran()
  testthat::skip_if_not(
    condition = Sys.getenv(x = "CI") == "true" ||
      Sys.getenv(x = "RPROJECT_SLOW_TESTS") == "true",
    message = "set RPROJECT_SLOW_TESTS=true to run slow tests"
  )
}

# Proprietary software: never on CI or CRAN, and only where it is found.
.SkipIfMissing <- function(program) {
  testthat::skip_on_cran()
  testthat::skip_on_ci()
  testthat::skip_if(
    condition = Sys.which(names = program) == "",
    message = paste0(program, " is not installed")
  )
}

# A project with the given files, for the house lint checks: `files` is a
# list of lines, named by path.
.TestLintProject <- function(files) {
  root <- .TestProject()
  for (file in names(x = files)) {
    dir.create(
      path = dirname(path = file.path(root, file)),
      showWarnings = FALSE,
      recursive = TRUE
    )
    writeLines(text = files[[file]], con = file.path(root, file))
  }
  root
}

# A package project built from the template, for Conform(): the manifest
# files (type cran), the files every package has, and an export with its test.
.TestConform <- function(name = "conformPkg",
                         public = "ijapesigan/conformPkg") {
  root <- .TestProject(name = name)
  cat(
    "type <- \"cran\"\n",
    file = file.path(root, ".setup", "scripts", "project.R"),
    append = TRUE
  )
  for (folder in c(
    "tests/testthat", "vignettes", "inst", ".setup/pkgdown", ".setup/repo"
  )) {
    dir.create(
      path = file.path(root, folder),
      showWarnings = FALSE,
      recursive = TRUE
    )
  }
  writeLines(text = "*.Rds", con = file.path(root, "vignettes", ".gitignore"))
  writeLines(
    text = c(
      "library(testthat)",
      paste0("library(", name, ")"),
      "",
      paste0("test_check(\"", name, "\")")
    ),
    con = file.path(root, "tests", "testthat.R")
  )
  writeLines(text = "citation", con = file.path(root, "inst", "CITATION"))
  writeLines(
    text = "destination: pkgdown",
    con = file.path(root, ".setup", "pkgdown", "_pkgdown.yml")
  )
  writeLines(
    text = c("jeksterslab-psu/conformPkg"),
    con = file.path(root, ".setup", "repo", "private-github.md")
  )
  writeLines(
    text = "https://www.overleaf.com/project/635a91d56f77ff3bdd9b8f9c",
    con = file.path(root, ".setup", "repo", "private-overleaf.md")
  )
  writeLines(
    text = public,
    con = file.path(root, ".setup", "repo", "public-github.md")
  )
  writeLines(
    text = c("export(Foo)", "S3method(print, foo)"),
    con = file.path(root, "NAMESPACE")
  )
  writeLines(
    text = "Foo <- function() {\n  1\n}",
    con = file.path(root, "R", paste0(name, "-foo.R"))
  )
  writeLines(
    text = "",
    con = file.path(root, "tests", "testthat", paste0("test-", name, "-foo.R"))
  )
  suppressMessages(
    expr = .TemplateWrite(path = root, type = "cran", check = FALSE)
  )
  root
}

# Rows of Conform() for a rule, without the printed table.
.TestConformRows <- function(path,
                             rule,
                             reference = NULL) {
  rows <- suppressMessages(
    expr = Conform(path = path, reference = reference)
  )
  rows[rows$rule == rule, ]
}
