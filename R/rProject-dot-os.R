# https://www.r-bloggers.com/2015/06/identifying-the-os-from-r/
.OS <- function() {
  sysinf <- Sys.info()
  if (!is.null(x = sysinf)) {
    os <- sysinf["sysname"]
    if (os == "Darwin") {
      os <- "osx"
    }
  } else { ## mystery machine
    os <- .Platform$OS.type
    r_version <- R.version$os
    if (grepl(pattern = "^darwin", x = r_version)) {
      os <- "osx"
    }
    if (grepl(pattern = "linux-gnu", x = r_version)) {
      os <- "linux"
    }
  }
  tolower(x = os)
}
