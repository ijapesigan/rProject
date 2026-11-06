#' Build `.Rbuildignore`
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LibPaths
#' @inheritParams EnvironmentProject
#' @param add Character vector.
#'   Items to add to `.Rbuildignore`.
#' @return Called for its side effects; the value is not meaningful.
#' @examples
#' \dontrun{
#' BuildIgnore(path = getwd(), project = "myProject")
#' }
#' @export
BuildIgnore <- function(path,
                        project,
                        add = NULL) {
  if (
    file.exists(
      file.path(
        path,
        "DESCRIPTION"
      )
    )
  ) {
    x <- c(
      ".*\\.Rcheck$",
      ".*\\.Rproj$",
      ".*\\.sif$",
      "^AGENTS\\.md$",
      "^CITATION\\.cff$",
      "^CLAUDE\\.local\\.md$",
      "^CLAUDE\\.md$",
      "^GEMINI\\.md$",
      "^LICENSE\\.md$",
      "^Makefile$",
      "^README\\.Rmd$",
      "^README\\.md$",
      "^\\.Rproj\\.user$",
      "^\\.claude$",
      "^\\.codex$",
      "^\\.devcontainer$",
      "^\\.gemini$",
      "^\\.git.*$",
      "^\\.library$",
      "^\\.mcp\\.json$",
      "^\\.quarto$",
      "^\\.setup$",
      "^\\.sif$",
      "^\\.sim$",
      "^\\.verify$",
      "^detritus$",
      "^index\\.qmd$",
      "^latexmkrc$",
      "^pkgdown$",
      "^quarto$",
      "^scripts$"
    )
    if (!is.null(x = add)) {
      x <- c(x, add)
    }
    con <- file(
      description = file.path(
        path,
        ".Rbuildignore"
      )
    )
    writeLines(
      text = x,
      con = con,
      sep = "\n"
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
