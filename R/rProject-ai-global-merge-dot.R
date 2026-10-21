.AIGlobalMerge <- function(existing,
                           source) {
  # objects (named lists): merge by key, the source wins;
  # arrays (unnamed lists, e.g., permission rules): union;
  # anything else: the source
  object <- function(x) {
    is.list(x) && !is.null(names(x))
  }
  array <- function(x) {
    is.list(x) && is.null(names(x))
  }
  if (object(existing) && object(source)) {
    for (key in names(source)) {
      existing[key] <- list(
        if (key %in% names(existing)) {
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
  } else if (array(existing) && array(source)) {
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
                FUN.VALUE = logical(1),
                y = x
              )
            )
          },
          FUN.VALUE = logical(1)
        )
      ]
    )
  } else {
    source
  }
}
