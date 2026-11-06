.AIGlobalMerge <- function(existing,
                           source) {
  # objects (named lists): merge by key, the source wins;
  # arrays (unnamed lists, e.g., permission rules): union;
  # anything else: the source
  object <- function(x) {
    is.list(x = x) && !is.null(x = names(x = x))
  }
  array <- function(x) {
    is.list(x = x) && is.null(x = names(x = x))
  }
  if (object(x = existing) && object(x = source)) {
    for (key in names(x = source)) {
      existing[key] <- list(
        if (key %in% names(x = existing)) {
          .AIGlobalMerge(
            existing = existing[[key]],
            source = source[[key]]
          )
        } else {
          source[[key]]
        }
      )
    }
    existing
  } else if (array(x = existing) && array(x = source)) {
    c(
      existing,
      source[
        !vapply(
          X = source,
          FUN = function(x) {
            any(
              vapply(
                X = existing,
                FUN = identical,
                FUN.VALUE = logical(length = 1),
                y = x
              )
            )
          },
          FUN.VALUE = logical(length = 1)
        )
      ]
    )
  } else {
    source
  }
}
