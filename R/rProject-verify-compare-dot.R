.VerifyCompare <- function(path,
                           private,
                           file) {
  local_file <- file.path(path, file)
  private_file <- file.path(private, file)
  if (!file.exists(private_file)) {
    "missing in the private repository"
  } else if (!file.exists(local_file)) {
    "missing locally"
  } else if (dir.exists(
    paths = local_file
  ) || dir.exists(paths = private_file)) {
    "match"
  } else if (
    unname(
      obj = tools::md5sum(files = local_file)
    ) == unname(obj = tools::md5sum(files = private_file))
  ) {
    "match"
  } else {
    local_text <- .VerifyText(file = local_file)
    private_text <- .VerifyText(file = private_file)
    if (
      !is.null(x = local_text) &&
        !is.null(x = private_text) &&
        identical(x = local_text, y = private_text)
    ) {
      "match"
    } else {
      "different"
    }
  }
}
