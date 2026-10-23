.LockExtra <- function(path) {
  # the packages the project adds (project.R): the installed version of
  # each pkg_cran, the installed commit of each pkg_github
  settings <- new.env()
  project_r <- file.path(path, ".setup", "scripts", "project.R")
  if (file.exists(project_r)) {
    sys.source(file = project_r, envir = settings)
  }
  pkg_cran <- get0(
    x = "pkg_cran",
    envir = settings,
    inherits = FALSE,
    ifnotfound = c()
  )
  pkg_github <- get0(
    x = "pkg_github",
    envir = settings,
    inherits = FALSE,
    ifnotfound = c()
  )
  field <- function(pkg, name) {
    value <- suppressWarnings(
      utils::packageDescription(pkg = pkg, fields = name)
    )
    ifelse(is.null(value) || is.na(value), NA_character_, value)
  }
  cran <- vapply(
    X = as.character(pkg_cran),
    FUN = field,
    FUN.VALUE = character(1),
    name = "Version"
  )
  repos <- sub("@.*$", "", as.character(pkg_github))
  github <- vapply(
    X = basename(repos),
    FUN = field,
    FUN.VALUE = character(1),
    name = "RemoteSha"
  )
  names(github) <- repos
  list(
    cran = cran,
    github = github
  )
}
