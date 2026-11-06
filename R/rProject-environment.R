#' Setup `.Renviron`
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LibPaths
#' @inheritParams EnvironmentProject
#' @inheritParams EnvironmentTokens
#' @return Called for its side effects; the value is not meaningful.
#' @examples
#' \dontrun{
#' Environment(
#'   path = getwd(),
#'   project = "myProject",
#'   tokens = c(GITHUB_PAT = Sys.getenv(x = "GITHUB_PAT"))
#' )
#' }
#' @export
Environment <- function(path,
                        project,
                        tokens) {
  dot_rprofile_file <- file.path(
    path,
    ".Rprofile"
  )
  Sys.setenv(R_PROFILE_USER = dot_rprofile_file)
  dot_rhistory_file <- file.path(
    path,
    ".Rhistory"
  )
  Sys.setenv(R_HISTFILE = dot_rhistory_file)
  key <- c(
    "R_LIBS_USER",
    "R_PROFILE_USER",
    "R_HISTFILE"
  )
  # forward slashes: .Renviron reads backslashes as escapes
  value <- paste0(
    "\"",
    .PathSlash(
      x = c(
        LibPaths(path = path),
        dot_rprofile_file,
        dot_rhistory_file
      )
    ),
    "\""
  )
  dot_renviron_contents <- paste(
    key,
    value,
    sep = "="
  )
  dot_renviron_contents <- c(
    dot_renviron_contents,
    "R_COMPLETION=TRUE"
  )
  if (!is.null(x = tokens)) {
    tokens <- EnvironmentTokens(tokens = tokens)
    tokens <- paste0(
      names(x = tokens),
      "=",
      "\"",
      unname(obj = tokens),
      "\""
    )
    dot_renviron_contents <- c(
      dot_renviron_contents,
      tokens
    )
  }
  project <- EnvironmentProject(project = project)
  project <- paste0(
    names(x = project),
    "=",
    "\"",
    unname(obj = project),
    "\""
  )
  dot_renviron_contents <- c(
    dot_renviron_contents,
    project
  )
  dot_renviron_file <- file.path(
    path,
    ".Renviron"
  )
  con <- file(description = dot_renviron_file)
  writeLines(
    text = dot_renviron_contents,
    con = con,
    sep = "\n"
  )
  close(con = con)
  # .Renviron may contain tokens
  Sys.chmod(
    paths = dot_renviron_file,
    mode = "600"
  )
}
