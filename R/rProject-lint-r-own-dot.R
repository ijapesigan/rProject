.LintROwn <- function(data) {
  # the names a file defines itself, or takes as arguments: a call to one of
  # them is not the base or package function of the same name
  terminal <- data[data$terminal, , drop = FALSE]
  after <- c(terminal$token[-1L], "")
  unique(
    x = c(
      terminal$text[
        terminal$token == "SYMBOL" &
          after %in% c("LEFT_ASSIGN", "EQ_ASSIGN")
      ],
      data$text[data$token == "SYMBOL_FORMALS"]
    )
  )
}
