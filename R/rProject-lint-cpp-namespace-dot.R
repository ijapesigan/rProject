.LintCppNamespace <- function(path) {
  level <- .LintLevel(path = path)
  .LintBind(
    rows = lapply(
      X = .LintCppList(path = path),
      FUN = function(file) {
        hit <- grep(
          pattern = "\\busing\\s+namespace\\b",
          x = .LintCppStrip(lines = .LintRead(path = path, file = file)),
          perl = TRUE
        )
        .LintRow(
          file = rep(x = file, times = length(x = hit)),
          line = hit,
          rule = "cpp-namespace",
          message = "no using namespace: write arma::, Rcpp::, std::",
          level = level
        )
      }
    )
  )
}
