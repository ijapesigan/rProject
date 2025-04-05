#' Set `PROJECT` Environment Variable
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @param project Character string.
#'   Project name.
#' @return Returns project name.
#' @export
EnvironmentProject <- function(project) {
  Sys.setenv(PROJECT = project[[1]])
  return(
    c(
      PROJECT = project[[1]]
    )
  )
}
