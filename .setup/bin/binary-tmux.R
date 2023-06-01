#' Setup Mplus Demo
BinaryTmux <- function() {
  root <- rprojroot::is_rstudio_project
  run_sh <- FALSE
  run_r <- FALSE
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
    system(
      paste(
        "cd",
        root$find_file(
          ".setup",
          "bin"
        ),
        ";",
        "bash",
        root$find_file(
          ".setup",
          "bin",
          "binary-tmux.sh"
        )
      )
    )
  }
  on.exit(
    unlink(
      root$find_file(
        "TEMPDIR"
      )
    )
  )
}
BinaryTmux()
