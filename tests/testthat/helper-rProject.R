# Shared test helpers (testthat sources helper-*.R before the tests).

# A small fake project in a temporary folder.
.TestProject <- function(name = "testProject",
                         description = TRUE) {
  root <- file.path(tempfile(pattern = "project"), name)
  dir.create(
    file.path(root, ".setup", "scripts"),
    recursive = TRUE
  )
  dir.create(file.path(root, "R"))
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
  if (is.null(vars)) {
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
    env = Sys.getenv(vars, unset = NA, names = TRUE)
  )
}

.TestRestore <- function(state) {
  .libPaths(state$lib)
  set <- state$env[!is.na(state$env)]
  unset <- names(state$env)[is.na(state$env)]
  if (length(set) > 0L) {
    do.call(what = Sys.setenv, args = as.list(set))
  }
  if (length(unset) > 0L) {
    Sys.unsetenv(unset)
  }
  invisible(NULL)
}

# Slow tests (installers, network, long builds) run only on request.
.SkipSlow <- function() {
  testthat::skip_if_not(
    Sys.getenv("RPROJECT_SLOW_TESTS") == "true",
    message = "set RPROJECT_SLOW_TESTS=true to run slow tests"
  )
}
