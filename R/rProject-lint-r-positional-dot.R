.LintRPositional <- function(call,
                             fml) {
  # the positional arguments that match a formal: R matches names first,
  # then the rest by position, up to `...`
  out <- list()
  if (!is.null(x = fml) && length(x = call$args) > 0L) {
    named <- unlist(
      x = lapply(
        X = call$args,
        FUN = function(arg) {
          arg$name
        }
      )
    )
    # exact and partial matches use up a formal
    open <- fml
    for (one in named[!is.na(x = named)]) {
      hit <- which(x = startsWith(x = open, prefix = one))
      if (one %in% open) {
        open <- setdiff(x = open, y = one)
      } else if (length(x = hit) == 1L) {
        open <- open[-hit]
      }
    }
    stop_at <- which(x = open == "...")
    if (length(x = stop_at) > 0L) {
      open <- open[seq_len(length.out = stop_at[1] - 1L)]
    }
    positional <- call$args[is.na(x = named)]
    n <- min(length(x = positional), length(x = open))
    for (i in seq_len(length.out = n)) {
      out[[i]] <- c(positional[[i]], list(formal = open[i]))
    }
  }
  out
}
