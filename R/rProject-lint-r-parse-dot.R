.LintRParse <- function(lines) {
  # parse data, or NULL for code that does not parse (lintr reports it)
  exprs <- tryCatch(
    expr = parse(text = lines, keep.source = TRUE),
    error = function(e) {
      NULL
    }
  )
  if (is.null(x = exprs)) {
    NULL
  } else {
    utils::getParseData(x = exprs)
  }
}
