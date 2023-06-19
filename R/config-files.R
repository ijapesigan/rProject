#' Setup Config Files
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @export
ConfigFiles <- function() {
  install <- system.file(
    "shell",
    paste0(
      "dotfiles.sh"
    ),
    package = "rProject"
  )
  tmp_dir <- tempdir()
  system(
    paste(
      "(",
      "cd",
      tmp_dir,
      ";",
      "bash",
      install,
      ")"
    )
  )
  on.exit(
    unlink(
      tmp_dir
    )
  )
  invisible(NULL)
}
