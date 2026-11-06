.LintRCalls <- function(data) {
  # the function calls of parse data: name, package (NA without ::), line,
  # and the positional and named arguments, one row per call
  if (is.null(x = data)) {
    list()
  } else {
    kids <- split(
      x = seq_len(length.out = nrow(x = data)),
      f = factor(x = data$parent, levels = unique(x = data$parent))
    )
    row_of <- stats::setNames(
      object = seq_len(length.out = nrow(x = data)),
      nm = as.character(x = data$id)
    )
    tokens <- which(x = data$token == "SYMBOL_FUNCTION_CALL")
    lapply(
      X = tokens,
      FUN = function(i) {
        name_expr <- as.character(x = data$parent[i])
        siblings <- kids[[name_expr]]
        sib_token <- data$token[siblings]
        call_expr <- as.character(x = data$parent[row_of[[name_expr]]])
        children <- kids[[call_expr]]
        open <- which(x = data$token[children] == "'('")
        if (
          any(sib_token %in% c("'$'", "'@'")) ||
            length(x = open) == 0L ||
            is.null(x = children)
        ) {
          NULL
        } else {
          pkg <- data$text[siblings[sib_token == "SYMBOL_PACKAGE"]]
          args <- .LintRCallArgs(
            data = data,
            children = children[-seq_len(length.out = open[1])]
          )
          list(
            name = data$text[i],
            pkg = ifelse(
              test = length(x = pkg) == 1L,
              yes = pkg,
              no = NA_character_
            ),
            line = data$line1[i],
            col = data$col1[i],
            args = args
          )
        }
      }
    )
  }
}
