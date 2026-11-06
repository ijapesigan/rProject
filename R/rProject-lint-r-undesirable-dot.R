.LintRUndesirable <- function(path) {
  # lintr's own linters: no pipes in R/; no library(), require(), attach()
  # in R/ or tests
  level <- .LintLevel(path = path)
  fns <- lintr::undesirable_function_linter(
    fun = c(
      library = "use pkg::fn()",
      require = "use pkg::fn()",
      attach = "use pkg::fn()"
    ),
    symbol_is_undesirable = FALSE
  )
  ops <- lintr::undesirable_operator_linter(
    op = c(`|>` = "no pipes in R/", `%>%` = "no pipes in R/")
  )
  files <- .LintList(path = path, pattern = "^(R|tests)/.*\\.[Rr]$")
  files <- setdiff(
    x = files,
    y = c(file.path("R", "RcppExports.R"), file.path("tests", "testthat.R"))
  )
  .LintBind(
    rows = lapply(
      X = files,
      FUN = function(file) {
        in_r <- grepl(pattern = "^R/", x = file)
        linters <- list(fns)
        if (in_r) {
          linters <- list(fns, ops)
        }
        lints <- lintr::lint(
          filename = file.path(path, file),
          linters = linters,
          parse_settings = FALSE
        )
        if (length(x = lints) == 0L) {
          NULL
        } else {
          .LintRow(
            file = rep(x = file, times = length(x = lints)),
            line = vapply(
              X = lints,
              FUN = `[[`,
              FUN.VALUE = integer(length = 1),
              "line_number"
            ),
            rule = "undesirable",
            message = vapply(
              X = lints,
              FUN = `[[`,
              FUN.VALUE = character(length = 1),
              "message"
            ),
            level = level
          )
        }
      }
    )
  )
}
