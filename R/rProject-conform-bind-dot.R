.ConformBind <- function(rows) {
  out <- do.call(
    what = rbind,
    args = c(list(.ConformEmpty()), rows)
  )
  rownames(x = out) <- NULL
  out
}
