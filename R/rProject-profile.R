#' Setup `.Rprofile`
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LibPaths
#' @inheritParams EnvironmentProject
#' @return Called for its side effects; the value is not meaningful.
#' @examples
#' \dontrun{
#' Profile(path = getwd(), project = "myProject")
#' }
#' @export
Profile <- function(path,
                    project) {
  if (
    file.exists(
      file.path(
        path,
        "DESCRIPTION"
      )
    )
  ) {
    project <- paste0(
      "Sys.setenv",
      "(",
      "PROJECT",
      " = ",
      "\"",
      unname(obj = EnvironmentProject(project = project)),
      "\"",
      ")",
      "\n"
    )
    # deparse() quotes and escapes the path
    lib <- paste0(
      ".libPaths(",
      deparse(expr = .PathSlash(x = LibPaths(path = path))),
      ")",
      "\n"
    )
    opt <- paste0(
      "options(menu.graphics = FALSE)",
      "\n",
      "options(",
      "repos = c(REPO_NAME = ",
      "\"",
      PkgRepo(path = path),
      "\"",
      ")",
      ")",
      "\n"
    )
    profile <- paste0(
      ".First <- function() {", "\n",
      "  ", "if (interactive()) {", "\n",
      "    ", "project <- Sys.getenv(\"PROJECT\")", "\n",
      "    ", "if (project == \"\") {", "\n",
      "      ", "project <- basename(getwd())", "\n",
      "    ", "}", "\n",
      "    ", "options(", "\n",
      "      ", "prompt = paste0(", "\n",
      "        ", "\"[\",", "\n",
      "        ", "project,", "\n",
      "        ", "\"] R> \"", "\n",
      "      ", ")", "\n",
      "    ", ")", "\n",
      "    ", "message(", "\n",
      "      ", "paste(", "\n",
      "        ", "R.version.string,", "\n",
      "        ", "Sys.time(),", "\n",
      "        ", "getwd(),", "\n",
      "        ", "sep = \" | \"", "\n",
      "      ", ")", "\n",
      "    ", ")", "\n",
      "  ", "}", "\n",
      "}", "\n",
      ".Last <- function() {", "\n",
      "  ", "if (interactive()) {", "\n",
      "    ", "try(", "\n",
      "      ", "savehistory(", "\n",
      "        ", "file = file.path(getwd(), \".Rhistory\")", "\n",
      "      ", ")", "\n",
      "    ", ")", "\n",
      "  ", "}", "\n",
      "}", "\n"
    )
    profile <- c(
      project,
      opt,
      lib,
      profile
    )
    con <- file(
      description = file.path(
        path,
        ".Rprofile"
      )
    )
    writeLines(
      text = profile,
      con = con
    )
    close(con = con)
  } else {
    message(
      paste(
        path,
        "is not an R package."
      )
    )
  }
}
