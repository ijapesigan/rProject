#' Setup Config Files
#'
#' Installs the shell, tmux, Vim, and xterm files from the package
#' (`inst/dotfiles`) into the home directory. A file it replaces is kept in
#' `~/.dotfiles-backup`. It runs `inst/shell/install-dotfiles.sh`, which needs
#' neither R nor a container on the host; `setup-machine.sh` calls that script
#' directly.
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @param check Logical.
#'   If `TRUE`, shows the differences and changes nothing.
#'
#' @return Called for its side effects; the value is not meaningful.
#' @examples
#' \dontrun{
#' ConfigFiles(check = TRUE)
#' }
#' @export
ConfigFiles <- function(check = FALSE) {
  script <- system.file(
    "shell",
    "install-dotfiles.sh",
    package = "rProject",
    mustWork = TRUE
  )
  status <- system2(
    command = "bash",
    args = c(
      .ShellQuote(x = script),
      if (isTRUE(x = check)) {
        "--check"
      }
    )
  )
  if (status != 0) {
    stop(
      "\n\nThe dotfiles were not installed.\n\n",
      call. = FALSE
    )
  }
  invisible(x = NULL)
}
