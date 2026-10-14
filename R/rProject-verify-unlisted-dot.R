.VerifyUnlisted <- function(path,
                            private,
                            listed) {
  status <- .VerifyChanges(
    path = path,
    private = private
  )
  # .setup/notes/claude.txt holds the resume commands; the agent keeps it
  # up to date when the user leaves (EX), so it is not a change to list
  status <- status[
    !(names(status) %in% c(listed, ".setup/notes/claude.txt"))
  ]
  out <- paste0(names(status), " (", status, ")")[seq_along(status)]
  if (length(out) > 10L) {
    out <- c(out[1:10], paste("and", length(out) - 10L, "more"))
  }
  out
}
