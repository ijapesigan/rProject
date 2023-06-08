#' Install tmux
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @export
Tmux <- function() {
  tmux <- system.file(
    file.path(
      "extdata",
      "install-tmux.sh"
    ),
    package = "rProject"
  )
  run_sh <- FALSE
  bin <- file.path(
    Sys.getenv("HOME"),
    ".local",
    "bin"
  )
  dir.create(
    bin,
    showWarnings = FALSE
  )
  tmux <- file.path(
    bin,
    "tmux"
  )
  if (!file.exists(tmux)) {
    run_sh <- TRUE
  }
  if (run_sh) {
    tmp_dir <- tempdir()
    system(
      paste(
        "cd",
        tmp_dir,
        ";",
        "bash",
        tmux
      )
    )
    on.exit(
      unlink(
        tmp_dir
      )
    )
  }
}
