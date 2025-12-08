#' Setup Config Files
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @details This function requires a `dotfiles` GitHub repository.
#'
#' @param git_user Character string.
#'   Git user.
#'
#' @export
ConfigFiles <- function(git_user) {
  if (Sys.which("git") == "") {
    stop("git is not installed.")
  }
  dotfiles <- paste0(
    "git clone https://github.com/",
    git_user,
    "/dotfiles.git; cd dotfiles; make"
  )
  tmp_dir <- tempdir()
  system(
    paste(
      "(",
      "cd",
      tmp_dir,
      ";",
      dotfiles,
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
