.LintPkg <- function(path) {
  # the package name, or the project's name without a DESCRIPTION
  description <- file.path(path, "DESCRIPTION")
  if (file.exists(description)) {
    read.dcf(file = description, fields = "Package")[1, 1]
  } else {
    .VerifyProject(path = path)
  }
}
