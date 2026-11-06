#' Set `PROJECT` Environment Variable
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @param project Character string.
#'   Project name.
#' @return Returns project name.
#' @examples
#' \dontrun{
#' EnvironmentProject(project = "myProject")
#' }
#' @export
EnvironmentProject <- function(project) {
  Sys.setenv(PROJECT = project[[1]])
  c(
    PROJECT = project[[1]]
  )
}
