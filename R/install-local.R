#' Install Applications on Local Machine
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @param what Character string.
#'   Vector of applications to install.
#'   Valid values include
#'   `"tmux"`, `"julia"`, `"mpdemo"`, `"lazygit"`, `"pfetch"`, and `"quarto"`.
#' @param all Logical.
#'   If `all = TRUE`, ignore `what` and install all valid `what` values.
#' @param force Logical.
#'   If `force = TRUE`, install whether or not the application is
#'   available in the system.
#'
#' @export
InstallLocal <- function(what = c(
                           "tmux",
                           "julia",
                           "mpdemo",
                           "lazygit",
                           "pfetch",
                           "quarto"
                         ),
                         all = FALSE,
                         force = FALSE) {
  all_apps <- c(
    "tmux",
    "julia",
    "mpdemo",
    "lazygit",
    "pfetch",
    "quarto"
  )
  if (all) {
    what <- all_apps
  }
  bin <- file.path(
    Sys.getenv("HOME"),
    ".local",
    "bin"
  )
  dir.create(
    bin,
    showWarnings = FALSE
  )
  for (i in seq_along(what)) {
    if (what[i] %in% all_apps) {
      if (force) {
        run_sh <- TRUE
      } else {
        if (Sys.which(what[i]) == "") {
          run_sh <- TRUE
        } else {
          run_sh <- FALSE
        }
      }
      if (run_sh) {
        install <- system.file(
          "shell",
          paste0(
            "install-",
            what[i],
            ".sh"
          ),
          package = "rProject"
        )
        if (run_sh) {
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
        }
      }
    }
  }
  invisible(NULL)
}
