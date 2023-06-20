#' Setup Mplus Demo
BinaryMpdemo <- function() {
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
  mpdemo_from <- file.path(
    bin,
    "mpdemo"
  )
  mpdemo_to <- root$find_file(
    ".setup",
    "bin",
    "mpdemo"
  )
  if (!file.exists(mpdemo_from)) {
    run_sh <- TRUE
  }
  if (!file.exists(mpdemo_to)) {
    run_r <- TRUE
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
          "binary-mpdemo.sh"
        )
      )
    )
  }
  if (run_r) {
    file.copy(
      from = file.path(
        bin,
        "mpdemo"
      ),
      to = root$find_file(
        ".setup",
        "bin"
      ),
      overwrite = TRUE
    )
    system(
      paste(
        "chmod 777",
        root$find_file(
          ".setup",
          "bin",
          "mpdemo"
        )
      )
    )
  }
}
BinaryMpdemo()
