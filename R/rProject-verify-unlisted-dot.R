.VerifyUnlisted <- function(path,
                            private,
                            listed) {
  status <- .VerifyChanges(
    path = path,
    private = private
  )
  status <- status[!(names(status) %in% listed)]
  out <- paste0(names(status), " (", status, ")")[seq_along(status)]
  if (length(out) > 10L) {
    out <- c(out[1:10], paste("and", length(out) - 10L, "more"))
  }
  out
}
