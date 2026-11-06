.LintRFiles <- function(path) {
  level <- .LintLevel(path = path)
  pkg <- .LintPkg(path = path)
  rules <- list(
    list(
      folder = "^R/.*\\.[Rr]$",
      good = paste0("^R/", pkg, "-[a-z0-9-]+\\.R$"),
      skip = "^R/RcppExports\\.R$",
      message = paste0("name it R/", pkg, "-<name>.R")
    ),
    list(
      folder = "^tests/testthat/[^/]+\\.[Rr]$",
      good = paste0(
        "^tests/testthat/(test-", pkg, "-[a-z0-9-]+|helper-", pkg, ")\\.R$"
      ),
      skip = "^$",
      message = paste0(
        "name it test-", pkg, "-<name>.R or helper-", pkg, ".R"
      )
    ),
    list(
      folder = "^\\.setup/tests-benchmark/[^/]+\\.[Rr]$",
      good = paste0(
        "^\\.setup/tests-benchmark/test-benchmark-", pkg, "-[a-z0-9-]+\\.R$"
      ),
      skip = "^$",
      message = paste0("name it test-benchmark-", pkg, "-<name>.R")
    ),
    list(
      folder = "^\\.setup/tests-external/[^/]+\\.[Rr]$",
      good = paste0(
        "^\\.setup/tests-external/test-external-", pkg, "-[a-z0-9-]+\\.R$"
      ),
      skip = "^$",
      message = paste0("name it test-external-", pkg, "-<name>.R")
    )
  )
  .LintBind(
    rows = lapply(
      X = rules,
      FUN = function(rule) {
        files <- .LintList(path = path, pattern = rule$folder)
        bad <- files[
          !grepl(pattern = rule$good, x = files) &
            !grepl(pattern = rule$skip, x = files)
        ]
        .LintRow(
          file = bad,
          line = rep(x = 1L, times = length(x = bad)),
          rule = "file-name",
          message = rule$message,
          level = level
        )
      }
    )
  )
}
