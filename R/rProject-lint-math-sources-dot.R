.LintMathSources <- function(path) {
  # roxygen lines of R and C++, and the text of Markdown files: for the
  # math rules; other lines are blank
  rox <- .LintList(path = path, pattern = "^(R/.*\\.R|\\.setup/cpp/.*\\.cpp)$")
  rox <- rox[rox != file.path("R", "RcppExports.R")]
  rox_items <- lapply(
    X = rox,
    FUN = function(file) {
      lines <- .LintRead(path = path, file = file)
      lines[!grepl(pattern = "^\\s*(#'|//')", x = lines)] <- ""
      list(file = file, lines = lines)
    }
  )
  md_items <- lapply(
    X = setdiff(
      x = .LintMdList(path = path),
      y = .LintList(path = path, pattern = "^\\.setup/(ai|logs)/")
    ),
    FUN = function(file) {
      list(
        file = file,
        lines = .LintMdStrip(lines = .LintRead(path = path, file = file))
      )
    }
  )
  c(rox_items, md_items)
}
