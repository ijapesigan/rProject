#' Package Manual
#'
#' @inheritParams LibPaths
#' @inheritParams EnvironmentProject
#' @return Called for its side effects; the value is not meaningful.
#' @examples
#' \dontrun{
#' Manual(path = getwd(), project = "myProject")
#' }
#' @export
Manual <- function(path,
                   project) {
  if (
    file.exists(
      file.path(
        path,
        "DESCRIPTION"
      )
    )
  ) {
    output <- file.path(
      path,
      ".setup",
      "build"
    )
    unlink(
      x = list.files(
        path = output,
        pattern = utils::glob2rx(pattern = "*.pdf"),
        full.names = TRUE
      )
    )
    man <- file.path(
      path,
      paste0(
        project,
        ".",
        "pdf"
      )
    )
    unlink(
      x = man
    )
    system2(
      command = file.path(
        R.home(component = "bin"),
        "R"
      ),
      args = c(
        "CMD",
        "Rd2pdf",
        .ShellQuote(x = find.package(package = project))
      )
    )
    file.copy(
      from = man,
      to = file.path(
        path,
        ".setup",
        "build"
      )
    )
    on.exit(
      expr = unlink(
        x = man
      ),
      add = TRUE
    )
  } else {
    message(
      paste(
        path,
        "is not an R package."
      )
    )
  }
}
