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
      expr = utils::packageDescription(pkg = pkg, fields = name)
    )
    ifelse(
      test = is.null(x = value) || is.na(x = value),
      yes = NA_character_,
      no = value
    )
  }
  cran <- vapply(
    X = as.character(x = pkg_cran),
    FUN = field,
    FUN.VALUE = character(length = 1),
    name = "Version"
  )
  repos <- sub(
    pattern = "@.*$",
    replacement = "",
    x = as.character(x = pkg_github)
  )
  github <- vapply(
    X = basename(path = repos),
    FUN = field,
    FUN.VALUE = character(length = 1),
    name = "RemoteSha"
  )
  names(x = github) <- repos
  list(
    cran = cran,
    github = github
  )
}
