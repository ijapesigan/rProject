#' Package Manual
#'
#' @inheritParams LibPaths
#' @inheritParams EnvironmentProject
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
        output,
        pattern = utils::glob2rx("*.pdf"),
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
    system(
      paste(
        shQuote(
          file.path(
            R.home("bin"),
            "R"
          )
        ),
        "CMD",
        "Rd2pdf",
        shQuote(
          find.package(project)
        )
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
