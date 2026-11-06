.VerifyCommitFiles <- function(private) {
  # the files that the last commit adds, changes, or deletes
  out <- .VerifyGit(
    private = private,
    args = c(
      "-c",
      "core.quotepath=off",
      "diff-tree",
      "--root",
      "--no-commit-id",
      "--no-renames",
      "--name-status",
      "-r",
      "HEAD"
    )
  )
  fields <- strsplit(x = out, split = "\t", fixed = TRUE)
  data.frame(
    status = vapply(
      X = fields,
      FUN = function(x) {
        x[1]
      },
      FUN.VALUE = character(length = 1)
    ),
    file = vapply(
      X = fields,
      FUN = function(x) {
        x[2]
      },
      FUN.VALUE = character(length = 1)
    ),
    stringsAsFactors = FALSE
  )
}
