#' Add `.library` to Library Paths
#'
#' \itemize{
#'   \item{creates a folder `.library` on the project path if it does not exist}
#'   \item{creates a `.gitignore` file inside `.library` if it does not exist}
#'   \item{adds `.library` to `.libPaths()`}
#'   \item{sets `R_LIBS_USER` to `.library`}
#' }
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @param path Character string.
#'   Project path.
#'
#' @return Returns the path of `.library`.
#' @examples
#' \dontrun{
#' LibPaths(path = getwd())
#' }
#' @export
LibPaths <- function(path) {
  dot_library_folder <- file.path(
    path,
    ".library"
  )
  dir.create(
    path = dot_library_folder,
    showWarnings = FALSE,
    recursive = TRUE
  )
  dot_gitignore_file <- file.path(
    dot_library_folder,
    ".gitignore"
  )
  if (!file.exists(dot_gitignore_file)) {
    dot_gitignore <- c(
      "*",
      "*/"
    )
    con <- file(description = dot_gitignore_file)
    writeLines(
      text = dot_gitignore,
      con = con,
      sep = "\n"
    )
    close(con = con)
  }
  .libPaths(
    new = dot_library_folder
  )
  Sys.setenv(
    R_LIBS_USER = dot_library_folder
  )
  dot_library_folder
}
