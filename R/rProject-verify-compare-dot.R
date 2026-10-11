.VerifyCompare <- function(path,
                           private,
                           file) {
  local_file <- file.path(path, file)
  private_file <- file.path(private, file)
  if (!file.exists(private_file)) {
    "missing in the private repository"
  } else if (!file.exists(local_file)) {
    "missing locally"
  } else if (dir.exists(local_file) || dir.exists(private_file)) {
    "match"
  } else if (
    unname(tools::md5sum(local_file)) == unname(tools::md5sum(private_file))
  ) {
    "match"
  } else {
    local_text <- .VerifyText(file = local_file)
    private_text <- .VerifyText(file = private_file)
    if (
      !is.null(local_text) &&
        !is.null(private_text) &&
        identical(local_text, private_text)
    ) {
      "match"
    } else {
      "different"
    }
  }
}
