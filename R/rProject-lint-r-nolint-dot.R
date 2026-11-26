.LintRNolint <- function(path,
                         code = .LintRCode(path = path)) {
  level <- .LintLevel(path = path)
  # one line (`# nolint:`) or a block (`# nolint start:`) names its rules
  # and a reason; `# nolint end` closes a block and is not listed
  good <- paste0(
    "#\\s*nolint(\\s+start)?:\\s*[A-Za-z_, ]+\\.",
    "\\s*Reason:\\s*\\S"
  )
  .LintBind(
    rows = lapply(
      X = code,
      FUN = function(item) {
        data <- item$data
        comments <- character(length = 0L)
        line <- integer(length = 0L)
        if (!is.null(x = data)) {
          keep <- data$token == "COMMENT" &
            grepl(pattern = "^#\\s*nolint\\b", x = data$text, perl = TRUE) &
            !grepl(
              pattern = "^#\\s*nolint\\s+end\\b",
              x = data$text,
              perl = TRUE
            )
          comments <- data$text[keep]
          line <- data$line1[keep]
        }
        if (length(x = comments) == 0L) {
          NULL
        } else {
          ok <- grepl(pattern = good, x = comments, perl = TRUE)
          # every # nolint is listed; one without a reason is a warning
          .LintRow(
            file = rep(x = item$file, times = length(x = comments)),
            line = line,
            rule = "nolint",
            message = ifelse(
              test = ok,
              yes = comments,
              no = "`# nolint` needs a rule and a reason"
            ),
            level = ifelse(test = ok, yes = "note", no = level)
          )
        }
      }
    )
  )
}
