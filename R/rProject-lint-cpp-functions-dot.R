.LintCppFunctions <- function(lines,
                              end = "\\{") {
  # function definitions (end = "\\{") or declarations (end = ";"), which
  # clang-format starts in the first column: name, arguments, and line
  text <- paste(.LintCppStrip(lines = lines), collapse = "\n")
  pattern <- paste0(
    "(?m)^(?:[A-Za-z_][\\w:<>,&* ]*[\\s&*]+)",
    "([A-Za-z_]\\w*)\\(([^)]*)\\)\\s*(?:const\\s*)?",
    end
  )
  hit <- gregexpr(pattern = pattern, text = text, perl = TRUE)[[1]]
  if (hit[1] < 0L) {
    data.frame(
      name = character(length = 0L),
      args = character(length = 0L),
      line = integer(length = 0L),
      stringsAsFactors = FALSE
    )
  } else {
    start <- attr(x = hit, which = "capture.start")
    size <- attr(x = hit, which = "capture.length")
    newlines <- gregexpr(pattern = "\n", text = text, fixed = TRUE)[[1]]
    data.frame(
      name = substring(
        text = text,
        first = start[, 1],
        last = start[, 1] + size[, 1] - 1L
      ),
      args = substring(
        text = text,
        first = start[, 2],
        last = start[, 2] + size[, 2] - 1L
      ),
      line = vapply(
        X = as.integer(x = hit),
        FUN = function(position) {
          sum(newlines < position) + 1L
        },
        FUN.VALUE = integer(length = 1)
      ),
      stringsAsFactors = FALSE
    )
  }
}
