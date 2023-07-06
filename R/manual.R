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
    unlink(
      file.path(
        path,
        paste0(project, "pdf")
      )
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
  } else {
    message(
      paste(
        path,
        "is not an R package."
      )
    )
  }
}
